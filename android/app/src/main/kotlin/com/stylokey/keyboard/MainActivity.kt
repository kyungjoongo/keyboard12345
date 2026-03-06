package com.stylokey.keyboard

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.provider.Settings
import android.view.Gravity
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.MobileAds
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class MainActivity : Activity() {

    private var adView: AdView? = null
    private var previewEngine: FlutterEngine? = null
    private var previewFlutterView: FlutterView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MobileAds.initialize(this)

        // 키보드 미리보기용 Flutter 엔진 초기화
        previewEngine = FlutterEngine(this).also { engine ->
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                    "previewMain"
                )
            )
            engine.lifecycleChannel.appIsResumed()
        }
        previewFlutterView = FlutterView(this, FlutterTextureView(this)).also { fv ->
            fv.attachToFlutterEngine(previewEngine!!)
        }

        setContentView(buildUI())
    }

    override fun onResume() {
        super.onResume()
        adView?.resume()
        previewEngine?.lifecycleChannel?.appIsResumed()
        setContentView(buildUI())
    }

    override fun onPause() {
        adView?.pause()
        previewEngine?.lifecycleChannel?.appIsPaused()
        super.onPause()
    }

    override fun onDestroy() {
        adView?.destroy()
        previewFlutterView?.detachFromFlutterEngine()
        previewEngine?.destroy()
        previewEngine = null
        super.onDestroy()
    }

    private fun isImeEnabled(): Boolean {
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        return imm.enabledInputMethodList.any { it.packageName == packageName }
    }

    private fun isImeSelected(): Boolean {
        val selected = Settings.Secure.getString(contentResolver, Settings.Secure.DEFAULT_INPUT_METHOD)
        return selected?.startsWith(packageName) == true
    }

    private fun buildUI(): LinearLayout {
        val enabled = isImeEnabled()
        val selected = isImeSelected()

        // 최상위: 세로 레이아웃 (스크롤 영역 + 광고 배너)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#F3F4F6"))
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        // ── 스크롤 콘텐츠 영역 ──────────────────────────────────────
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(40), dp(20), dp(20))
        }

        container.addView(TextView(this).apply {
            text = "⌨️"
            textSize = 52f
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(8))
        })
        container.addView(TextView(this).apply {
            text = "StyloKey"
            textSize = 28f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#111827"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(4))
        })
        container.addView(TextView(this).apply {
            text = "한국어 키보드 설정"
            textSize = 14f
            setTextColor(Color.parseColor("#6B7280"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(32))
        })

        container.addView(buildStepCard(
            step = "1",
            title = "키보드 활성화",
            desc = "시스템 설정에서 StyloKey를 활성화해 주세요.",
            btnText = if (enabled) "완료 ✓" else "설정 열기",
            done = enabled,
            onClick = { startActivity(Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)) }
        ))

        container.addView(TextView(this).apply { height = dp(12) })

        container.addView(buildStepCard(
            step = "2",
            title = "기본 키보드로 설정",
            desc = "키보드 선택 창에서 StyloKey를 선택해 주세요.",
            btnText = if (selected) "완료 ✓" else "키보드 선택",
            done = selected,
            enabled = enabled,
            onClick = {
                val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                imm.showInputMethodPicker()
            }
        ))

        if (enabled && selected) {
            container.addView(TextView(this).apply { height = dp(24) })
            container.addView(TextView(this).apply {
                text = "✅ 설정 완료! StyloKey를 사용할 준비가 됐어요."
                textSize = 14f
                setTextColor(Color.parseColor("#059669"))
                gravity = Gravity.CENTER
                setBackgroundColor(Color.parseColor("#ECFDF5"))
                setPadding(dp(16), dp(16), dp(16), dp(16))
            })
        }

        // ── 설정 카드는 스크롤 영역 안에만 ──────────────────────────
        val scrollView = ScrollView(this).apply {
            setBackgroundColor(Color.parseColor("#F3F4F6"))
            addView(container)
        }
        root.addView(scrollView, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f
        ))

        // ── 키보드 미리보기 (스크롤 영역 밖 고정) ────────────────────
        root.addView(TextView(this).apply {
            text = "키보드 미리보기"
            textSize = 13f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#6B7280"))
            setBackgroundColor(Color.parseColor("#F3F4F6"))
            setPadding(dp(20), dp(10), dp(20), dp(6))
        })

        previewFlutterView?.let { fv ->
            (fv.parent as? ViewGroup)?.removeView(fv)
            root.addView(fv, LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(422)  // 텍스트창 72 + 키보드 350
            ))
        }

        // ── 하단 배너 광고 ──────────────────────────────────────────
        adView = AdView(this).apply {
            setAdSize(AdSize.BANNER)
            adUnitId = "ca-app-pub-3940256099942544/6300978111" // 테스트 ID
            loadAd(AdRequest.Builder().build())
        }
        root.addView(adView, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        return root
    }

    private fun buildStepCard(
        step: String,
        title: String,
        desc: String,
        btnText: String,
        done: Boolean,
        enabled: Boolean = true,
        onClick: () -> Unit
    ): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(20), dp(20), dp(20))
            setBackgroundColor(Color.WHITE)
        }

        val header = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, 0, 0, dp(10))
        }
        header.addView(TextView(this).apply {
            text = step
            textSize = 13f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.WHITE)
            setBackgroundColor(if (done) Color.parseColor("#10B981") else Color.parseColor("#6B7280"))
            gravity = Gravity.CENTER
            width = dp(28)
            height = dp(28)
        })
        header.addView(TextView(this).apply {
            text = "  $title"
            textSize = 16f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#111827"))
        })
        card.addView(header)

        card.addView(TextView(this).apply {
            text = desc
            textSize = 13f
            setTextColor(Color.parseColor("#6B7280"))
            setPadding(0, 0, 0, dp(16))
        })

        card.addView(Button(this).apply {
            text = btnText
            textSize = 14f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.WHITE)
            isEnabled = enabled
            setBackgroundColor(when {
                done    -> Color.parseColor("#10B981")
                !enabled -> Color.parseColor("#D1D5DB")
                else    -> Color.parseColor("#3B82F6")
            })
            if (!done && enabled) setOnClickListener { onClick() }
        })

        return card
    }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()
}
