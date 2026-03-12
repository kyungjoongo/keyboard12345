package com.stylokey.keyboard

import android.inputmethodservice.InputMethodService
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.widget.FrameLayout
import android.os.Handler
import android.os.Looper
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
    private var keyboardContainer: FrameLayout? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // ── Prevent IME from going full-screen ─────────────────────────────────
    override fun onEvaluateFullscreenMode(): Boolean = false

    /** currentInputConnection이 null일 경우 50ms 후 1회 재시도 */
    private fun withInputConnection(action: (android.view.inputmethod.InputConnection) -> Unit) {
        val ic = currentInputConnection
        if (ic != null) {
            action(ic)
        } else {
            mainHandler.postDelayed({
                currentInputConnection?.let(action)
            }, 50)
        }
    }

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
                    when (call.method) {
                        "commitText" -> {
                            val text = call.argument<String>("text") ?: ""
                            withInputConnection { ic -> ic.commitText(text, 1) }
                            result.success(null)
                        }
                        "setComposingText" -> {
                            val text = call.argument<String>("text") ?: ""
                            withInputConnection { ic ->
                                if (text.isEmpty()) ic.finishComposingText()
                                else ic.setComposingText(text, 1)
                            }
                            result.success(null)
                        }
                        // 더블탭 업그레이드용: 기존 composing/committed 글자를 지우고 새 글자로 교체
                        "replaceComposing" -> {
                            val newText = call.argument<String>("text") ?: ""
                            withInputConnection { ic ->
                                ic.beginBatchEdit()
                                ic.finishComposingText()          // 현재 composing 확정
                                ic.deleteSurroundingText(1, 0)    // 확정된 글자 삭제
                                if (newText.isNotEmpty()) {
                                    ic.setComposingText(newText, 1) // 새 글자 composing으로 설정
                                }
                                ic.endBatchEdit()
                            }
                            result.success(null)
                        }
                        // 자판 전환 시 composing을 원자적으로 commit + 종료
                        "switchModeCommit" -> {
                            val text = call.argument<String>("text") ?: ""
                            withInputConnection { ic ->
                                ic.beginBatchEdit()
                                if (text.isNotEmpty()) {
                                    ic.commitText(text, 1)
                                }
                                ic.finishComposingText()
                                ic.endBatchEdit()
                            }
                            result.success(null)
                        }
                        "deleteSurroundingText" -> {
                            withInputConnection { ic -> ic.deleteSurroundingText(1, 0) }
                            result.success(null)
                        }
                        "updateKeyboardHeight" -> {
                            val heightDp = call.argument<Int>("height") ?: 350
                            updateViewHeight(heightDp)
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

        // ── TextureView: 뷰 계층 내 인라인 렌더링 → 이중 버퍼 swap 깜빡임 없음 ──
        val textureView = FlutterTextureView(this)
        flutterView = FlutterView(this, textureView).also { fv ->
            fv.attachToFlutterEngine(engine)
        }

        // SharedPreferences에서 실제 키보드 높이 읽기 (Flutter 기본값 350dp)
        val density = resources.displayMetrics.density
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val storedHeightDp = prefs.getInt("flutter.keyboardHeight", 350)
        val keyboardHeight = (storedHeightDp * density).toInt()

        // IME 윈도우 높이를 keyboardHeight로만 고정 (네비게이션 바 패딩 추가 시 앱 화면을 과도하게 가림)
        val container = FrameLayout(this)
        container.addView(
            flutterView,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                keyboardHeight
            )
        )
        keyboardContainer = container
        return container
    }

    /** Flutter에서 높이 변경 시 네이티브 뷰 높이를 동기화 */
    private fun updateViewHeight(heightDp: Int) {
        val px = (heightDp * resources.displayMetrics.density).toInt()
        val fv = flutterView ?: return
        val lp = fv.layoutParams as? FrameLayout.LayoutParams ?: return
        if (lp.height != px) {
            lp.height = px
            fv.layoutParams = lp
        }
    }

    private fun getNavBarHeightDp(): Int {
        return try {
            val density = resources.displayMetrics.density
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val wm = getSystemService(WINDOW_SERVICE) as? WindowManager
                    ?: return 0
                val insets = wm.currentWindowMetrics.windowInsets
                val navInsets = insets.getInsets(WindowInsets.Type.navigationBars())
                (navInsets.bottom / density).toInt()
            } else {
                val resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android")
                if (resourceId > 0) (resources.getDimensionPixelSize(resourceId) / density).toInt() else 0
            }
        } catch (e: Exception) {
            0
        }
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        flutterEngine?.lifecycleChannel?.appIsResumed()
        // 새 입력 필드 포커스 시 Flutter 컴포저 상태 초기화
        channel?.invokeMethod("reset", null)
        // 설정에서 높이가 바뀌었을 수 있으므로 매번 동기화
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val heightDp = prefs.getInt("flutter.keyboardHeight", 350)
        updateViewHeight(heightDp)
        // 네비게이션 바 높이를 Flutter에 전달 (Flutter 엔진 준비 후 전송)
        val navHeight = getNavBarHeightDp()
        mainHandler.postDelayed({
            channel?.invokeMethod("setNavBarHeight", mapOf("height" to navHeight))
        }, 200)
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
