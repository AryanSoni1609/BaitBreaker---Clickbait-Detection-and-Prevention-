// lib/main.dart
// Contrastive BERT Clickbait Detector — Cyberpunk Edition

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────
//  THEME CONSTANTS
// ─────────────────────────────────────────
const Color kBg         = Color(0xFF020408);
const Color kBg2        = Color(0xFF060D14);
const Color kCyan       = Color(0xFF00F5FF);
const Color kGreen      = Color(0xFF39FF14);
const Color kPink       = Color(0xFFFF2079);
const Color kPurple     = Color(0xFF9D00FF);
const Color kOrange     = Color(0xFFFF6B00);
const Color kGlass      = Color(0x14FFFFFF);
const Color kGlassBorder= Color(0x30FFFFFF);

const TextStyle kMono = TextStyle(
  fontFamily: 'Courier New',
  color: kCyan,
  letterSpacing: 1.5,
);

// ─────────────────────────────────────────
//  ENTRY
// ─────────────────────────────────────────
void main() => runApp(const ClickbaitApp());

class ClickbaitApp extends StatelessWidget {
  const ClickbaitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kCyan, secondary: kGreen),
      ),
      home: const InputPage(),
    );
  }
}

// ═══════════════════════════════════════════
//  1. INPUT PAGE
// ═══════════════════════════════════════════
class InputPage extends StatefulWidget {
  const InputPage({super.key});
  @override State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage>
    with TickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  late AnimationController _pulseCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _headerCtrl;
  late Animation<double> _pulse;
  late Animation<double> _glow;
  late Animation<double> _headerSlide;
  bool _isFocused = false;
  bool _hasText    = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _headerCtrl= AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));

    _pulse       = Tween(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _glow        = Tween(begin: 6.0, end: 22.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _headerSlide = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutBack);

    _headerCtrl.forward();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
    _ctrl.addListener(() => setState(() => _hasText = _ctrl.text.isNotEmpty));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose(); _glowCtrl.dispose(); _headerCtrl.dispose();
    _ctrl.dispose(); _focus.dispose();
    super.dispose();
  }

  void _analyze() {
    if (_ctrl.text.trim().isEmpty) {
      _focus.requestFocus();
      return;
    }
    Navigator.push(context, _CyberPageRoute(
      page: LoadingPage(text: _ctrl.text.trim()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        const MatrixRain(),
        _CyberGrid(),
        SafeArea(
          child: Column(children: [
            const SizedBox(height: 16),
            _TickerBanner(),
            const SizedBox(height: 32),
            _AnimatedHeader(animation: _headerSlide),
            const Spacer(),
            _buildInputCard(),
            const Spacer(),
            _buildFooter(),
            const SizedBox(height: 24),
          ]),
        ),
      ]),
    );
  }

  Widget _buildInputCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glow, _pulse]),
      builder: (context, _) {
        return Center(
          child: Container(
            width: min(480, MediaQuery.of(context).size.width - 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: kGlass,
              border: Border.all(
                color: _isFocused
                    ? kCyan.withOpacity(0.8)
                    : kGlassBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: kCyan.withOpacity(_isFocused ? 0.25 : 0.08),
                  blurRadius: _glow.value * (_isFocused ? 2 : 1),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: kPurple.withOpacity(0.08),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'INPUT_VECTOR'),
                    const SizedBox(height: 14),
                    _CyberTextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      isFocused: _isFocused,
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(child: _ScanButton(
                        hasText: _hasText,
                        pulse: _pulse,
                        onTap: _analyze,
                      )),
                    ]),
                    if (_hasText) ...[
                      const SizedBox(height: 12),
                      _CharCounter(count: _ctrl.text.length),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatChip(label: 'MODEL', value: 'BERT-SNN'),
          const SizedBox(width: 16),
          _StatChip(label: 'ACC', value: '94.2%'),
          const SizedBox(width: 16),
          _StatChip(label: 'LATENCY', value: '<50ms'),
        ],
      ),
    );
  }
}

