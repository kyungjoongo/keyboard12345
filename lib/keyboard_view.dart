import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'korean_composer.dart';

const _channel = MethodChannel('com.example.keyboard12345/ime');

// ── Theme ──────────────────────────────────────────────────────────────────────

class KeyboardTheme {
  final String name;
  final Color swatch;
  final Color background;
  final Color charKey;
  final Color charKeyPressed;
  final Color actionKey;
  final Color actionKeyPressed;
  final Color activeKey;
  final Color activePressedKey;
  final Color charKeyText;
  final Color actionKeyText;

  const KeyboardTheme({
    required this.name,
    required this.swatch,
    required this.background,
    required this.charKey,
    required this.charKeyPressed,
    required this.actionKey,
    required this.actionKeyPressed,
    required this.activeKey,
    required this.activePressedKey,
    required this.charKeyText,
    required this.actionKeyText,
  });

  static const List<KeyboardTheme> presets = [
    KeyboardTheme(
      name: '라이트',
      swatch: Color(0xFFD1D5DB),
      background: Color(0xFFD1D5DB),
      charKey: Color(0xFFFFFFFF),
      charKeyPressed: Color(0xFFCCCCCC),
      actionKey: Color(0xFFADB5BD),
      actionKeyPressed: Color(0xFF9AA3AB),
      activeKey: Color(0xFF6B7280),
      activePressedKey: Color(0xFF505860),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xDD000000),
    ),
    KeyboardTheme(
      name: '다크',
      swatch: Color(0xFF1F2937),
      background: Color(0xFF111827),
      charKey: Color(0xFF374151),
      charKeyPressed: Color(0xFF4B5563),
      actionKey: Color(0xFF1F2937),
      actionKeyPressed: Color(0xFF374151),
      activeKey: Color(0xFF6B7280),
      activePressedKey: Color(0xFF9CA3AF),
      charKeyText: Color(0xFFFFFFFF),
      actionKeyText: Color(0xB3FFFFFF),
    ),
    KeyboardTheme(
      name: '블루',
      swatch: Color(0xFF3B82F6),
      background: Color(0xFFBFDBFE),
      charKey: Color(0xFFEFF6FF),
      charKeyPressed: Color(0xFFBFDBFE),
      actionKey: Color(0xFF3B82F6),
      actionKeyPressed: Color(0xFF2563EB),
      activeKey: Color(0xFF1D4ED8),
      activePressedKey: Color(0xFF1E40AF),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xFFFFFFFF),
    ),
    KeyboardTheme(
      name: '핑크',
      swatch: Color(0xFFEC4899),
      background: Color(0xFFFBCFE8),
      charKey: Color(0xFFFFF0F7),
      charKeyPressed: Color(0xFFFBCFE8),
      actionKey: Color(0xFFEC4899),
      actionKeyPressed: Color(0xFFDB2777),
      activeKey: Color(0xFFBE185D),
      activePressedKey: Color(0xFF9D174D),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xFFFFFFFF),
    ),
    KeyboardTheme(
      name: '민트',
      swatch: Color(0xFF10B981),
      background: Color(0xFFA7F3D0),
      charKey: Color(0xFFECFDF5),
      charKeyPressed: Color(0xFFA7F3D0),
      actionKey: Color(0xFF10B981),
      actionKeyPressed: Color(0xFF059669),
      activeKey: Color(0xFF047857),
      activePressedKey: Color(0xFF065F46),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xFFFFFFFF),
    ),
    KeyboardTheme(
      name: '퍼플',
      swatch: Color(0xFF8B5CF6),
      background: Color(0xFFDDD6FE),
      charKey: Color(0xFFF5F3FF),
      charKeyPressed: Color(0xFFDDD6FE),
      actionKey: Color(0xFF8B5CF6),
      actionKeyPressed: Color(0xFF7C3AED),
      activeKey: Color(0xFF6D28D9),
      activePressedKey: Color(0xFF5B21B6),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xFFFFFFFF),
    ),
  ];
}

// ── Emoji data ────────────────────────────────────────────────────────────────

