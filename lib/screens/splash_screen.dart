import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'school_discovery_screen.dart';
import 'dashboard_screen.dart';
import 'admin_hub_screen.dart';

const String supabaseUrl = 'https://shlzyjkkckmdxolwenvk.supabase.co';
const String supabaseAnonKey = 'sb_publishable_6yYdqREcVbFa_65ARl1EWA_rGjENe1n';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _entranceController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _fadeIn = CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
    _initApp();
  }

  @override
  void dispose() {
    _animController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
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

    // CHECK REMEMBERED LOGIN SESSION
    try {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('saved_user_type');

      if (userType == 'parent') {
        final rawStudent = prefs.getString('saved_student_data');
        if (rawStudent != null && mounted) {
          final studentData = jsonDecode(rawStudent) as Map<String, dynamic>;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => DashboardScreen(studentData: studentData)),
            (route) => false,
          );
          return;
        }
      } else if (userType == 'admin') {
        final client = Supabase.instance.client;
        if (client.auth.currentSession != null && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminHubScreen()),
            (route) => false,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Auto-login check notice: $e');
    }

    if (mounted) {
      setState(() => _isCheckingSession = false);
    }
  }

  void _navigateToDiscovery() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => const SchoolDiscoveryScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
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
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            // Status Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.18)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'SMART DIGITAL CAMPUS • PRAYAGRAJ',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E3A8A),
                                      letterSpacing: 0.9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Institutional Crest Emblem
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E40AF), Color(0xFF0F1E36)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x3D1E3A8A),
                                    blurRadius: 24,
                                    offset: Offset(0, 10),
                                  )
                                ],
                                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.45), width: 1.5),
                              ),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 46),
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'S.S.D. CONVENT SCHOOL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F1E36),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Knowledge • Discipline • Future',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Premium Showcase Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x290F1E36),
                                    blurRadius: 22,
                                    offset: Offset(0, 12),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.apartment_rounded, color: Color(0xFFFBBF24), size: 42),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'S.S.D. CONVENT CAMPUS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Champapur, Handia Road, Janghai, Prayagraj',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFF93C5FD), fontSize: 12),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _SplashHighlightItem(icon: Icons.verified_rounded, label: 'Attendance'),
                                        _SplashHighlightItem(icon: Icons.receipt_long_rounded, label: 'Fee Ledger'),
                                        _SplashHighlightItem(icon: Icons.workspace_premium_rounded, label: 'Report Cards'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom Action Dock
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F1E36),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(color: Color(0x26000000), blurRadius: 20, offset: Offset(0, -4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0F1E36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              onPressed: _navigateToDiscovery,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isCheckingSession) ...[
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF1E3A8A)),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  const Text(
                                    'Explore School & Portal',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 19),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '© S.S.D. Convent School • Cloud Verified Portal',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashHighlightItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SplashHighlightItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFBBF24), size: 15),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
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