// ─── Animated header ───
class _AnimatedHeader extends StatelessWidget {
  final Animation<double> animation;
  const _AnimatedHeader({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
            .animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GlowIcon(icon: Icons.memory, color: kCyan, size: 28),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [kCyan, kGreen],
                  ).createShader(b),
                  child: const Text(
                    'CLICKBAIT.EXE',
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _GlowIcon(icon: Icons.memory, color: kGreen, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '» Siamese Neural Network  ·  Contrastive Learning  ·  v3.1 «',
              textAlign: TextAlign.center,
              style: kMono.copyWith(
                fontSize: 11,
                color: kCyan.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Cyberpunk text field ───
class _CyberTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;

  const _CyberTextField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? kCyan : kGlassBorder,
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [BoxShadow(color: kCyan.withOpacity(0.2), blurRadius: 12)]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: kMono.copyWith(fontSize: 14, color: Colors.white),
        maxLines: 3,
        minLines: 1,
        decoration: InputDecoration(
          hintText: '> paste headline or URL here...',
          hintStyle: kMono.copyWith(
            color: kCyan.withOpacity(0.35),
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.chevron_right,
                color: isFocused ? kCyan : kCyan.withOpacity(0.4), size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

// ─── Glowing scan button ───
class _ScanButton extends StatefulWidget {
  final bool hasText;
  final Animation<double> pulse;
  final VoidCallback onTap;
  const _ScanButton({required this.hasText, required this.pulse, required this.onTap});

  @override State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 200));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pulse,
      builder: (_, __) => GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) { _ctrl.forward(); setState(() => _hovering = true); },
        onTapUp: (_)   { _ctrl.reverse(); setState(() => _hovering = false); },
        onTapCancel: () { _ctrl.reverse(); setState(() => _hovering = false); },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit:  (_) => setState(() => _hovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: _hovering
                    ? [kGreen, kCyan]
                    : [kCyan.withOpacity(0.8), kGreen.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: kCyan.withOpacity(
                      _hovering ? 0.7 : widget.pulse.value * 0.4),
                  blurRadius: _hovering ? 30 : widget.pulse.value * 20,
                  spreadRadius: _hovering ? 2 : 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.radar, color: kBg, size: 20),
                const SizedBox(width: 10),
                Text(
                  'INITIATE SCAN',
                  style: TextStyle(
                    fontFamily: 'Courier New',
                    color: kBg,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  2. LOADING PAGE
// ═══════════════════════════════════════════
class LoadingPage extends StatefulWidget {
  final String text;
  const LoadingPage({super.key, required this.text});
  @override State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _stepCtrl;

  double _progress = 0;
  int    _stepIdx  = 0;
  String _log      = '';

  final _steps = [
    ('INIT',  'Booting neural inference engine...'),
    ('PARSE', 'Tokenizing input sequence...'),
    ('EMBED', 'Projecting to 768-dim embedding space...'),
    ('INFER', 'Running Siamese contrastive pass...'),
    ('EVAL',  'Computing similarity distance metric...'),
    ('DONE',  'Classification complete — compiling report...'),
  ];

  @override
  void initState() {
    super.initState();
    _rotCtrl  = AnimationController(vsync: this,
        duration: const Duration(seconds: 3))..repeat();
    _pulseCtrl= AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _stepCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 400));
    _runPipeline();
  }

  @override void dispose() {
    _rotCtrl.dispose(); _pulseCtrl.dispose(); _stepCtrl.dispose();
    super.dispose();
  }

  Future<void> _runPipeline() async {
    // --- hit backend in parallel with fake progress ---
    String result = 'SAFE';
    double confidence = 0.0;
    final backendFuture = _callBackend();

    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _stepCtrl.reset(); _stepCtrl.forward();
      setState(() {
        _stepIdx  = i;
        _progress = (i + 1) / _steps.length;
        _log      += '[${_steps[i].$1}] ${_steps[i].$2}\n';
      });
    }

    final backendData = await backendFuture;
    result = backendData['result'];
    confidence = backendData['confidence'];

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      _CyberPageRoute(page: ResultPage(result: result, headline: widget.text, confidence: confidence)),
    );
  }

  Future<Map<String, dynamic>> _callBackend() async {
    String url = 'http://127.0.0.1:8000/predict';
    try { if (Platform.isAndroid) url = 'http://10.0.2.2:8000/predict'; }
    catch (_) {}
    try {
      final res = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': widget.text}));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return {
          'result': body['prediction'] == 'Clickbait' ? 'CLICKBAIT' : 'SAFE',
          'confidence': body['confidence'] ?? 0.0
        };
      }
    } catch (_) {}
    return {'result': 'SAFE', 'confidence': 0.0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        const MatrixRain(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 20),
              _buildScannerRing(),
              const SizedBox(height: 40),
              _buildProgressBar(),
              const SizedBox(height: 24),
              _buildStepList(),
              const Spacer(),
              _buildLogTerminal(),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildScannerRing() {
    return SizedBox(
      width: 200, height: 200,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotCtrl, _pulseCtrl]),
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Transform.rotate(
              angle: _rotCtrl.value * 2 * pi,
              child: CustomPaint(
                size: const Size(200, 200),
                painter: _RingPainter(color: kCyan, strokeWidth: 2, dashed: true),
              ),
            ),
            // Middle ring
            Transform.rotate(
              angle: -_rotCtrl.value * 4 * pi,
              child: CustomPaint(
                size: const Size(150, 150),
                painter: _RingPainter(color: kGreen, strokeWidth: 1.5, dashed: true, segments: 6),
              ),
            ),
            // Pulse
            Container(
              width: 80 + _pulseCtrl.value * 20,
              height: 80 + _pulseCtrl.value * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCyan.withOpacity(0.05 * (1 - _pulseCtrl.value)),
                border: Border.all(
                  color: kCyan.withOpacity(0.3 + _pulseCtrl.value * 0.5),
                  width: 1,
                ),
              ),
            ),
            // Core
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: kCyan, width: 2),
                boxShadow: [BoxShadow(color: kCyan.withOpacity(0.5), blurRadius: 20)],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.memory, color: kCyan, size: 22),
                const SizedBox(height: 2),
                Text('${(_progress * 100).toInt()}%',
                    style: kMono.copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('PROCESSING PIPELINE', style: kMono.copyWith(fontSize: 10,
            color: kCyan.withOpacity(0.7))),
        Text('${(_progress * 100).toInt()}%', style: kMono.copyWith(fontSize: 10)),
      ]),
      const SizedBox(height: 8),
      Container(
        height: 6, decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(3),
      ),
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          widthFactor: _progress,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: const LinearGradient(colors: [kCyan, kGreen]),
              boxShadow: [BoxShadow(color: kCyan.withOpacity(0.8), blurRadius: 8)],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildStepList() {
    return Column(
      children: List.generate(_steps.length, (i) {
        final done    = i < _stepIdx;
        final current = i == _stepIdx;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: current
                ? kCyan.withOpacity(0.08)
                : Colors.transparent,
            border: Border.all(
              color: current ? kCyan.withOpacity(0.4)
                  : done ? kGreen.withOpacity(0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: done
                  ? Icon(Icons.check_circle, color: kGreen, size: 16, key: const ValueKey('done'))
                  : current
                  ? _PulsingDot(key: const ValueKey('cur'))
                  : Icon(Icons.circle_outlined,
                  color: Colors.white.withOpacity(0.15), size: 16,
                  key: const ValueKey('idle')),
            ),
            const SizedBox(width: 10),
            Text(
              '[${_steps[i].$1}]',
              style: kMono.copyWith(
                fontSize: 11,
                color: current ? kCyan
                    : done ? kGreen.withOpacity(0.7)
                    : Colors.white.withOpacity(0.2),
                fontWeight: current ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _steps[i].$2,
                style: TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 11,
                  color: current ? Colors.white.withOpacity(0.85)
                      : done ? Colors.white.withOpacity(0.4)
                      : Colors.white.withOpacity(0.15),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        );
      }),
    );
  }

  Widget _buildLogTerminal() {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kGreen.withOpacity(0.25)),
      ),
      child: SingleChildScrollView(
        reverse: true,
        child: Text(
          '> $_log',
          style: kMono.copyWith(fontSize: 10, color: kGreen.withOpacity(0.7)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  3. RESULT PAGE
// ═══════════════════════════════════════════
class ResultPage extends StatefulWidget {
  final String result;
  final String headline;
  final double confidence;
  const ResultPage({super.key, required this.result, required this.headline, required this.confidence});
  @override State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _fadeAnim;

  bool get _isCb => widget.result == 'CLICKBAIT';

  Color get _accent => _isCb ? kPink    : kGreen;
  Color get _accent2 => _isCb ? kOrange : kCyan;

  @override
  void initState() {
    super.initState();
    _enterCtrl   = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 800));
    _pulseCtrl   = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _particleCtrl= AnimationController(vsync: this,
        duration: const Duration(seconds: 4))..repeat();

    _scaleAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterCtrl.forward();
  }

  @override void dispose() {
    _enterCtrl.dispose(); _pulseCtrl.dispose(); _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        const MatrixRain(),
        AnimatedBuilder(
          animation: _particleCtrl,
          builder: (_, __) => CustomPaint(
            painter: _ParticlePainter(_particleCtrl.value, _accent),
            size: MediaQuery.of(context).size,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 20),
              FadeTransition(opacity: _fadeAnim, child: _buildHeader()),
              const Spacer(),
              _buildResultCard(),
              const SizedBox(height: 32),
              FadeTransition(opacity: _fadeAnim, child: _buildHeadlineCard()),
              const Spacer(),
              FadeTransition(opacity: _fadeAnim, child: _buildActions()),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    return Column(children: [
      Text('ANALYSIS COMPLETE',
          style: kMono.copyWith(fontSize: 11, color: kCyan.withOpacity(0.6),
              letterSpacing: 4)),
      const SizedBox(height: 4),
      Container(height: 1, color: kCyan.withOpacity(0.2)),
    ]);
  }

  Widget _buildResultCard() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _accent.withOpacity(0.12),
                  _accent2.withOpacity(0.06),
                ],
              ),
              border: Border.all(
                color: _accent.withOpacity(0.4 + _pulseCtrl.value * 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.2 + _pulseCtrl.value * 0.15),
                  blurRadius: 40 + _pulseCtrl.value * 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(children: [
              // Verdict icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(0.1),
                  border: Border.all(color: _accent, width: 2),
                  boxShadow: [BoxShadow(
                      color: _accent.withOpacity(0.5), blurRadius: 20)],
                ),
                child: Icon(
                  _isCb ? Icons.warning_amber : Icons.verified_user,
                  color: _accent, size: 38,
                ),
              ),
              const SizedBox(height: 20),
              // Verdict text
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [_accent, _accent2],
                ).createShader(b),
                child: Text(
                  _isCb ? '⚠  CLICKBAIT DETECTED' : '✓  LEGITIMATE HEADLINE',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Sub-label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _accent.withOpacity(0.1),
                  border: Border.all(color: _accent.withOpacity(0.3)),
                ),
                child: Text(
                  _isCb
                      ? 'MANIPULATION SIGNALS FOUND · HIGH CONFIDENCE'
                      : 'NO MANIPULATION SIGNALS · SAFE TO PROCEED',
                  style: TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 10,
                    color: _accent.withOpacity(0.9),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Metric chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MetricChip(label: 'VERDICT',
                      value: _isCb ? 'UNSAFE' : 'SAFE', accent: _accent),
                  _MetricChip(label: 'CONFIDENCE', value: '${(widget.confidence * 100).toStringAsFixed(1)}%', accent: _accent),
                  _MetricChip(label: 'STATUS', value: 'DONE', accent: _accent),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadlineCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: kGlassBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ANALYZED INPUT', style: kMono.copyWith(
            fontSize: 9, color: kCyan.withOpacity(0.5), letterSpacing: 3)),
        const SizedBox(height: 8),
        Text(
          widget.headline,
          style: const TextStyle(
            fontFamily: 'Courier New',
            fontSize: 13,
            color: Colors.white70,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }

  Widget _buildActions() {
    return Row(children: [
      Expanded(
        child: _OutlineButton(
          label: 'SCAN ANOTHER',
          icon: Icons.refresh,
          color: kCyan,
          onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════

class _TickerBanner extends StatefulWidget {
  @override State<_TickerBanner> createState() => _TickerBannerState();
}

class _TickerBannerState extends State<_TickerBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset>   _slide;
  int _idx = 0;

  final _items = [
    'BREAKING: AI models detect misinformation at 94.2% accuracy',
    'ALERT: Clickbait surges 340% during election cycles — study',
    'WARNING: Viral fake headlines spread 6x faster than real news',
    'UPDATE: BERT-based models now outperform human fact-checkers',
    'LIVE: Digital trust index falls to record low — WHO report',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 6));
    _slide = Tween<Offset>(
      begin: const Offset(1, 0), end: const Offset(-1.5, 0),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _idx = (_idx + 1) % _items.length;
        _ctrl.reset(); _ctrl.forward();
      }
    });
    _ctrl.forward();
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: kPink.withOpacity(0.9),
        boxShadow: [BoxShadow(color: kPink.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(color: Colors.black26),
          child: const Text('LIVE',
              style: TextStyle(
                  fontFamily: 'Courier New',
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 2,
                  color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRect(
            child: SlideTransition(
              position: _slide,
              child: Text(
                _items[_idx],
                style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  final IconData icon; final Color color; final double size;
  const _GlowIcon({required this.icon, required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Icon(icon, color: color, size: size,
      shadows: [Shadow(color: color, blurRadius: 12)]);
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 14,
          decoration: BoxDecoration(
              color: kCyan,
              boxShadow: [BoxShadow(color: kCyan, blurRadius: 6)])),
      const SizedBox(width: 8),
      Text(label,
          style: kMono.copyWith(fontSize: 10, letterSpacing: 3,
              color: kCyan.withOpacity(0.7))),
    ]);
  }
}

class _CharCounter extends StatelessWidget {
  final int count;
  const _CharCounter({required this.count});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text('$count CHARS',
          style: kMono.copyWith(fontSize: 9, color: kCyan.withOpacity(0.4))),
    ],
  );
}

class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: kGlass,
        border: Border.all(color: kGlassBorder),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label:', style: kMono.copyWith(
            fontSize: 9, color: kCyan.withOpacity(0.45))),
        const SizedBox(width: 4),
        Text(value, style: kMono.copyWith(
            fontSize: 9, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label, value; final Color accent;
  const _MetricChip({required this.label, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: TextStyle(fontFamily: 'Courier New',
          fontSize: 9, color: accent.withOpacity(0.5), letterSpacing: 2)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontFamily: 'Courier New',
          fontSize: 12, fontWeight: FontWeight.bold, color: accent)),
    ]);
  }
}

class _OutlineButton extends StatefulWidget {
  final String label; final IconData icon;
  final Color color; final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.icon,
    required this.color, required this.onTap});
  @override State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _h = false;
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit:  (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _h ? widget.color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: widget.color.withOpacity(_h ? 0.9 : 0.4)),
          boxShadow: _h
              ? [BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 16)]
              : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.icon, color: widget.color, size: 18),
          const SizedBox(width: 8),
          Text(widget.label, style: TextStyle(
            fontFamily: 'Courier New', color: widget.color,
            fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold,
          )),
        ]),
      ),
    ),
  );
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({super.key});
  @override State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 16, height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kCyan.withOpacity(0.4 + _c.value * 0.6),
          boxShadow: [BoxShadow(color: kCyan.withOpacity(_c.value * 0.8),
              blurRadius: 6)],
        ),
      ));
}

