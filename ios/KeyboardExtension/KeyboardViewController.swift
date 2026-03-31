import UIKit
import Flutter
import AudioToolbox

// MARK: - KeyboardViewController
// iOS Custom Keyboard Extension
// Flutter 엔진을 내장하여 Dart 키보드 UI를 그대로 사용합니다.
// MethodChannel: com.example.keyboard12345/ime

class KeyboardViewController: UIInputViewController {

    // MARK: - Properties

    private var flutterEngine: FlutterEngine?
    private var flutterVC:     FlutterViewController?
    private var channel:       FlutterMethodChannel?

    /// Android composingText와 동일한 역할: 현재 조합 중인 텍스트 추적
    private var composingText = ""

    /// 키보드 높이 제약 (Dart 설정 슬라이더와 동기화)
    private var heightConstraint: NSLayoutConstraint?
    private let defaultHeight: CGFloat = 430
    private let heightKey = "com.stylokey.keyboardHeight"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupFlutter()
        setupNextKeyboardButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Dart 키보드 초기화: 현재 앱의 returnKeyType → imeAction 변환
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            let action = self.mapReturnKeyType(
                self.textDocumentProxy.returnKeyType ?? .default
            )
            self.channel?.invokeMethod("reset", arguments: ["imeAction": action])
        }
    }

    // MARK: - Flutter Setup

    private func setupFlutter() {
        let engine = FlutterEngine(
            name: "stylokey_engine",
            project: nil,
            allowHeadlessExecution: true
        )
        // Dart 진입점: iosImeMain (Firebase 없이 순수 키보드 UI만 실행)
        engine.run(withEntrypoint: "iosImeMain", initialRoute: nil)

        let vc = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        flutterEngine = engine
        flutterVC    = vc

        // MethodChannel 연결
        let ch = FlutterMethodChannel(
            name: "com.example.keyboard12345/ime",
            binaryMessenger: engine.binaryMessenger
        )
        channel = ch
        ch.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        // Flutter 뷰 추가
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false

        // 키보드 전체 높이 제약 (저장된 높이 복원, 없으면 기본값)
        let savedHeight = CGFloat(UserDefaults.standard.integer(forKey: heightKey))
        let initialHeight = savedHeight > 100 ? savedHeight : defaultHeight
        heightConstraint = view.heightAnchor.constraint(equalToConstant: initialHeight)
        heightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            vc.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            vc.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            vc.view.topAnchor.constraint(equalTo: view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        vc.didMove(toParent: self)
    }

    // MARK: - Globe (Input Mode Switch) Button

    private func setupNextKeyboardButton() {
        guard needsInputModeSwitchKey else { return }

        let btn = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(systemName: "globe"), for: .normal)
        } else {
            btn.setTitle("🌐", for: .normal)
        }
        btn.tintColor = UIColor(white: 0.45, alpha: 0.9)
        btn.addTarget(
            self,
            action: #selector(handleInputModeList(from:with:)),
            for: .allTouchEvents
        )
        btn.translatesAutoresizingMaskIntoConstraints = false
        // Flutter 뷰 위에 오버레이 (하단 우측 → 키보드 전환 표준 위치)
        view.addSubview(btn)
        view.bringSubviewToFront(btn)
        NSLayoutConstraint.activate([
            btn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6),
            btn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            btn.widthAnchor.constraint(equalToConstant: 44),
            btn.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - MethodChannel Handler

    private func handleMethodCall(_ call: FlutterMethodCall,
                                  result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {

        // ── 텍스트 커밋 ────────────────────────────────────────────────────────
        case "commitText":
            let text = args?["text"] as? String ?? ""
            guard !text.isEmpty else { result(nil); break }

            if !composingText.isEmpty && text == composingText {
                // 한글 조합 확정: 동일 텍스트가 이미 필드에 있음 → 추적만 초기화
                composingText = ""
            } else {
                // 영문·공백·이모지 또는 다른 텍스트 → 조합 제거 후 직접 삽입
                if !composingText.isEmpty {
                    let n = composingText.unicodeScalars.count
                    for _ in 0..<n { textDocumentProxy.deleteBackward() }
                    composingText = ""
                }
                textDocumentProxy.insertText(text)
            }
            result(nil)

        // ── 조합 중 텍스트 설정 (한글 조합) ───────────────────────────────────
        case "setComposingText":
            let newText = args?["text"] as? String ?? ""
            replaceComposing(with: newText)
            result(nil)

        // ── 조합 중 텍스트 교체 ────────────────────────────────────────────────
        case "replaceComposing":
            let newText = args?["text"] as? String ?? ""
            replaceComposing(with: newText)
            result(nil)

        // ── 뒤로 삭제 ─────────────────────────────────────────────────────────
        case "deleteSurroundingText":
            if !composingText.isEmpty {
                replaceComposing(with: "")  // 조합 텍스트 실제 삭제 + 추적 초기화
            } else {
                textDocumentProxy.deleteBackward()
            }
            result(nil)

        // ── 모드 전환 + 조합 커밋 (원자적) ────────────────────────────────────
        case "switchModeCommit":
            let text = args?["text"] as? String ?? ""
            if !composingText.isEmpty && text == composingText {
                composingText = ""
            } else {
                if !composingText.isEmpty {
                    let n = composingText.unicodeScalars.count
                    for _ in 0..<n { textDocumentProxy.deleteBackward() }
                    composingText = ""
                }
                if !text.isEmpty { textDocumentProxy.insertText(text) }
            }
            result(nil)

        // ── 엔터/확인 액션 ────────────────────────────────────────────────────
        case "performEditorAction":
            textDocumentProxy.insertText("\n")
            result(nil)

        // ── 커서 앞 텍스트 가져오기 (AI 기능용) ──────────────────────────────
        case "getTextBeforeCursor":
            let length = args?["length"] as? Int ?? 100
            let ctx    = textDocumentProxy.documentContextBeforeInput ?? ""
            let start  = ctx.index(ctx.endIndex, offsetBy: -min(length, ctx.count))
            result(String(ctx[start...]))

        // ── 커서 앞 텍스트 교체 (AI 정제 결과 반영) ──────────────────────────
        case "replaceTextBeforeCursor":
            let oldLen  = args?["oldLen"] as? Int ?? 0
            let newText = args?["newText"] as? String ?? ""
            composingText = ""
            for _ in 0..<oldLen { textDocumentProxy.deleteBackward() }
            if !newText.isEmpty { textDocumentProxy.insertText(newText) }
            result(nil)

        // ── 진동 피드백 ───────────────────────────────────────────────────────
        case "vibrate":
            let level = args?["level"] as? Int ?? 1
            switch level {
            case 0:  UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case 2:  UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            default: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            result(nil)

        // ── 키 클릭 소리 ──────────────────────────────────────────────────────
        case "playKeySound":
            AudioServicesPlaySystemSound(1104) // 시스템 키보드 클릭음
            result(nil)

        // ── 키보드 높이 동기화 ────────────────────────────────────────────────
        case "updateKeyboardHeight":
            if let h = args?["height"] as? Int, h > 100 {
                UserDefaults.standard.set(h, forKey: heightKey) // 높이 영구 저장
                DispatchQueue.main.async { [weak self] in
                    self?.heightConstraint?.constant = CGFloat(h)
                    self?.view.layoutIfNeeded()
                }
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Composing Helpers

    /// 조합 중 텍스트를 새 값으로 교체합니다.
    private func replaceComposing(with newText: String) {
        let deleteCount = composingText.unicodeScalars.count
        for _ in 0..<deleteCount { textDocumentProxy.deleteBackward() }
        composingText = newText
        if !newText.isEmpty { textDocumentProxy.insertText(newText) }
    }

    /// 조합을 완료 처리합니다 (composingText 비움).
    private func flushComposing() {
        composingText = ""
    }

    // MARK: - Return Key → IME Action Mapping

    private func mapReturnKeyType(_ type: UIReturnKeyType) -> Int {
        switch type {
        case .go:      return 2
        case .search:  return 3
        case .send:    return 4
        case .next:    return 5
        case .done:    return 6
        default:       return 0
        }
    }

    // MARK: - Text Change Detection

    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)

        // 외부에서 커서가 이동하면 조합 초기화
        if !composingText.isEmpty {
            let ctx = textDocumentProxy.documentContextBeforeInput ?? ""
            if !ctx.hasSuffix(composingText) {
                composingText = ""
                channel?.invokeMethod("cursorMoved", arguments: nil)
            }
        }
    }
}