const _emojiTabIcons = ['😊', '👋', '❤️', '🐾', '🍔'];
const _emojiData = [
  // Smileys
  [
    '😀','😃','😄','😁','😆','😅','😂','🤣','🥲','🥹','😊','😇','🙂','🙃',
    '😉','😌','😍','🥰','😘','😗','😙','😚','😋','😛','😝','😜','🤪','🤨',
    '🧐','🤓','😎','🥸','🤩','🥳','😏','😒','😞','😔','😟','😕','🫤','😣',
    '😖','😫','😩','🥺','😢','😭','😤','😠','😡','🤬','🤯','😳','🥵','🥶',
    '😱','😨','😰','😥','😓','🤔','🤭','😶','😐','😑','😬','🙄','😯','😦',
    '😧','😮','😲','🥱','😴','🤤','😷','🤒','🤕','🤢','🤮','🤧',
  ],
  // Hands & people
  [
    '👋','🤚','🖐','✋','🖖','👌','🤌','🤏','✌️','🤞','🤟','🤘','🤙','👈',
    '👉','👆','👇','☝️','👍','👎','✊','👊','🤛','🤜','👏','🙌','🫶','👐',
    '🤲','🤝','🙏','💪','🦾','👀','👅','👄','💋','🧑','👦','👧','👨','👩',
    '🧓','👴','👵','👶','🧒','🧑‍💻','🧑‍🎤','🧑‍🍳','🧑‍🎨','🧑‍🚀',
  ],
  // Hearts & symbols
  [
    '❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❤️‍🔥','💕','💞',
    '💓','💗','💖','💘','💝','💟','🔥','⭐','🌟','💫','✨','🎉','🎊','🎈',
    '🎁','🎀','🏆','🥇','💯','💢','💥','💦','💨','💬','💭','💤','🔔','🎵',
    '🎶','🎤','📱','💻','⌚','📷','🎮','🎲','🎯','👾','🕹️','🎧','📣','🔑',
  ],
  // Nature & animals
  [
    '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸',
    '🐵','🙈','🙉','🙊','🐔','🐧','🐦','🦆','🦅','🦉','🦇','🐺','🐗','🐴',
    '🦄','🐝','🦋','🐌','🐞','🦗','🌸','🌹','🌺','🌻','🌼','🌷','🍀','🌿',
    '🍃','🌱','🌲','🌳','🌴','🍄','🌊','🌈','🌙','☀️','⛅','❄️','🌧','⛈',
  ],
  // Food & drink
  [
    '🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍒','🍑','🥝','🍅','🥑',
    '🍆','🥦','🥕','🌽','🍔','🍟','🍕','🌭','🌮','🌯','🥙','🥚','🍳','🥞',
    '🧇','🥓','🍖','🍗','🧀','🍱','🍣','🍜','🍝','🍛','🍲','🥗','🍿','🍦',
    '🍧','🍨','🍰','🎂','🍭','🍬','🍫','🍩','🍪','☕','🍵','🧋','🥤','🍺',
    '🍻','🥂','🍷','🧃','🥛','🍼',
  ],
];

// ── Keyboard ───────────────────────────────────────────────────────────────────

enum KeyboardMode { english, korean, number, emoji }

class KeyboardView extends StatefulWidget {
  /// 제공하면 MethodChannel 대신 이 컨트롤러에 직접 텍스트를 기록합니다 (프리뷰 모드).
  final TextEditingController? previewController;

  const KeyboardView({super.key, this.previewController});

  @override
  State<KeyboardView> createState() => _KeyboardViewState();
}

class _KeyboardViewState extends State<KeyboardView> {
  KeyboardMode _mode = KeyboardMode.korean;
  KeyboardMode _modeBeforeEmoji = KeyboardMode.korean;
  bool _capsLock = false;
  final KoreanComposer _composer = KoreanComposer();

  // ── Settings ──────────────────────────────────────────────────────────────
  bool _showingSettings = false;
  bool _hapticEnabled = true;
  bool _soundEnabled = false;
  int _themeIndex = 0;
  // 키보드 높이 (280~440dp)
  int _keyboardHeight = 350;
  // 숫자행 항상 표시
  bool _showNumberRow = false;
  // 한영 전환 방식: 0=탭, 1=길게누름
  int _langToggleMode = 0;
  // 진동 강도: 0=약, 1=중, 2=강
  int _hapticLevel = 1;
  // 소리 볼륨 (0.0~1.0)
  double _soundVolume = 0.5;
  // 소리 테마: 0=기본, 1=타자기, 2=부드러움
  int _soundTheme = 0;

  // ── Clipboard ─────────────────────────────────────────────────────────────
  List<String> _clipboardHistory = [];
  bool _showingClipboard = false;

  // ── Emoji ─────────────────────────────────────────────────────────────────
  int _emojiCategoryIndex = 0;

  // ── 쌍자음 ────────────────────────────────────────────────────────────────
  bool _ssangMode = false;
  static const Map<String, String> _ssangMap = {
    'ㄱ': 'ㄲ', 'ㄷ': 'ㄸ', 'ㅂ': 'ㅃ', 'ㅅ': 'ㅆ', 'ㅈ': 'ㅉ',
  };

  // ── Preview mode ──────────────────────────────────────────────────────────
  bool get _isPreview => widget.previewController != null;
  String _previewComposing = '';

  String get _previewBase {
    final ctrl = widget.previewController!;
    if (_previewComposing.isNotEmpty && ctrl.text.endsWith(_previewComposing)) {
      return ctrl.text.substring(0, ctrl.text.length - _previewComposing.length);
    }
    return ctrl.text;
  }

  void _previewUpdate(String base, String composing) {
    _previewComposing = composing;
    final ctrl = widget.previewController!;
    ctrl.text = base + composing;
    ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
  }

