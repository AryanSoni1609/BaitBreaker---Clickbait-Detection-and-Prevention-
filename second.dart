// lib/main.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

const Color neon = Colors.greenAccent;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const InputPage(),
    );
  }
}

// ---------------- INPUT PAGE ----------------
class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController controller = TextEditingController();

  void analyze() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingPage(text: controller.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ...List.generate(12, (_) => DVDIcon(screenSize: size)),

          Column(
            children: [
              const SizedBox(height: 60),

              Container(
                height: 45,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 10),
                    Text("BREAKING",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    SizedBox(width: 10),
                    Expanded(child: _Ticker()),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "[ Contrastive BERT Clickbait Detector ]",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  color: neon,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 20, color: neon)],
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "» Powered by Siamese Neural Networks + Contrastive Learning",
                textAlign: TextAlign.center,
                style: TextStyle(color: neon),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Center(
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: neon.withOpacity(0.6),
                          blurRadius: 25,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("ENTER HEADLINE",
                            style: TextStyle(color: neon)),
                        const SizedBox(height: 20),

                        TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Paste headline or link...",
                            prefixIcon:
                            const Icon(Icons.search, color: neon),
                            filled: true,
                            fillColor: Colors.black54,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: analyze,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neon,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("SCAN"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- DVD ICON ----------------
class DVDIcon extends StatefulWidget {
  final Size screenSize;

  const DVDIcon({super.key, required this.screenSize});

  @override
  State<DVDIcon> createState() => _DVDIconState();
}

class _DVDIconState extends State<DVDIcon> {
  late double x;
  late double y;
  late double dx;
  late double dy;

  @override
  void initState() {
    super.initState();
    final rand = Random();

    x = rand.nextDouble() * widget.screenSize.width;
    y = rand.nextDouble() * widget.screenSize.height;

    dx = (rand.nextBool() ? 1 : -1) * 2.5;
    dy = (rand.nextBool() ? 1 : -1) * 2.5;

    move();
  }

  void move() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 16));
      setState(() {
        x += dx;
        y += dy;

        if (x <= 0 || x >= widget.screenSize.width - 30) dx *= -1;
        if (y <= 0 || y >= widget.screenSize.height - 30) dy *= -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: const Icon(Icons.warning,
          color: Colors.redAccent, size: 30),
    );
  }
}

// ---------------- TICKER ----------------
class _Ticker extends StatefulWidget {
  const _Ticker();

  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> {
  final texts = [
    "AI detects misinformation spikes globally",
    "Cybersecurity threats rising due to fake news",
    "False alarms triggered by viral clickbait",
    "Digital trust impacted by misinformation"
  ];

  int index = 0;
  double position = 1;

  @override
  void initState() {
    super.initState();
    animate();
  }

  void animate() async {
    while (true) {
      for (double i = 1; i >= -1.5; i -= 0.003) {
        await Future.delayed(const Duration(milliseconds: 16));
        if (!mounted) return;
        setState(() => position = i);
      }
      index = (index + 1) % texts.length;
      position = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(position * MediaQuery.of(context).size.width, 0),
      child: Text(
        texts[index],
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ---------------- LOADING ----------------
class LoadingPage extends StatefulWidget {
  final String text;

  const LoadingPage({super.key, required this.text});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  double progress = 0;
  String status = "Initializing AI...";

  final steps = [
    "Scanning headline...",
    "Extracting features...",
    "Analyzing semantic intent...",
    "Detecting manipulation...",
    "Finalizing prediction..."
  ];

  @override
  void initState() {
    super.initState();
    runAI();
  }

  void runAI() async {
    // Determine the correct backend URL based on the platform
    String backendUrl = 'http://127.0.0.1:8000/predict';
    try {
      if (Platform.isAndroid) {
        backendUrl = 'http://10.0.2.2:8000/predict';
      }
    } catch (e) {
      // Ignore if running on a platform where Platform.isAndroid throws
    }

    String finalResult = "SAFE";
    
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': widget.text}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['prediction'] == 'Clickbait') {
          finalResult = "CLICKBAIT";
        }
      }
    } catch (e) {
      print("Error connecting to backend: $e");
    }

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500)); // Sped up the animation a bit
      if (!mounted) return;
      setState(() {
        status = steps[i];
        progress = (i + 1) / steps.length;
      });
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(result: finalResult),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: neon),
            const SizedBox(height: 20),
            Text(status, style: const TextStyle(color: neon)),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: progress, color: neon),
            const SizedBox(height: 10),
            Text("${(progress * 100).toInt()}%"),
          ],
        ),
      ),
    );
  }
}

// ---------------- RESULT ----------------
class ResultPage extends StatelessWidget {
  final String result;

  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isClickbait = result == "CLICKBAIT";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isClickbait
                  ? [Colors.red, Colors.orange]
                  : [Colors.green, Colors.teal],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isClickbait ? Icons.warning : Icons.verified,
                size: 100,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              Text(
                isClickbait
                    ? "⚠️ CLICKBAIT DETECTED"
                    : "✅ SAFE HEADLINE",
                style: const TextStyle(
                    fontSize: 26,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}