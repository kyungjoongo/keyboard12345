import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'keyboard_view.dart';

// ── 공통 초기화 ──────────────────────────────────────────────────────────────

Future<void> _initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

// ── 임베디드 프리뷰 진입점 (MainActivity 내 키보드 미리보기 전용) ──────────────

@pragma('vm:entry-point')
void previewMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _PreviewEmbedApp());
}

class _PreviewEmbedApp extends StatefulWidget {
  const _PreviewEmbedApp();

  @override
  State<_PreviewEmbedApp> createState() => _PreviewEmbedAppState();
}

class _PreviewEmbedAppState extends State<_PreviewEmbedApp> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFFE5E7EB),
        body: Column(
          children: [
            // 입력 결과 표시창
            Container(
              width: double.infinity,
              height: 72,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _ctrl,
                      builder: (_, value, __) {
                        final text = value.text;
                        return Text(
                          text.isEmpty ? '키보드를 눌러 입력해 보세요...' : text,
                          style: TextStyle(
                            fontSize: 16,
                            color: text.isEmpty
                                ? const Color(0xFFAAAAAA)
                                : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _ctrl.clear(),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ],
              ),
            ),
            // 키보드
            KeyboardView(previewController: _ctrl),
          ],
        ),
      ),
    );
  }
}

// ── IME 서비스 진입점 (FlutterImeService 전용) ───────────────────────────────

@pragma('vm:entry-point')
void imeMain() async {
  await _initApp();
  runApp(const _ImeApp());
}

class _ImeApp extends StatelessWidget {
  const _ImeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const _ImeHost(),
    );
  }
}

class _ImeHost extends StatelessWidget {
  const _ImeHost();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: KeyboardView(),
      ),
    );
  }
}

// ── 일반 앱 진입점 (프리뷰 화면) ────────────────────────────────────────────

void main() async {
  await _initApp();
  runApp(const KeyboardApp());
}

class KeyboardApp extends StatelessWidget {
  const KeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const _PreviewScreen(),
    );
  }
}

// ── 프리뷰 화면 ───────────────────────────────────────────────────────────────

class _PreviewScreen extends StatefulWidget {
  const _PreviewScreen();

  @override
  State<_PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<_PreviewScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'StyloKey 미리보기',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: _ctrl,
                          builder: (_, value, __) {
                            final text = value.text;
                            return Text(
                              text.isEmpty ? '여기에 입력됩니다...' : text,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    text.isEmpty ? Colors.grey : Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _ctrl.clear(),
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('지우기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            KeyboardView(previewController: _ctrl),
          ],
        ),
      ),
    );
  }
}