  KeyboardTheme get _theme => KeyboardTheme.presets[_themeIndex];

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'reset') {
      _composer.reset();
      _mode = KeyboardMode.korean;
      _modeBeforeEmoji = KeyboardMode.korean;
      _lastKey = null;
      _tapCount = 0;
      _ssangMode = false;
      setState(() {});
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final height = prefs.getInt('keyboardHeight') ?? 350;
      setState(() {
        _hapticEnabled = prefs.getBool('haptic') ?? true;
        _soundEnabled = prefs.getBool('sound') ?? false;
        _themeIndex = prefs.getInt('theme') ?? 0;
        _keyboardHeight = height;
        _showNumberRow = prefs.getBool('showNumberRow') ?? false;
        _langToggleMode = prefs.getInt('langToggleMode') ?? 0;
        _hapticLevel = prefs.getInt('hapticLevel') ?? 1;
        _soundVolume = prefs.getDouble('soundVolume') ?? 0.5;
        _soundTheme = prefs.getInt('soundTheme') ?? 0;
        _clipboardHistory = prefs.getStringList('clipboardHistory') ?? [];
      });
      // 네이티브 뷰 높이 동기화 (키보드가 앱 화면 가리는 문제 방지)
      if (!_isPreview) {
        _channel.invokeMethod('updateKeyboardHeight', {'height': height});
      }
    } catch (_) {
      // 프리뷰 모드 등 플러그인 미등록 환경에서는 기본값 사용
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  void _triggerFeedback() {
    if (_isPreview) return;
    if (_hapticEnabled) _channel.invokeMethod('vibrate', {'level': _hapticLevel});
    if (_soundEnabled) _channel.invokeMethod('playKeySound', {
      'volume': _soundVolume,
      'theme': _soundTheme,
    });
  }

  // ── Clipboard ─────────────────────────────────────────────────────────────

  Future<void> _openClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        _addToClipboardHistory(data.text!);
      }
    } catch (_) {}
    setState(() {
      _showingClipboard = true;
      _showingSettings = false;
    });
  }

  void _addToClipboardHistory(String text) {
    if (text.length > 300) return; // 너무 긴 텍스트 제외
    _clipboardHistory.remove(text); // 중복 제거 후 최신으로 추가
    _clipboardHistory.add(text);
    if (_clipboardHistory.length > 20) _clipboardHistory.removeAt(0);
    _saveClipboardHistory();
  }

  Future<void> _saveClipboardHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('clipboardHistory', _clipboardHistory);
    } catch (_) {}
  }

  Future<void> _clearClipboardHistory() async {
    setState(() => _clipboardHistory.clear());
    await _saveClipboardHistory();
  }

  // ── Tap detection ─────────────────────────────────────────────────────────
  String? _lastKey;
  int _lastKeyMs = 0;
  int _tapCount = 0;
  static const _doubleTapMs = 500;

  /// 숫자 모드 더블탭 업그레이드
  static const Map<String, String> _numberDoubleMap = {
    '-': '_',
    '+': '!',
    '=': '?',
  };

  /// 2번 탭 → 획 추가 (격음/장음)
  static const Map<String, String> _keyUpgrade = {
    'ㅏ': 'ㅑ', 'ㅓ': 'ㅕ', 'ㅗ': 'ㅛ', 'ㅜ': 'ㅠ', 'ㅐ': 'ㅒ', 'ㅔ': 'ㅖ',
    'ㄱ': 'ㅋ', 'ㄷ': 'ㅌ', 'ㅂ': 'ㅍ', 'ㅅ': 'ㅆ', 'ㅇ': 'ㅎ', 'ㅈ': 'ㅊ',
  };

  /// 3번 탭 → 된소리
  static const Map<String, String> _keyUpgrade3 = {
    'ㄱ': 'ㄲ',
    'ㄷ': 'ㄸ',
    'ㅂ': 'ㅃ',
    'ㅈ': 'ㅉ',
  };

  // ── Layout definitions ────────────────────────────────────────────────────

  static const _numberRow = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

  static const _numberRows = [
    ['1', '2', '3', '*', '+', '/', '('],
    ['4', '5', '6', '#', '-', '=', ')'],
    ['7', '8', '9', '0', '@', '.', '~'],
  ];

  static const _koreanRows = [
    ['ㄱ', 'ㄴ', 'ㄷ', 'ㅏ', 'ㅓ'],
    ['ㄹ', 'ㅁ', 'ㅂ', 'ㅡ', 'ㅣ'],
    ['ㅅ', 'ㅇ', 'ㅈ', 'ㅗ', 'ㅜ'],
  ];

  static const _englishRows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', "'"],
    ['@', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '.,', '?'],
  ];

  // ── IME communication ─────────────────────────────────────────────────────

  Future<void> _commitText(String text) async {
    if (text.isEmpty) return;
    if (_isPreview) {
      setState(() => _previewUpdate(_previewBase + text, ''));
    } else {
      await _channel.invokeMethod('commitText', {'text': text});
    }
  }

  Future<void> _setComposing(String text) async {
    if (_isPreview) {
      setState(() => _previewUpdate(_previewBase, text));
    } else {
      await _channel.invokeMethod('setComposingText', {'text': text});
    }
  }

  Future<void> _replaceComposing(String text) async {
    if (_isPreview) {
      setState(() => _previewUpdate(_previewBase, text));
    } else {
      await _channel.invokeMethod('replaceComposing', {'text': text});
    }
  }

  Future<void> _deleteBack() async {
    if (_isPreview) {
      setState(() {
        if (_previewComposing.isNotEmpty) {
          _previewUpdate(_previewBase, '');
        } else {
          final t = widget.previewController!.text;
          if (t.isNotEmpty) _previewUpdate(t.substring(0, t.length - 1), '');
        }
      });
    } else {
      await _channel.invokeMethod('deleteSurroundingText');
    }
  }

  Future<void> _sendAction() async {
    // 조합 중인 한글 먼저 커밋
    String koreanText = '';
    if (_mode == KeyboardMode.korean) {
      koreanText = _composer.commitAll();
      if (koreanText.isNotEmpty && !_isPreview) {
        await _channel.invokeMethod('switchModeCommit', {'text': koreanText});
      }
    }
    _lastKey = null;
    _tapCount = 0;
    if (_isPreview) {
      setState(() => _previewUpdate('$_previewBase$koreanText\n', ''));
    } else {
      await _channel.invokeMethod('performEditorAction');
    }
  }

  // ── Key handlers ──────────────────────────────────────────────────────────

  void _onKey(String key) {
    if (_mode == KeyboardMode.korean) {
      String actualKey = key;
      if (_ssangMode && _ssangMap.containsKey(key)) {
        actualKey = _ssangMap[key]!;
        _ssangMode = false; // 한 글자 입력 후 자동 해제 → 쌍 버튼 UI 갱신
        setState(() {});   // 쌍 버튼 색상 변경만을 위한 rebuild
      }
      _handleKorean(actualKey);
    } else if (key == '.,') {
      _handleDotComma();
    } else if (_mode == KeyboardMode.number && _numberDoubleMap.containsKey(key)) {
      _handleNumberDouble(key);
    } else {
      _lastKey = null;
      final toSend = (_mode == KeyboardMode.english && _capsLock)
          ? key.toUpperCase()
          : key;
      _commitText(toSend);
    }
  }

  Future<void> _handleNumberDouble(String key) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isDouble = _lastKey == key && (nowMs - _lastKeyMs) < _doubleTapMs;
    _lastKey = key;
    _lastKeyMs = nowMs;

    if (isDouble) {
      // 두 번째 탭: 앞 문자 지우고 업그레이드 문자 입력
      await _deleteBack();
      await _commitText(_numberDoubleMap[key]!);
    } else {
      await _commitText(key);
    }
  }

  Future<void> _handleDotComma() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isDouble = _lastKey == '.,' && (nowMs - _lastKeyMs) < _doubleTapMs;
    _lastKey = '.,';
    _lastKeyMs = nowMs;

    if (isDouble) {
      // 두 번째 탭: 앞의 '.'를 지우고 ','로 교체
      await _deleteBack();
      await _commitText(',');
    } else {
      await _commitText('.');
    }
  }

  Future<void> _handleKorean(String key) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isRepeat = key == _lastKey && (nowMs - _lastKeyMs) < _doubleTapMs;

    if (isRepeat) {
      _tapCount++;
    } else {
      _tapCount = 1;
    }
    _lastKey = key;
    _lastKeyMs = nowMs;

    // ── 3번 탭: 된소리 (ㅈ→ㅉ) ────────────────────────────────────────────
    if (_tapCount == 3 && _keyUpgrade3.containsKey(key)) {
      final upgraded3 = _keyUpgrade3[key]!;
      final replaced = _composer.replaceCurrentConsonant(upgraded3);
      if (replaced) {
        await _replaceComposing(_composer.composing);
        return;
      }
      // 받침 위치에서는 ㅉ 불가 → 독립 자음으로 입력
      _composer.input(upgraded3);
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        await _commitText(pending);
        _composer.clearPending();
      }
      await _setComposing(_composer.composing);
      return;
    }

    // ── 2번 탭: 획 추가 (ㅈ→ㅊ 등) ──────────────────────────────────────
    if (_tapCount == 2 && _keyUpgrade.containsKey(key)) {
      final upgraded = _keyUpgrade[key]!;
      bool replaced = false;
      if (KoreanComposer.isVowel(key)) {
        replaced = _composer.replaceCurrentVowel(upgraded);
      } else {
        replaced = _composer.replaceCurrentConsonant(upgraded);
      }
      if (replaced) {
        await _replaceComposing(_composer.composing);
        return;
      }
      _composer.input(upgraded);
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        await _commitText(pending);
        _composer.clearPending();
      }
      await _setComposing(_composer.composing);
      return;
    }

    // ── 1번 탭 (또는 4번 이상): 일반 입력 ────────────────────────────────
    _composer.input(key);
    final pending = _composer.pending;
    if (pending.isNotEmpty) {
      await _commitText(pending);
      _composer.clearPending();
    }
    await _setComposing(_composer.composing);
    // 키보드 UI 자체는 변하지 않으므로 setState 불필요
  }

  Future<void> _onDelete() async {
    if (_mode == KeyboardMode.korean) {
      final hadComposing = _composer.backspace();
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        await _commitText(pending);
        _composer.clearPending();
      }
      await _setComposing(_composer.composing);
      if (!hadComposing) await _deleteBack();
      // 삭제 시 키보드 UI 자체는 변하지 않으므로 setState 불필요
    } else {
      await _deleteBack();
    }
  }

  Future<void> _commitKoreanAndSwitch(void Function() switchFn) async {
    if (_mode == KeyboardMode.korean) {
      final text = _composer.commitAll();
      if (_isPreview) {
        setState(() => _previewUpdate(_previewBase + text, ''));
      } else {
        // 원자적으로 composing commit + 종료 (두 단계 비동기 타이밍 문제 방지)
        await _channel.invokeMethod('switchModeCommit', {'text': text});
      }
    }
    _ssangMode = false;
    _lastKey = null;  // 더블탭 상태 초기화 (모드 전환 후 오입력 방지)
    _tapCount = 0;
    setState(switchFn);
  }

  void _onRotate() {
    _commitKoreanAndSwitch(() {
      switch (_mode) {
        case KeyboardMode.number:
          _mode = KeyboardMode.korean;
        case KeyboardMode.korean:
          _mode = KeyboardMode.english;
        case KeyboardMode.english:
          _mode = KeyboardMode.number;
        case KeyboardMode.emoji:
          _mode = _modeBeforeEmoji;
      }
    });
  }

  void _onLangToggle() {
    if (_mode == KeyboardMode.emoji) {
      _lastKey = null;
      _tapCount = 0;
      setState(() => _mode = _modeBeforeEmoji);
      return;
    }
    _commitKoreanAndSwitch(() {
      _mode = _mode == KeyboardMode.korean
          ? KeyboardMode.english
          : KeyboardMode.korean;
    });
  }

  void _onCaps() => setState(() => _capsLock = !_capsLock);

  /// 쌍 버튼: 현재 조합 중인 자음이 있으면 즉시 쌍자음으로 업그레이드,
  /// 없으면 기존 모드 토글 (다음 자음을 쌍자음으로 입력).
  Future<void> _onSsang() async {
    final cur = _composer.currentConsonant;
    if (cur.isNotEmpty && _ssangMap.containsKey(cur)) {
      final doubled = _ssangMap[cur]!;
      if (_composer.replaceCurrentConsonant(doubled)) {
        _lastKey = null;
        _tapCount = 0;
        await _replaceComposing(_composer.composing);
        return; // 조합 텍스트만 변경 → 키보드 UI 리빌드 불필요
      }
    }
    setState(() => _ssangMode = !_ssangMode);
  }

  void _toggleEmoji() {
    if (_mode == KeyboardMode.emoji) {
      _lastKey = null;
      _tapCount = 0;
      setState(() => _mode = _modeBeforeEmoji);
    } else {
      _commitKoreanAndSwitch(() {
        _modeBeforeEmoji = _mode;
        _mode = KeyboardMode.emoji;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // 네비게이션 바 높이: edge-to-edge 기기에서 키보드 하단 키가 가려지지 않도록
    final navBottom = MediaQuery.of(context).viewPadding.bottom;
    return SizedBox(
      height: _keyboardHeight.toDouble(),
      child: Container(
        color: _theme.background,
        child: Column(
          children: [
            // ── 상단 툴바: 이모지 · 클립보드 · 설정 ──────────────────────
            if (!_showingSettings && !_showingClipboard) _buildToolbar(),
            Expanded(
              child: _showingSettings
                  ? _buildSettingsPanel()
                  : _showingClipboard
                      ? _buildClipboardPanel()
                      : Column(
                          children: [
                            if (_mode == KeyboardMode.emoji)
                              Expanded(child: _buildEmojiGrid())
                            else
                              ..._buildMainRows(),
                            _buildBottomRow(),
                          ],
                        ),
            ),
            // 네비게이션 바 영역 (키가 가려지지 않도록 여백 확보)
            if (navBottom > 0) SizedBox(height: navBottom),
          ],
        ),
      ),
    );
  }

  // ── 상단 툴바 ─────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    final isEmoji = _mode == KeyboardMode.emoji;
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          // 이모지 토글
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleEmoji,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                isEmoji ? '⌨️' : '😊',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
          // 클립보드
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openClipboard,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                Icons.content_paste_rounded,
                size: 16,
                color: _theme.charKeyText.withOpacity(0.5),
              ),
            ),
          ),
          const Spacer(),
          // 설정
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _showingSettings = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Icon(Icons.settings, size: 17, color: _theme.charKeyText.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Emoji panel ───────────────────────────────────────────────────────────

  Widget _buildEmojiGrid() {
    return Column(
      children: [
        // Category tabs
        SizedBox(
          height: 38,
          child: Row(
            children: List.generate(_emojiTabIcons.length, (i) {
              final selected = i == _emojiCategoryIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _emojiCategoryIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: selected
                          ? _theme.charKey.withOpacity(0.5)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: selected
                              ? _theme.actionKey
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _emojiTabIcons[i],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // Emoji grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
            ),
            itemCount: _emojiData[_emojiCategoryIndex].length,
            itemBuilder: (_, i) {
              final emoji = _emojiData[_emojiCategoryIndex][i];
              return GestureDetector(
                onTap: () {
                  _triggerFeedback();
                  _channel.invokeMethod('commitText', {'text': emoji});
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Clipboard panel ───────────────────────────────────────────────────────

  Widget _buildClipboardPanel() {
    final reversed = _clipboardHistory.reversed.toList();
    return Column(
      children: [
        // Header
        Container(
          height: 38,
          color: _theme.actionKey.withOpacity(0.15),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showingClipboard = false),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_back, size: 18, color: _theme.charKeyText),
                ),
              ),
              Text(
                '클립보드',
                style: TextStyle(
                  color: _theme.charKeyText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _clearClipboardHistory,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: _theme.charKeyText.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        // History list
        Expanded(
          child: reversed.isEmpty
              ? Center(
                  child: Text(
                    '클립보드 기록 없음',
                    style: TextStyle(
                      color: _theme.charKeyText.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: reversed.length,
                  itemBuilder: (_, i) {
                    final item = reversed[i];
                    return GestureDetector(
                      onTap: () {
                        _commitText(item);
                        _triggerFeedback();
                        setState(() => _showingClipboard = false);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: _theme.charKey,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _theme.charKeyText, fontSize: 13),
                        ),
                      ),
                    );
                  },
                ),
        ),
        _buildBottomRow(),
      ],
    );
  }

  // ── Settings panel ────────────────────────────────────────────────────────

  Widget _settingLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: _theme.charKeyText.withOpacity(0.55)),
      ),
    );
  }

  Widget _segmentButton(String label, int value, int current, void Function(int) onTap) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _theme.actionKey : _theme.charKey,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _theme.actionKey.withOpacity(0.4), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? _theme.actionKeyText : _theme.charKeyText,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      size: 20, color: _theme.actionKeyText),
                  onPressed: () => setState(() => _showingSettings = false),
                ),
                Text('설정',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _theme.charKeyText)),
              ],
            ),
          ),

          // ── 키보드 스킨 ───────────────────────────────────────────────────
          _settingLabel('키보드 스킨'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(KeyboardTheme.presets.length, (i) {
                final t = KeyboardTheme.presets[i];
                final selected = i == _themeIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _themeIndex = i);
                    _saveInt('theme', i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t.swatch,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.black54 : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(selected ? 0.3 : 0.1),
                          blurRadius: selected ? 6 : 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 8),

          // ── 키보드 높이 ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('키보드 높이',
                    style: TextStyle(fontSize: 15, color: _theme.charKeyText)),
                Text('$_keyboardHeight dp',
                    style: TextStyle(
                        fontSize: 13,
                        color: _theme.charKeyText.withOpacity(0.6))),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _theme.actionKey,
              thumbColor: _theme.actionKey,
              inactiveTrackColor: _theme.actionKey.withOpacity(0.2),
              overlayColor: _theme.actionKey.withOpacity(0.1),
            ),
            child: Slider(
              value: _keyboardHeight.toDouble(),
              min: 280,
              max: 440,
              divisions: 8,
              onChanged: (v) {
                setState(() => _keyboardHeight = v.round());
                _saveInt('keyboardHeight', v.round());
                if (!_isPreview) {
                  _channel.invokeMethod('updateKeyboardHeight', {'height': v.round()});
                }
              },
            ),
          ),
          const Divider(height: 8),

          // ── 숫자행 표시 ───────────────────────────────────────────────────
          SwitchListTile(
            dense: true,
            title: Text('숫자행 항상 표시',
                style: TextStyle(fontSize: 15, color: _theme.charKeyText)),
            activeColor: _theme.actionKey,
            value: _showNumberRow,
            onChanged: (v) {
              setState(() => _showNumberRow = v);
              _saveBool('showNumberRow', v);
            },
          ),
          const Divider(height: 8),

          // ── 한영 전환 방식 ────────────────────────────────────────────────
          _settingLabel('한영 전환 방식'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _segmentButton('탭', 0, _langToggleMode, (v) {
                  setState(() => _langToggleMode = v);
                  _saveInt('langToggleMode', v);
                }),
                const SizedBox(width: 8),
                _segmentButton('길게 누름', 1, _langToggleMode, (v) {
                  setState(() => _langToggleMode = v);
                  _saveInt('langToggleMode', v);
                }),
              ],
            ),
          ),
          const Divider(height: 8),

          // ── 진동 ──────────────────────────────────────────────────────────
          SwitchListTile(
            dense: true,
            title: Text('진동',
                style: TextStyle(fontSize: 15, color: _theme.charKeyText)),
            activeColor: _theme.actionKey,
            value: _hapticEnabled,
            onChanged: (v) {
              setState(() => _hapticEnabled = v);
              _saveBool('haptic', v);
            },
          ),
          if (_hapticEnabled) ...[
            _settingLabel('진동 강도'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _segmentButton('약', 0, _hapticLevel, (v) {
                    setState(() => _hapticLevel = v);
                    _saveInt('hapticLevel', v);
                  }),
                  const SizedBox(width: 8),
                  _segmentButton('중', 1, _hapticLevel, (v) {
                    setState(() => _hapticLevel = v);
                    _saveInt('hapticLevel', v);
                  }),
                  const SizedBox(width: 8),
                  _segmentButton('강', 2, _hapticLevel, (v) {
                    setState(() => _hapticLevel = v);
                    _saveInt('hapticLevel', v);
                  }),
                ],
              ),
            ),
          ],
          const Divider(height: 8),

          // ── 소리 ──────────────────────────────────────────────────────────
          SwitchListTile(
            dense: true,
            title: Text('키 클릭 소리',
                style: TextStyle(fontSize: 15, color: _theme.charKeyText)),
            activeColor: _theme.actionKey,
            value: _soundEnabled,
            onChanged: (v) {
              setState(() => _soundEnabled = v);
              _saveBool('sound', v);
            },
          ),
          if (_soundEnabled) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('볼륨',
                      style: TextStyle(fontSize: 15, color: _theme.charKeyText)),
                  Text('${(_soundVolume * 100).round()}%',
                      style: TextStyle(
                          fontSize: 13,
                          color: _theme.charKeyText.withOpacity(0.6))),
                ],
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _theme.actionKey,
                thumbColor: _theme.actionKey,
                inactiveTrackColor: _theme.actionKey.withOpacity(0.2),
                overlayColor: _theme.actionKey.withOpacity(0.1),
              ),
              child: Slider(
                value: _soundVolume,
                onChanged: (v) {
                  setState(() => _soundVolume = v);
                  _saveDouble('soundVolume', v);
                },
              ),
            ),
            _settingLabel('소리 테마'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _segmentButton('기본', 0, _soundTheme, (v) {
                    setState(() => _soundTheme = v);
                    _saveInt('soundTheme', v);
                  }),
                  const SizedBox(width: 8),
                  _segmentButton('타자기', 1, _soundTheme, (v) {
                    setState(() => _soundTheme = v);
                    _saveInt('soundTheme', v);
                  }),
                  const SizedBox(width: 8),
                  _segmentButton('부드러움', 2, _soundTheme, (v) {
                    setState(() => _soundTheme = v);
                    _saveInt('soundTheme', v);
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Keyboard rows ─────────────────────────────────────────────────────────

  List<Widget> _buildMainRows() {
    final rows = switch (_mode) {
      KeyboardMode.number => _numberRows,
      KeyboardMode.korean => _koreanRows,
      KeyboardMode.english => _englishRows,
      KeyboardMode.emoji => _koreanRows,
    };
    return [
      // 숫자행 (숫자 모드에선 중복이므로 제외)
      if (_showNumberRow && _mode != KeyboardMode.number)
        Expanded(
          child: _KeyRow(
            keys: _numberRow,
            caps: false,
            bold: false,
            onKey: _onKey,
            onKeyDown: _triggerFeedback,
            theme: _theme,
            showPopup: _isPreview,
            animate: true,
          ),
        ),
      ...rows.map((row) => Expanded(
            child: _KeyRow(
              keys: row,
              caps: _capsLock && _mode == KeyboardMode.english,
              bold: _mode == KeyboardMode.korean,
              onKey: _onKey,
              onKeyDown: _triggerFeedback,
              theme: _theme,
              showPopup: _isPreview,
              animate: true,
            ),
          )),
    ];
  }

  Widget _buildBottomRow() {
    final isKorean = _mode == KeyboardMode.korean;
    final isEnglish = _mode == KeyboardMode.english;

    final modeLabel = switch (_mode) {
      KeyboardMode.korean => '한',
      KeyboardMode.english => 'EN',
      KeyboardMode.number => '123',
      KeyboardMode.emoji => '한',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          // 한/영/숫자 모드 순환 (탭 모드(0) vs 길게누름 모드(1))
          _ActionKey(
            onTap: _langToggleMode == 0 ? _onRotate : () {},
            onLongPress: _langToggleMode == 1 ? _onRotate : null,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 4,
            child: Text(
              modeLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _theme.actionKeyText,
              ),
            ),
          ),
          // 쌍자음(한국어) / 대문자(영어) / 빈칸(그 외)
          _ActionKey(
            onTap: isKorean
                ? _onSsang
                : isEnglish
                    ? _onCaps
                    : () {},
            onTapDown: (isKorean || isEnglish) ? _triggerFeedback : () {},
            theme: _theme,
            flex: 3,
            active: isKorean ? _ssangMode : isEnglish ? _capsLock : false,
            animate: true,
            child: isKorean
                ? Text('쌍',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _theme.actionKeyText))
                : isEnglish
                    ? Icon(Icons.keyboard_capslock,
                        size: 20, color: _theme.actionKeyText)
                    : const SizedBox(),
          ),
          _ActionKey(
            onTap: () => _onKey(' '),
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 5,
            animate: true,
            child: const Text(' ', style: TextStyle(fontSize: 14)),
          ),
          _ActionKey(
            onTap: _sendAction,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 3,
            animate: true,
            child: Icon(Icons.keyboard_return,
                size: 22, color: _theme.actionKeyText),
          ),
          _ActionKey(
            onTap: _onDelete,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 2,
            repeatOnHold: true,
            animate: true,
            child: Icon(Icons.backspace_outlined,
                size: 20, color: _theme.actionKeyText),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _KeyRow extends StatelessWidget {
  final List<String> keys;
  final bool caps;
  final bool bold;
  final void Function(String) onKey;
  final VoidCallback onKeyDown;
  final KeyboardTheme theme;
  final bool showPopup;
  final bool animate;

  const _KeyRow({
    required this.keys,
    required this.caps,
    required this.onKey,
    required this.onKeyDown,
    required this.theme,
    this.bold = false,
    this.showPopup = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    // 키가 많을수록 가로 패딩 축소 (영문 10개 → 1px, 한글 5개 → 3px)
    final keyPad = keys.length >= 8 ? 1.0 : 3.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        children: keys
            .map((k) => Expanded(
                  child: _CharKey(
                    label: caps ? k.toUpperCase() : k,
                    onTap: () => onKey(k),
                    onTapDown: onKeyDown,
                    theme: theme,
                    bold: bold,
                    horizontalPad: keyPad,
                    showPopup: showPopup,
                    animate: animate,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _CharKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final KeyboardTheme theme;
  final bool bold;
  final double horizontalPad;
  final bool showPopup;
  final bool animate;

  const _CharKey({
    required this.label,
    required this.onTap,
    required this.onTapDown,
    required this.theme,
    this.bold = false,
    this.horizontalPad = 3,
    this.showPopup = false,
    this.animate = true,
  });

  @override
  State<_CharKey> createState() => _CharKeyState();
}

class _CharKeyState extends State<_CharKey>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _popupEntry;
  late final AnimationController _ctrl;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 35),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _curve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _curve.dispose();
    _ctrl.dispose();
    _popupEntry?.remove();
    super.dispose();
  }

  void _showPopup() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final overlay = Overlay.of(context);
    final pos = box.localToGlobal(Offset.zero);
    final sz = box.size;
    final popupTop = (pos.dy - 66).clamp(4.0, double.infinity);
    _popupEntry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: Positioned(
        left: pos.dx - 6,
        top: popupTop,
        width: sz.width + 12,
        height: 62,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.charKey,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 28,
                color: widget.theme.charKeyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        ),
      ),
    );
    overlay.insert(_popupEntry!);
  }

  void _hidePopup() {
    _popupEntry?.remove();
    _popupEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPad),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          widget.onTapDown();
          widget.onTap();
          if (widget.animate) _ctrl.forward();
          if (widget.showPopup) _showPopup();
        },
        onTapUp: (_) {
          if (widget.animate) _ctrl.reverse();
          if (widget.showPopup) _hidePopup();
        },
        onTapCancel: () {
          if (widget.animate) _ctrl.reverse();
          if (widget.showPopup) _hidePopup();
        },
        child: RepaintBoundary( // 각 키 애니메이션이 키보드 전체를 repaint하지 않도록 격리
          child: AnimatedBuilder(
          animation: _curve,
          builder: (ctx, child) {
            final t = _curve.value; // may go slightly < 0 during easeOutBack
            final tC = t.clamp(0.0, 1.0);
            // scale < 1 when pressed, bounces slightly above 1 on release
            final scale = 1.0 - 0.10 * t;
            return Transform(
              transform: Matrix4.identity()
                ..translate(0.0, 4.0 * tC)
                ..scale(scale),
              alignment: Alignment.center,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    widget.theme.charKey,
                    widget.theme.charKeyPressed,
                    tC,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.38 * (1 - tC)),
                      offset: Offset(0, (1 - tC) * 4),
                      blurRadius: (1 - tC) * 4,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: child,
              ),
            );
          },
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 18,
              color: widget.theme.charKeyText,
              fontWeight: widget.bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        ),  // RepaintBoundary 닫기
      ),
    );
  }
}