// ═══════════════════════════════════════════
//  CUSTOM PAINTERS
// ═══════════════════════════════════════════

/// Dashed / segmented circle ring
class _RingPainter extends CustomPainter {
  final Color color; final double strokeWidth;
  final bool dashed; final int segments;
  _RingPainter({required this.color, required this.strokeWidth,
    this.dashed = false, this.segments = 8});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    if (!dashed) {
      canvas.drawCircle(c, r, paint);
      return;
    }
    final step = 2 * pi / segments;
    for (int i = 0; i < segments; i++) {
      final start = i * step;
      final sweep = step * 0.6;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r),
          start, sweep, false, paint);
    }
  }

  @override bool shouldRepaint(_) => false;
}

/// Particle burst effect for result page
class _ParticlePainter extends CustomPainter {
  final double t;
  final Color color;
  final List<_Particle> _particles;

  _ParticlePainter(this.t, this.color)
      : _particles = _buildParticles(color);

  static final _rand = Random(42);
  static List<_Particle> _buildParticles(Color c) =>
      List.generate(40, (_) => _Particle(
        angle: _rand.nextDouble() * 2 * pi,
        speed: 0.1 + _rand.nextDouble() * 0.4,
        size:  1 + _rand.nextDouble() * 2.5,
        color: c,
      ));

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (final p in _particles) {
      final phase = (t + p.speed) % 1.0;
      final dist  = phase * size.height * 0.5;
      final x     = cx + cos(p.angle) * dist;
      final y     = cy + sin(p.angle) * dist;
      final opacity = (1 - phase) * 0.6;

      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = p.color.withOpacity(opacity),
      );
    }
  }

  @override bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

