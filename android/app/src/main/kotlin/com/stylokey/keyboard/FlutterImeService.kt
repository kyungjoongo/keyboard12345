package com.stylokey.keyboard

import android.inputmethodservice.InputMethodService
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.view.inputmethod.EditorInfo
import android.widget.FrameLayout
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class FlutterImeService : InputMethodService() {

    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var channel: MethodChannel? = null

    // ── Prevent IME from going full-screen ─────────────────────────────────
    override fun onEvaluateFullscreenMode(): Boolean = false

    override fun onCreate() {
        super.onCreate()

        flutterEngine = FlutterEngine(this).also { engine ->
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                    "imeMain"
                )
            )
            engine.lifecycleChannel.appIsResumed()

            channel = MethodChannel(
                engine.dartExecutor.binaryMessenger,
                "com.example.keyboard12345/ime"
            ).apply {
                setMethodCallHandler { call, result ->
                    val ic = currentInputConnection
                    when (call.method) {
                        "commitText" -> {
                            val text = call.argument<String>("text") ?: ""
                            ic?.commitText(text, 1)
                            result.success(null)
                        }
                        "setComposingText" -> {
                            val text = call.argument<String>("text") ?: ""
                            if (text.isEmpty()) ic?.finishComposingText()
                            else ic?.setComposingText(text, 1)
                            result.success(null)
                        }
                        // 더블탭 업그레이드용: 기존 composing/committed 글자를 지우고 새 글자로 교체
                        "replaceComposing" -> {
                            val newText = call.argument<String>("text") ?: ""
                            ic?.beginBatchEdit()
                            ic?.finishComposingText()          // 현재 composing 확정
                            ic?.deleteSurroundingText(1, 0)    // 확정된 글자 삭제
                            if (newText.isNotEmpty()) {
                                ic?.setComposingText(newText, 1) // 새 글자 composing으로 설정
                            }
                            ic?.endBatchEdit()
                            result.success(null)
                        }
                        // 자판 전환 시 composing을 원자적으로 commit + 종료
                        "switchModeCommit" -> {
                            val text = call.argument<String>("text") ?: ""
                            ic?.beginBatchEdit()
                            if (text.isNotEmpty()) {
                                ic?.commitText(text, 1)
                            }
                            ic?.finishComposingText()
                            ic?.endBatchEdit()
                            result.success(null)
                        }
                        "deleteSurroundingText" -> {
                            ic?.deleteSurroundingText(1, 0)
                            result.success(null)
                        }
                        "performEditorAction" -> {
                            val opts = currentInputEditorInfo?.imeOptions
                                ?: EditorInfo.IME_ACTION_DONE
                            sendDefaultEditorAction(
                                (opts and EditorInfo.IME_MASK_ACTION) == EditorInfo.IME_ACTION_NONE
                            )
                            result.success(null)
                        }
                        "vibrate" -> {
                            // level: 0=약(15ms), 1=중(25ms), 2=강(45ms)
                            val level = call.argument<Int>("level") ?: 1
                            val (durationMs, amplitude) = when (level) {
                                0 -> Pair(12L, 60)
                                2 -> Pair(45L, VibrationEffect.DEFAULT_AMPLITUDE)
                                else -> Pair(25L, VibrationEffect.DEFAULT_AMPLITUDE)
                            }
                            @Suppress("DEPRECATION")
                            val vibrator = getSystemService(VIBRATOR_SERVICE) as? Vibrator
                            vibrator?.let {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    it.vibrate(VibrationEffect.createOneShot(durationMs, amplitude))
                                } else {
                                    @Suppress("DEPRECATION")
                                    it.vibrate(durationMs)
                                }
                            }
                            result.success(null)
                        }
                        "playKeySound" -> {
                            // volume: 0.0~1.0, theme: 0=기본, 1=타자기, 2=부드러움
                            val volume = (call.argument<Double>("volume") ?: 0.5).toFloat()
                            val theme = call.argument<Int>("theme") ?: 0
                            val soundEffect = when (theme) {
                                1 -> AudioManager.FX_KEYPRESS_RETURN   // 타자기
                                2 -> AudioManager.FX_KEYPRESS_SPACEBAR // 부드러움
                                else -> AudioManager.FX_KEYPRESS_STANDARD // 기본
                            }
                            val am = getSystemService(AUDIO_SERVICE) as? AudioManager
                            am?.playSoundEffect(soundEffect, volume)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                }
            }
        }
    }

    override fun onCreateInputView(): View {
        val engine = flutterEngine ?: return View(this)

        // ── Use TextureView (no separate z-layer) so it doesn't cover the app ──
        val textureView = FlutterTextureView(this)
        flutterView = FlutterView(this, textureView).also { fv ->
            fv.attachToFlutterEngine(engine)
        }

        // ── Wrap in a FrameLayout with a fixed keyboard height ──────────────
        // Flutter SizedBox가 내부 높이를 제어하므로 최대치(440dp)로 설정
        val density = resources.displayMetrics.density
        val keyboardHeight = (440 * density).toInt()

        // Android 15 edge-to-edge: 네비게이션 바 높이만큼 하단 패딩 추가
        val container = object : FrameLayout(this) {
            override fun onApplyWindowInsets(insets: WindowInsets): WindowInsets {
                val navBottom = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    insets.getInsets(WindowInsets.Type.navigationBars()).bottom
                } else {
                    @Suppress("DEPRECATION")
                    insets.systemWindowInsetBottom
                }
                setPadding(0, 0, 0, navBottom)
                return insets
            }
        }
        container.setBackgroundColor(0xFFD1D5DB.toInt())
        container.addView(
            flutterView,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                keyboardHeight
            )
        )
        return container
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        flutterEngine?.lifecycleChannel?.appIsResumed()
        // 새 입력 필드 포커스 시 Flutter 컴포저 상태 초기화
        channel?.invokeMethod("reset", null)
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        flutterEngine?.lifecycleChannel?.appIsPaused()
    }

    override fun onDestroy() {
        flutterView?.detachFromFlutterEngine()
        flutterEngine?.destroy()
        flutterEngine = null
        super.onDestroy()
    }
}
