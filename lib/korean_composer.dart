/// Korean (두벌식) syllable composition engine.
///
/// Usage:
///   composer.input(key);           // process a jamo key
///   final c = composer.pending;    // text ready to commit (finalized syllables)
///   final x = composer.composing;  // in-progress syllable shown as composing
///   composer.clearPending();       // clear after you have committed c
class KoreanComposer {
  // ── Unicode tables ──────────────────────────────────────────────────────

  static const Map<String,int> _choIdx = {
    'ㄱ':0,'ㄲ':1,'ㄴ':2,'ㄷ':3,'ㄸ':4,'ㄹ':5,'ㅁ':6,'ㅂ':7,'ㅃ':8,
    'ㅅ':9,'ㅆ':10,'ㅇ':11,'ㅈ':12,'ㅉ':13,'ㅊ':14,'ㅋ':15,'ㅌ':16,'ㅍ':17,'ㅎ':18,
  };

  static const Map<String,int> _jungIdx = {
    'ㅏ':0,'ㅐ':1,'ㅑ':2,'ㅒ':3,'ㅓ':4,'ㅔ':5,'ㅕ':6,'ㅖ':7,'ㅗ':8,'ㅘ':9,
    'ㅙ':10,'ㅚ':11,'ㅛ':12,'ㅜ':13,'ㅝ':14,'ㅞ':15,'ㅟ':16,'ㅠ':17,'ㅡ':18,'ㅢ':19,'ㅣ':20,
  };

  static const Map<String,int> _jongIdx = {
    'ㄱ':1,'ㄲ':2,'ㄳ':3,'ㄴ':4,'ㄵ':5,'ㄶ':6,'ㄷ':7,'ㄹ':8,'ㄺ':9,
    'ㄻ':10,'ㄼ':11,'ㄽ':12,'ㄾ':13,'ㄿ':14,'ㅀ':15,'ㅁ':16,'ㅂ':17,'ㅄ':18,'ㅅ':19,
    'ㅆ':20,'ㅇ':21,'ㅈ':22,'ㅊ':23,'ㅋ':24,'ㅌ':25,'ㅍ':26,'ㅎ':27,
  };

  // compound vowels: base + added → compound
  static const Map<String,Map<String,String>> _vowelCombine = {
    'ㅏ': {'ㅣ':'ㅐ'},
    'ㅓ': {'ㅣ':'ㅔ'},
    'ㅑ': {'ㅣ':'ㅒ'},
    'ㅕ': {'ㅣ':'ㅖ'},
    'ㅗ': {'ㅏ':'ㅘ','ㅐ':'ㅙ','ㅣ':'ㅚ'},
    'ㅜ': {'ㅓ':'ㅝ','ㅔ':'ㅞ','ㅣ':'ㅟ'},
    'ㅡ': {'ㅣ':'ㅢ'},
  };

  // compound final consonants
  static const Map<String,Map<String,String>> _jongCombine = {
    'ㄱ': {'ㅅ':'ㄳ'},
    'ㄴ': {'ㅈ':'ㄵ','ㅎ':'ㄶ'},
    'ㄹ': {'ㄱ':'ㄺ','ㅁ':'ㄻ','ㅂ':'ㄼ','ㅅ':'ㄽ','ㅌ':'ㄾ','ㅍ':'ㄿ','ㅎ':'ㅀ'},
    'ㅂ': {'ㅅ':'ㅄ'},
  };

  // split compound jongsung → [first, second]
  static const Map<String,List<String>> _jongSplit = {
    'ㄳ':['ㄱ','ㅅ'],'ㄵ':['ㄴ','ㅈ'],'ㄶ':['ㄴ','ㅎ'],
    'ㄺ':['ㄹ','ㄱ'],'ㄻ':['ㄹ','ㅁ'],'ㄼ':['ㄹ','ㅂ'],
    'ㄽ':['ㄹ','ㅅ'],'ㄾ':['ㄹ','ㅌ'],'ㄿ':['ㄹ','ㅍ'],
    'ㅀ':['ㄹ','ㅎ'],'ㅄ':['ㅂ','ㅅ'],
  };

  // split compound vowels back (for backspace)
  static const Map<String,String> _vowelSplit = {
    'ㅐ':'ㅏ','ㅔ':'ㅓ','ㅒ':'ㅑ','ㅖ':'ㅕ',
    'ㅘ':'ㅗ','ㅙ':'ㅗ','ㅚ':'ㅗ',
    'ㅝ':'ㅜ','ㅞ':'ㅜ','ㅟ':'ㅜ',
    'ㅢ':'ㅡ',
  };

  // ── State ────────────────────────────────────────────────────────────────

  String _cho_ = '';   // initial consonant being composed
  String _jung_ = '';  // vowel being composed
  String _jong_ = '';  // final consonant being composed

  /// Finalized syllables ready to be committed to InputConnection.
  String _pending = '';

  /// Text ready to commit (finalized completed syllables).
  String get pending => _pending;

  /// Current in-progress syllable for setComposingText.
  String get composing => _build();

  void clearPending() => _pending = '';

  // ── Helpers ──────────────────────────────────────────────────────────────

  static bool isConsonant(String c) => _choIdx.containsKey(c);
  static bool isVowel(String c) => _jungIdx.containsKey(c);

