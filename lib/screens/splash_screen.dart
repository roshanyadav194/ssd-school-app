import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'school_discovery_screen.dart';

const String supabaseUrl = 'https://shlzyjkkckmdxolwenvk.supabase.co';
const String supabaseAnonKey = 'sb_publishable_6yYdqREcVbFa_65ARl1EWA_rGjENe1n';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _initBackend();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initBackend() async {
    try {
      if (supabaseUrl.startsWith('http')) {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        ).timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Supabase init notice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) => CustomPaint(
                  painter: BackgroundAnimationPainter(_animController.value),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Color(0x331E3A8A), blurRadius: 15, offset: Offset(0, 6))
                            ],
                          ),
                          child: const Icon(Icons.school_rounded, color: Colors.white, size: 44),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'S.S.D. CONVENT SCHOOL',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F1E36),
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Knowledge • Discipline • Future',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(color: Color(0x29000000), blurRadius: 16, offset: Offset(0, 8))
                            ],
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.apartment_rounded, color: Colors.white, size: 54),
                              SizedBox(height: 12),
                              Text(
                                'S.S.D. CONVENT CAMPUS',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Family Information Portal',
                                style: TextStyle(color: Color(0xFF93C5FD), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F1E36),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F1E36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SchoolDiscoveryScreen()),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Explore School & Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '© S.S.D. Convent School • Secure Access',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundAnimationPainter extends CustomPainter {
  final double progress;
  BackgroundAnimationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final orb1X = w * 0.25 + math.cos(progress * 2 * math.pi) * 35;
    final orb1Y = h * 0.22 + math.sin(progress * 2 * math.pi) * 30;
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3B82F6).withOpacity(0.18),
          const Color(0xFF3B82F6).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(orb1X, orb1Y), radius: 140));
    canvas.drawCircle(Offset(orb1X, orb1Y), 140, paint1);

    final orb2X = w * 0.8 + math.sin(progress * 2 * math.pi) * 30;
    final orb2Y = h * 0.5 + math.cos(progress * 2 * math.pi) * 35;
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF59E0B).withOpacity(0.12),
          const Color(0xFFF59E0B).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(orb2X, orb2Y), radius: 120));
    canvas.drawCircle(Offset(orb2X, orb2Y), 120, paint2);

    final orb3X = w * 0.15 + math.sin(progress * 2 * math.pi + 1) * 25;
    final orb3Y = h * 0.65 + math.cos(progress * 2 * math.pi + 1) * 25;
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF60A5FA).withOpacity(0.14),
          const Color(0xFF60A5FA).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(orb3X, orb3Y), radius: 110));
    canvas.drawCircle(Offset(orb3X, orb3Y), 110, paint3);

    final particlePaint = Paint()..style = PaintingStyle.fill;
    final particles = [
      Offset(w * 0.15, h * 0.15),
      Offset(w * 0.85, h * 0.18),
      Offset(w * 0.12, h * 0.45),
      Offset(w * 0.88, h * 0.38),
      Offset(w * 0.35, h * 0.72),
      Offset(w * 0.78, h * 0.70),
    ];

    for (int i = 0; i < particles.length; i++) {
      final double offsetPhase = i * (math.pi / 3);
      final double dy = math.sin((progress * 2 * math.pi) + offsetPhase) * 12;
      final double dx = math.cos((progress * 2 * math.pi) + offsetPhase) * 8;
      final double opacity = 0.25 + 0.25 * math.sin((progress * 2 * math.pi) + offsetPhase);

      particlePaint.color = (i % 2 == 0 ? const Color(0xFF1E3A8A) : const Color(0xFFD97706))
          .withOpacity(opacity.clamp(0.0, 1.0));

      canvas.drawCircle(
        Offset(particles[i].dx + dx, particles[i].dy + dy),
        3.0 + (i % 3),
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundAnimationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