class _ActionKey extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final KeyboardTheme theme;
  final int flex;
  final bool active;
  final bool repeatOnHold;
  final VoidCallback? onLongPress;
  final bool animate;

  const _ActionKey({
    required this.child,
    required this.onTap,
    required this.onTapDown,
    required this.theme,
    this.flex = 1,
    this.active = false,
    this.repeatOnHold = false,
    this.onLongPress,
    this.animate = true,
  });

  @override
  State<_ActionKey> createState() => _ActionKeyState();
}

class _ActionKeyState extends State<_ActionKey>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _repeatFired = false; // repeat이 실제로 발동됐는지 추적
  Timer? _repeatTimer;
  late final AnimationController _ctrl;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 35),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _curve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _curve.dispose();
    _ctrl.dispose();
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _startRepeat() {
    if (_repeatFired) return;
    _repeatFired = true;
    widget.onTap();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) {
        _repeatTimer?.cancel();
        return;
      }
      widget.onTapDown();
      widget.onTap();
    });
  }

  void _cancelRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  Color _bgColor(double tC) {
    final base =
        widget.active ? widget.theme.activeKey : widget.theme.actionKey;
    final pressed = widget.active
        ? widget.theme.activePressedKey
        : widget.theme.actionKeyPressed;
    return Color.lerp(base, pressed, tC)!;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            widget.onTapDown();
            setState(() => _pressed = true);
            if (widget.animate) _ctrl.forward();
            if (widget.repeatOnHold) _repeatFired = false;
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            if (widget.animate) _ctrl.reverse();
            if (widget.repeatOnHold) {
              final didRepeat = _repeatFired;
              _cancelRepeat();
              if (!didRepeat) widget.onTap();
            } else {
              widget.onTap();
            }
          },
          onTapCancel: () {
            setState(() => _pressed = false);
            if (widget.animate) _ctrl.reverse();
            if (widget.repeatOnHold) _cancelRepeat();
          },
          // 길게누름 지원 (repeatOnHold: 빠른 반복 삭제 / onLongPress: 커스텀 액션)
          onLongPress: widget.repeatOnHold ? _startRepeat
              : (widget.onLongPress != null ? () {
                  widget.onTapDown();
                  widget.onLongPress!();
                } : null),
          onLongPressEnd: (widget.repeatOnHold || widget.onLongPress != null) ? (_) {
            setState(() => _pressed = false);
            _ctrl.reverse();
            if (widget.repeatOnHold) _cancelRepeat();
          } : null,
          child: RepaintBoundary( // 액션키 애니메이션 격리
            child: AnimatedBuilder(
              animation: _curve,
              builder: (ctx, child) {
                final t = _curve.value;
                final tC = t.clamp(0.0, 1.0);
                return Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 4.0 * tC)
                    ..scale(1.0 - 0.09 * t),
                  alignment: Alignment.center,
                  child: Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: _bgColor(tC),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.38 * (1 - tC)),
                          offset: Offset(0, (1 - tC) * 4),
                          blurRadius: (1 - tC) * 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: child,
                  ),
                );
              },
              child: DefaultTextStyle(
                style:
                    TextStyle(color: widget.theme.actionKeyText, fontSize: 14),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