  String _build() {
    if (_cho_.isEmpty) return '';
    if (_jung_.isEmpty) return _cho_;
    final ci = _choIdx[_cho_]!;
    final vi = _jungIdx[_jung_]!;
    final ji = _jong_.isEmpty ? 0 : (_jongIdx[_jong_] ?? 0);
    return String.fromCharCode(0xAC00 + (ci * 21 + vi) * 28 + ji);
  }

  void _finalize() {
    final s = _build();
    if (s.isNotEmpty) _pending += s;
    _cho_ = ''; _jung_ = ''; _jong_ = '';
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Process a jamo or other character key.
  void input(String key) {
    if (isConsonant(key)) {
      _handleConsonant(key);
    } else if (isVowel(key)) {
      _handleVowel(key);
    } else {
      // Commit composing + key as literal
      _finalize();
      _pending += key;
    }
  }

  void _handleConsonant(String c) {
    if (_cho_.isEmpty) {
      _cho_ = c; return;
    }
    if (_jung_.isEmpty) {
      // Two consonants in a row → commit first, start new
      _finalize(); _cho_ = c; return;
    }
    if (_jong_.isEmpty) {
      if (_jongIdx.containsKey(c)) {
        _jong_ = c;
      } else {
        _finalize(); _cho_ = c;
      }
      return;
    }
    // Try compound jongsung
    final compound = _jongCombine[_jong_]?[c];
    if (compound != null) {
      _jong_ = compound;
    } else {
      _finalize(); _cho_ = c;
    }
  }

  void _handleVowel(String v) {
    if (_cho_.isEmpty) {
      // Vowel-only syllable uses silent ㅇ
      _cho_ = 'ㅇ'; _jung_ = v; return;
    }
    if (_jung_.isEmpty) {
      _jung_ = v; return;
    }
    if (_jong_.isEmpty) {
      // Try compound vowel
      final compound = _vowelCombine[_jung_]?[v];
      if (compound != null) {
        _jung_ = compound;
      } else {
        _finalize(); _cho_ = 'ㅇ'; _jung_ = v;
      }
      return;
    }
    // jongsung + vowel → jongsung becomes new chosung
    final split = _jongSplit[_jong_];
    if (split != null) {
      _jong_ = split[0];
      final newCho = split[1];
      _finalize();
      _cho_ = newCho; _jung_ = v;
    } else {
      final newCho = _jong_;
      _jong_ = '';
      _finalize();
      _cho_ = newCho; _jung_ = v;
    }
  }

  /// Backspace: remove last jamo unit.
  /// Returns true if something was removed from composing state.
  /// Returns false if nothing in composing — caller should delete 1 char via IME.
  bool backspace() {
    if (_jong_.isNotEmpty) {
      final split = _jongSplit[_jong_];
      _jong_ = split != null ? split[0] : '';
      return true;
    }
    if (_jung_.isNotEmpty) {
      final base = _vowelSplit[_jung_];
      _jung_ = base ?? '';
      return true;
    }
    if (_cho_.isNotEmpty) {
      _cho_ = '';
      return true;
    }
    return false; // nothing composing
  }

  /// Double-tap upgrade: replace current vowel if one is composing.
  /// e.g. ㅓ → ㅕ, ㅗ → ㅛ
  /// Returns true if the vowel was replaced.
  bool replaceCurrentVowel(String newVowel) {
    if (_jung_.isNotEmpty && _jong_.isEmpty) {
      _jung_ = newVowel;
      return true;
    }
    return false;
  }

  /// Double-tap upgrade: replace current consonant (종성 or 홀로 선 초성).
  /// e.g. ㅈ → ㅊ, ㄱ → ㅋ
  /// Returns true if replaced.
  bool replaceCurrentConsonant(String newConsonant) {
    // Case 1: jongsung just set
    if (_jong_.isNotEmpty && _jongIdx.containsKey(newConsonant)) {
      // If current jong is a compound (e.g. ㄵ = ㄴ+ㅈ), the first input
      // formed a compound받침, but the user intended to start a new syllable
      // with the upgraded consonant. Split it: keep the first part as jong,
      // finalize current syllable, start a new syllable with newConsonant.
      final split = _jongSplit[_jong_];
      if (split != null) {
        _jong_ = split[0];
        _finalize();
        _cho_ = newConsonant;
      } else {
        _jong_ = newConsonant;
      }
      return true;
    }
    // Case 2: lone chosung (no vowel yet)
    if (_cho_.isNotEmpty && _jung_.isEmpty && _choIdx.containsKey(newConsonant)) {
      _cho_ = newConsonant;
      return true;
    }
    return false;
  }

  /// 현재 조합 위치의 자음을 반환합니다 (쌍자음 업그레이드 판단용).
  /// 받침이 있으면 받침, 초성만 있으면 초성, 없으면 빈 문자열.
  String get currentConsonant {
    if (_jong_.isNotEmpty) return _jong_;
    if (_cho_.isNotEmpty && _jung_.isEmpty) return _cho_;
    return '';
  }

  /// Commit everything and reset.
  String commitAll() {
    _finalize();
    final result = _pending;
    _pending = '';
    return result;
  }

  void reset() {
    _cho_ = ''; _jung_ = ''; _jong_ = ''; _pending = '';
  }
}
