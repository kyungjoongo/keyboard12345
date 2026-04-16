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

enum KeyboardMode { english, korean, number, emoji, symbol }

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

  // ── IME Action (앱이 요청하는 엔터키 동작) ─────────────────────────────
  // 0=NONE(줄바꿈), 1=NONE, 2=GO, 3=SEARCH, 4=SEND, 5=NEXT, 6=DONE
  int _imeAction = 0;

  // ── Settings ──────────────────────────────────────────────────────────────
  bool _showingSettings = false;
  bool _hapticEnabled = false;
  bool _soundEnabled = false;
  int _themeIndex = 0;

  // 키보드 높이 (280~440dp)
  int _keyboardHeight = 430;
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

  // 키보드 레이아웃: 'standard' (천지인/단모음 혼합 느낌의 기존 레이아웃), 'full' (두벌식 풀 키보드)
  String _layoutType = 'standard';
  // 일반 레이아웃 연타 업그레이드(2/3탭 획/된소리)
  bool _multiTapUpgradeEnabled = true;

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

  // ── Nav bar height (from native Android, since viewPadding.bottom = 0 in IME) ──
  double _nativeNavBarHeight = 0;

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
      if (_mode == KeyboardMode.emoji) {
        _mode = _modeBeforeEmoji;
      }
      _lastKey = null;
      _tapCount = 0;
      _ssangMode = false;
      final args = call.arguments as Map?;
      _imeAction = (args?['imeAction'] as int?) ?? 0;
      // 마지막 사용 모드 복원 (숫자/영문/한글)
      // iOS 키보드 익스텐션은 shared_preferences 미등록 환경일 수 있으므로 try-catch 처리
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedMode = prefs.getInt('lastKeyboardMode');
        if (savedMode != null && savedMode >= 0 && savedMode < KeyboardMode.values.length) {
          final m = KeyboardMode.values[savedMode];
          if (m != KeyboardMode.emoji) {
            _mode = m;
            _modeBeforeEmoji = m;
          }
        }
      } catch (_) {
        // 플러그인 미등록 환경(iOS 익스텐션 등)에서는 기본 모드 유지
      }
      setState(() {});
    } else if (call.method == 'cursorMoved') {
      // 사용자가 커서를 composing 영역 밖으로 이동 → composer만 초기화 (모드 유지)
      _composer.reset();
      _lastKey = null;
      _tapCount = 0;
    } else if (call.method == 'setNavBarHeight') {
      final h = (call.arguments as Map)['height'] as int? ?? 0;
      setState(() => _nativeNavBarHeight = h.toDouble());
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final height = prefs.getInt('keyboardHeight') ?? 430;
      final savedMode = prefs.getInt('lastKeyboardMode');
      setState(() {
        if (savedMode != null && savedMode >= 0 && savedMode < KeyboardMode.values.length) {
          _mode = KeyboardMode.values[savedMode];
          if (_mode == KeyboardMode.emoji) _mode = KeyboardMode.korean;
          _modeBeforeEmoji = _mode;
        }
        _hapticEnabled = prefs.getBool('haptic') ?? false;
        _soundEnabled = prefs.getBool('sound') ?? false;
        _themeIndex = prefs.getInt('theme') ?? 0;
        _keyboardHeight = height;
        _showNumberRow = prefs.getBool('showNumberRow') ?? false;
        _langToggleMode = prefs.getInt('langToggleMode') ?? 0;
        _hapticLevel = prefs.getInt('hapticLevel') ?? 1;
        _soundVolume = prefs.getDouble('soundVolume') ?? 0.5;
        _soundTheme = prefs.getInt('soundTheme') ?? 0;
        _layoutType = prefs.getString('layoutType') ?? 'standard';
        _multiTapUpgradeEnabled = prefs.getBool('multiTapUpgradeEnabled') ?? true;
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

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
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
  static const _doubleTapMs = 300;
  int _lastAnyKeyMs = 0; // 모든 키 입력 디바운스용
  static const _debounceMs = 25; // 25ms 이내 연속 터치 무시 (고스트 터치 방지)

  /// 숫자 모드 더블탭 업그레이드
  static const Map<String, String> _numberDoubleMap = {
    '-': '_',
    '+': '=',
    '!': '%',
    '?': '&',
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
    ['1', '2', '3', '!', '?', '/', '('],
    ['4', '5', '6', '#', '-', '+', ')'],
    ['7', '8', '9', '0', '@', '.', '*'],
  ];

  static const _koreanRows = [
    ['ㄱ', 'ㄴ', 'ㄷ', 'ㅏ', 'ㅓ'],
    ['ㄹ', 'ㅁ', 'ㅂ', 'ㅡ', 'ㅣ'],
    ['ㅅ', 'ㅇ', 'ㅈ', 'ㅗ', 'ㅜ'],
  ];

  static const _koreanFullRows = [
    ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'],
    ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ'],
    ['ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ'],
  ];

  static const _englishRows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', "'"],
    ['@', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '.,', '?'],
  ];

  static const _symbolRows = [
    ['!', '@', '#', '\$', '%', '^', '&', '*', '(', ')'],
    ['-', '_', '=', '+', '[', ']', '{', '}', '\\', '|'],
    ['`', '~', ';', ':', '"', "'", '<', '>', '/', '?'],
  ];

  // ── IME communication ─────────────────────────────────────────────────────

  void _commitText(String text) {
    if (text.isEmpty) return;
    if (_isPreview) {
      setState(() => _previewUpdate(_previewBase + text, ''));
    } else {
      _channel.invokeMethod('commitText', {'text': text});
    }
  }

  void _setComposing(String text) {
    if (_isPreview) {
      setState(() => _previewUpdate(_previewBase, text));
    } else {
      _channel.invokeMethod('setComposingText', {'text': text});
    }
  }

  void _replaceComposing(String text) {
    if (_isPreview) {
      setState(() => _previewUpdate(_previewBase, text));
    } else {
      _channel.invokeMethod('replaceComposing', {'text': text});
    }
  }

  void _deleteBack() {
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
      _channel.invokeMethod('deleteSurroundingText');
    }
  }

  void _sendAction() {
    // 조합 중인 한글 먼저 커밋
    String koreanText = '';
    if (_mode == KeyboardMode.korean) {
      koreanText = _composer.commitAll();
      if (koreanText.isNotEmpty && !_isPreview) {
        _channel.invokeMethod('switchModeCommit', {'text': koreanText});
      }
    }
    _lastKey = null;
    _tapCount = 0;
    if (_isPreview) {
      setState(() => _previewUpdate('$_previewBase$koreanText\n', ''));
    } else if (_imeAction == 0 || _imeAction == 1) {
      // IME_ACTION_UNSPECIFIED(0) / IME_ACTION_NONE(1): 줄바꿈
      _channel.invokeMethod('commitText', {'text': '\n'});
    } else {
      // GO(2), SEARCH(3), SEND(4), NEXT(5), DONE(6): 앱 요청 액션 수행
      _channel.invokeMethod('performEditorAction');
    }
  }

  // ── Key handlers ──────────────────────────────────────────────────────────

  void _onKey(String key) {
    // 고스트 터치 방지: 25ms 이내 연속 터치 무시
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - _lastAnyKeyMs) < _debounceMs) return;
    _lastAnyKeyMs = now;

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

  void _handleNumberDouble(String key) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isDouble = _lastKey == key && (nowMs - _lastKeyMs) < _doubleTapMs;
    _lastKey = key;
    _lastKeyMs = nowMs;

    if (isDouble) {
      // 두 번째 탭: 앞 문자 지우고 업그레이드 문자 입력
      _deleteBack();
      _commitText(_numberDoubleMap[key]!);
    } else {
      _commitText(key);
    }
  }

  void _handleDotComma() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isDouble = _lastKey == '.,' && (nowMs - _lastKeyMs) < _doubleTapMs;
    _lastKey = '.,';
    _lastKeyMs = nowMs;

    if (isDouble) {
      // 두 번째 탭: 앞의 '.'를 지우고 ','로 교체
      _deleteBack();
      _commitText(',');
    } else {
      _commitText('.');
    }
  }

  void _handleKorean(String key) {
    if (_layoutType == 'full' || !_multiTapUpgradeEnabled) {
      // 풀키보드이거나 연타 업그레이드 옵션이 꺼진 경우: 일반 두벌식 입력만 처리
      _composer.input(key);
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        _commitText(pending);
        _composer.clearPending();
      }
      _setComposing(_composer.composing);
      return;
    }
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
        _replaceComposing(_composer.composing);
        return;
      }
      // 받침 위치에서는 ㅉ 불가 → 독립 자음으로 입력
      _composer.input(upgraded3);
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        _commitText(pending);
        _composer.clearPending();
      }
      _setComposing(_composer.composing);
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
        // 겹받침 병합 시도: "만" 확정 + "ㅎ" → "많" 으로 병합
        if (!KoreanComposer.isVowel(key) && _composer.tryMergeCompoundJong()) {
          // 직전 확정 글자 삭제 후 병합된 음절로 교체
          _deleteBack();
          _replaceComposing(_composer.composing);
        } else {
          _replaceComposing(_composer.composing);
        }
        return;
      }
      _composer.input(upgraded);
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        _commitText(pending);
        _composer.clearPending();
      }
      _setComposing(_composer.composing);
      return;
    }

    // ── 1번 탭 (또는 4번 이상): 일반 입력 ────────────────────────────────
    _composer.input(key);
    final pending = _composer.pending;
    if (pending.isNotEmpty) {
      _commitText(pending);
      _composer.clearPending();
    }
    _setComposing(_composer.composing);
    // 키보드 UI 자체는 변하지 않으므로 setState 불필요
  }

  void _onDelete() {
    if (_mode == KeyboardMode.korean) {
      final hadComposing = _composer.backspace();
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        _commitText(pending);
        _composer.clearPending();
      }
      _setComposing(_composer.composing);
      if (!hadComposing) _deleteBack();
      // 삭제 시 키보드 UI 자체는 변하지 않으므로 setState 불필요
    } else {
      _deleteBack();
    }
  }

  void _commitKoreanAndSwitch(void Function() switchFn) {
    if (_mode == KeyboardMode.korean) {
      final text = _composer.commitAll();
      if (_isPreview) {
        setState(() => _previewUpdate(_previewBase + text, ''));
      } else {
        // 원자적으로 composing commit + 종료 (두 단계 비동기 타이밍 문제 방지)
        _channel.invokeMethod('switchModeCommit', {'text': text});
      }
    }
    _ssangMode = false;
    _lastKey = null;  // 더블탭 상태 초기화 (모드 전환 후 오입력 방지)
    _tapCount = 0;
    setState(switchFn);
    if (_mode != KeyboardMode.emoji) _saveInt('lastKeyboardMode', _mode.index);
  }

  void _onRotate() {
    _commitKoreanAndSwitch(() {
      switch (_mode) {
        case KeyboardMode.number:
          _mode = KeyboardMode.korean;
        case KeyboardMode.korean:
          _mode = KeyboardMode.english;
        case KeyboardMode.english:
          _mode = KeyboardMode.symbol;
        case KeyboardMode.symbol:
          _mode = KeyboardMode.number;
        case KeyboardMode.emoji:
          _mode = _modeBeforeEmoji;
      }
    });
  }

  void _setMode(KeyboardMode m) {
    setState(() => _mode = m);
    if (m != KeyboardMode.emoji) {
      _saveInt('lastKeyboardMode', m.index);
    }
  }

  void _onLangToggle() {
    if (_mode == KeyboardMode.emoji) {
      _lastKey = null;
      _tapCount = 0;
      _setMode(_modeBeforeEmoji);
      return;
    }
    _commitKoreanAndSwitch(() {
      _mode = _mode == KeyboardMode.korean
          ? KeyboardMode.english
          : KeyboardMode.korean;
      _modeBeforeEmoji = _mode;
    });
  }

  void _onSwitchToNumber() {
    if (_mode == KeyboardMode.emoji) {
      _lastKey = null;
      _tapCount = 0;
      _setMode(_modeBeforeEmoji);
      return;
    }
    _commitKoreanAndSwitch(() {
      if (_mode == KeyboardMode.number || _mode == KeyboardMode.symbol) {
        _mode = _modeBeforeEmoji;
      } else {
        _modeBeforeEmoji = _mode;
        _mode = KeyboardMode.number;
      }
    });
  }

  void _onCaps() => setState(() => _capsLock = !_capsLock);

  /// 쌍 버튼: 현재 조합 중인 자음이 있으면 즉시 쌍자음으로 업그레이드,
  /// 없으면 기존 모드 토글 (다음 자음을 쌍자음으로 입력).
  void _onSsang() {
    final cur = _composer.currentConsonant;
    if (cur.isNotEmpty && _ssangMap.containsKey(cur)) {
      final doubled = _ssangMap[cur]!;
      if (_composer.replaceCurrentConsonant(doubled)) {
        _lastKey = null;
        _tapCount = 0;
        _replaceComposing(_composer.composing);
        return; // 조합 텍스트만 변경 → 키보드 UI 리빌드 불필요
      }
    }
    setState(() => _ssangMode = !_ssangMode);
  }

  void _toggleEmoji() {
    if (_mode == KeyboardMode.emoji) {
      _lastKey = null;
      _tapCount = 0;
      _setMode(_modeBeforeEmoji);
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
    // 네비게이션 바 높이: IME 컨텍스트에서 viewPadding은 0이므로 네이티브에서 받은 값 사용
    final navBottom = _nativeNavBarHeight;
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
            if (navBottom > 0)
              Container(height: navBottom, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // ── 상단 툴바 ─────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
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
                  _commitText(emoji);
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
          const Divider(height: 8),

          // ── 키보드 레이아웃 ──────────────────────────────────────────────
          _settingLabel('키보드 레이아웃'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _segmentButton('일반', 0, _layoutType == 'standard' ? 0 : 1, (v) {
                  setState(() => _layoutType = v == 0 ? 'standard' : 'full');
                  _saveString('layoutType', v == 0 ? 'standard' : 'full');
                }),
                const SizedBox(width: 8),
                _segmentButton('두벌식 풀', 1, _layoutType == 'standard' ? 0 : 1, (v) {
                  setState(() => _layoutType = v == 0 ? 'standard' : 'full');
                  _saveString('layoutType', v == 0 ? 'standard' : 'full');
                }),
              ],
            ),
          ),
          const Divider(height: 8),

          // ── 일반 레이아웃 연타 업그레이드 ─────────────────────────────────
          SwitchListTile(
            dense: true,
            title: Text('연타 업그레이드(획/된소리)',
                style: TextStyle(fontSize: 15, color: _theme.charKeyText)),
            subtitle: Text(
              '빠른 타건 시 오입력이 있으면 꺼두세요',
              style: TextStyle(
                fontSize: 12,
                color: _theme.charKeyText.withOpacity(0.6),
              ),
            ),
            activeColor: _theme.actionKey,
            value: _multiTapUpgradeEnabled,
            onChanged: (v) {
              setState(() => _multiTapUpgradeEnabled = v);
              _saveBool('multiTapUpgradeEnabled', v);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Keyboard rows ─────────────────────────────────────────────────────────

  List<Widget> _buildMainRows() {
    final rows = switch (_mode) {
      KeyboardMode.number => _numberRows,
      KeyboardMode.korean => _layoutType == 'full' ? _koreanFullRows : _koreanRows,
      KeyboardMode.english => _englishRows,
      KeyboardMode.symbol => _symbolRows,
      KeyboardMode.emoji => _layoutType == 'full' ? _koreanFullRows : _koreanRows,
    };
    return [
      // 숫자행 (숫자 모드에선 중복이므로 제외)
      if (_showNumberRow && _mode != KeyboardMode.number && _mode != KeyboardMode.symbol)
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

  Widget _buildEnterIcon() {
    // imeAction: 0=UNSPECIFIED, 1=NONE → 줄바꿈, 2=GO, 3=SEARCH, 4=SEND, 5=NEXT, 6=DONE
    switch (_imeAction) {
      case 4: // SEND
        return Icon(Icons.send, size: 20, color: _theme.actionKeyText);
      case 3: // SEARCH
        return Icon(Icons.search, size: 22, color: _theme.actionKeyText);
      case 2: // GO
        return Icon(Icons.arrow_forward, size: 22, color: _theme.actionKeyText);
      case 5: // NEXT
        return Icon(Icons.arrow_downward, size: 22, color: _theme.actionKeyText);
      case 6: // DONE
        return Icon(Icons.check, size: 22, color: _theme.actionKeyText);
      default: // 0, 1 → 줄바꿈
        return Icon(Icons.keyboard_return, size: 22, color: _theme.actionKeyText);
    }
  }

  Widget _buildBottomRow() {
    final isKorean = _mode == KeyboardMode.korean;
    final isEnglish = _mode == KeyboardMode.english;
    final isSymbol = _mode == KeyboardMode.symbol;
    final isNumber = _mode == KeyboardMode.number;
    final isEmoji = _mode == KeyboardMode.emoji;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          // 한/영 전환 키
          _ActionKey(
            onTap: _onLangToggle,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 2,
            active: isKorean,
            child: Text(
              isKorean ? '한' : 'EN',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _theme.actionKeyText,
              ),
            ),
          ),
          // 숫자/기호 전환 키
          _ActionKey(
            onTap: _onSwitchToNumber,
            onLongPress: (isNumber || isSymbol)
                ? () => _commitKoreanAndSwitch(() {
                      _mode = isNumber
                          ? KeyboardMode.symbol
                          : KeyboardMode.number;
                    })
                : null,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 2,
            active: isNumber || isSymbol,
            child: Text(
              (isNumber || isSymbol) ? '가/a' : '123',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _theme.actionKeyText,
              ),
            ),
          ),
          // 쌍자음(한국어) / 대문자(영어) / ABC(기호) / 빈칸(그 외)
          _ActionKey(
            onTap: isKorean
                ? _onSsang
                : isEnglish
                    ? _onCaps
                    : isSymbol
                        ? () => _setMode(KeyboardMode.english)
                        : () {},
            onTapDown: (isKorean || isEnglish || isSymbol) ? _triggerFeedback : () {},
            theme: _theme,
            flex: 2,
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
                    : isSymbol
                        ? Text('ABC',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _theme.actionKeyText))
                        : const SizedBox(),
          ),
          _ActionKey(
            onTap: () => _onKey(' '),
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 4,
            animate: true,
            child: const Text(' ', style: TextStyle(fontSize: 14)),
          ),
          _ActionKey(
            onTap: _toggleEmoji,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 1,
            active: isEmoji,
            animate: true,
            child: Text(
              isEmoji ? '⌨️' : '😊',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          _ActionKey(
            onTap: _sendAction,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 2,
            animate: true,
            child: _buildEnterIcon(),
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
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
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
  Offset? _downPos;          // 터치 시작 위치 (슬라이드 감지)
  bool _cancelled = false;   // 슬라이드로 취소됨

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 25),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _curve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOutCubic,
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
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          _downPos = e.localPosition;
          _cancelled = false;
          widget.onTapDown();
          widget.onTap();
          if (widget.animate) _ctrl.forward();
          if (widget.showPopup) _showPopup();
        },
        onPointerMove: (e) {
          // 터치가 키 영역 밖으로 많이 벗어나면 팝업 숨김 (시각적 피드백)
          if (_downPos != null && !_cancelled) {
            final dx = (e.localPosition.dx - _downPos!.dx).abs();
            final dy = (e.localPosition.dy - _downPos!.dy).abs();
            if (dx > 30 || dy > 30) {
              _cancelled = true;
              if (widget.showPopup) _hidePopup();
            }
          }
        },
        onPointerUp: (_) {
          _downPos = null;
          if (widget.animate) _ctrl.reverse();
          if (widget.showPopup) _hidePopup();
        },
        onPointerCancel: (_) {
          _downPos = null;
          if (widget.animate) _ctrl.reverse();
          if (widget.showPopup) _hidePopup();
        },
        child: RepaintBoundary( // 각 키 애니메이션이 키보드 전체를 repaint하지 않도록 격리
          child: AnimatedBuilder(
          animation: _curve,
          builder: (ctx, child) {
            final t = _curve.value;
            final tC = t.clamp(0.0, 1.0);
            final scale = 1.0 - 0.04 * t;
            return Transform(
              transform: Matrix4.identity()
                ..translate(0.0, 1.5 * tC)
                ..scale(scale),
              alignment: Alignment.center,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.lerp(
                    widget.theme.charKey,
                    widget.theme.charKeyPressed,
                    tC,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: tC < 0.99
                      ? [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25 * (1 - tC)),
                            offset: Offset(0, (1 - tC) * 2),
                            blurRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: SizedBox.expand(
                  child: Center(child: child),
                ),
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
  bool _repeatFired = false; // repeat이 실제로 발동됐는지 추적
  bool _firedOnDown = false; // onTapDown에서 onTap이 이미 실행됐는지 추적
  Timer? _repeatTimer;
  late final AnimationController _ctrl;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 25),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _curve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _curve.dispose();
    _ctrl.dispose();
    _repeatTimer?.cancel();
    super.dispose();
  }

  int _repeatCount = 0;
  Timer? _holdTimer; // longPress 대기 타이머 (200ms)

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) _startRepeat();
    });
  }

  void _startRepeat() {
    if (_repeatFired) return;
    _repeatFired = true;
    _repeatCount = 0;
    widget.onTap();
    _scheduleNextRepeat();
  }

  void _scheduleNextRepeat() {
    if (!mounted) return;
    _repeatCount++;
    // 가속 삭제: 처음 느리다가 점점 빨라짐
    // 1~5회: 70ms, 6~15회: 40ms, 16회~: 20ms
    final delay = _repeatCount <= 5 ? 70
        : _repeatCount <= 15 ? 40
        : 20;
    _repeatTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      widget.onTapDown();
      widget.onTap();
      _scheduleNextRepeat();
    });
  }

  void _cancelRepeat() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    _repeatCount = 0;
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
            if (widget.animate) _ctrl.forward();
            if (widget.repeatOnHold) {
              _repeatFired = false;
              _firedOnDown = false;
              _startHoldTimer(); // 200ms 후 반복 삭제 시작
            } else if (widget.onLongPress == null) {
              // 길게누름/반복 없는 일반 키: 즉시 실행
              _firedOnDown = true;
              widget.onTap();
            } else {
              _firedOnDown = false;
            }
          },
          onTapUp: (_) {
            if (widget.animate) _ctrl.reverse();
            if (widget.repeatOnHold) {
              final didRepeat = _repeatFired;
              _cancelRepeat();
              if (!didRepeat) widget.onTap();
            } else if (!_firedOnDown && widget.onLongPress != null) {
              // longPress 지원 키: tapUp에서 실행 (longPress와 구분)
              // _firedOnDown 체크: 모드 전환으로 onLongPress가 생겼어도 이중 실행 방지
              widget.onTap();
            }
            _firedOnDown = false;
          },
          onTapCancel: () {
            if (widget.animate) _ctrl.reverse();
            if (widget.repeatOnHold) _cancelRepeat();
            _firedOnDown = false;
          },
          // 길게누름 지원 (repeatOnHold는 자체 타이머 사용 / onLongPress: 커스텀 액션)
          onLongPress: widget.repeatOnHold ? null
              : (widget.onLongPress != null ? () {
                  widget.onTapDown();
                  widget.onLongPress!();
                } : null),
          onLongPressEnd: (widget.onLongPress != null && !widget.repeatOnHold) ? (_) {
            _ctrl.reverse();
          } : null,
          child: RepaintBoundary( // 액션키 애니메이션 격리
            child: AnimatedBuilder(
              animation: _curve,
              builder: (ctx, child) {
                final t = _curve.value;
                final tC = t.clamp(0.0, 1.0);
                return Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 1.5 * tC)
                    ..scale(1.0 - 0.04 * t),
                  alignment: Alignment.center,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _bgColor(tC),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: tC < 0.99
                          ? [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.25 * (1 - tC)),
                                offset: Offset(0, (1 - tC) * 2),
                                blurRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: SizedBox(
                      height: 58,
                      child: Center(child: child),
                    ),
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