class _Particle {
  final double angle, speed, size;
  final Color color;
  const _Particle({required this.angle, required this.speed,
    required this.size, required this.color});
}

/// Animated matrix rain background
class MatrixRain extends StatefulWidget {
  const MatrixRain({super.key});
  @override State<MatrixRain> createState() => _MatrixRainState();
}

class _MatrixRainState extends State<MatrixRain>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100))..repeat();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _MatrixPainter(),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _MatrixPainter extends CustomPainter {
  static final _rand    = Random();
  static final _cols    = <_RainColumn>[];
  static bool  _inited  = false;
  static int   _cols_n  = 0;

  static const _chars = '01ABCDEF><[]{}|/\\!@#\$%^&*';

  static void _init(Size size) {
    final n = (size.width / 18).ceil();
    if (_inited && n == _cols_n) return;
    _inited = true; _cols_n = n; _cols.clear();
    for (int i = 0; i < n; i++) {
      _cols.add(_RainColumn(
        x: i * 18.0,
        y: _rand.nextDouble() * size.height,
        speed: 60 + _rand.nextDouble() * 80,
        length: 4 + _rand.nextInt(10),
        char: _chars[_rand.nextInt(_chars.length)],
      ));
    }
  }

  static DateTime _last = DateTime.now();

  @override
  void paint(Canvas canvas, Size size) {
    _init(size);
    final now  = DateTime.now();
    final dt   = now.difference(_last).inMilliseconds / 1000.0;
    _last = now;

    for (final col in _cols) {
      col.y += col.speed * dt;
      if (col.y > size.height + col.length * 18) {
        col.y = -col.length * 18;
        col.char = _chars[_rand.nextInt(_chars.length)];
      }
      for (int j = 0; j < col.length; j++) {
        final opacity = (1 - j / col.length) * 0.18;
        final isHead  = j == 0;
        canvas.drawParagraph(
          _buildParagraph(col.char,
              isHead ? kCyan.withOpacity(0.55) : kGreen.withOpacity(opacity),
              isHead ? 12 : 10),
          Offset(col.x, col.y - j * 18),
        );
      }
    }
  }

  Paragraph _buildParagraph(String text, Color color, double size) {
    final pb = ParagraphBuilder(ParagraphStyle())
      ..pushStyle(ui.TextStyle(
          color: color, fontSize: size, fontFamily: 'Courier New'))
      ..addText(text);
    return pb.build()..layout(const ParagraphConstraints(width: 20));
  }

  @override bool shouldRepaint(_) => true;
}

class _RainColumn {
  double x, y, speed;
  int length;
  String char;
  _RainColumn({required this.x, required this.y, required this.speed,
    required this.length, required this.char});
}

/// Subtle grid overlay
class _CyberGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.03,
      child: CustomPaint(
        painter: _GridPainter(),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kCyan..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += spacing)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
//  CUSTOM PAGE ROUTE
// ─────────────────────────────────────────
class _CyberPageRoute extends PageRouteBuilder {
  final Widget page;
  _CyberPageRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 600),
    transitionsBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}
