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

/// Global Light / Dark Theme Notifier shared across all screens
final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier(ThemeMode.light);

Future<void> toggleSSDTheme() async {
  final isCurrentlyDark = appThemeNotifier.value == ThemeMode.dark;
  appThemeNotifier.value = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ssd_dark_mode', !isCurrentlyDark);
  } catch (_) {}
}

/// Smooth Page Transition Helper (Respects Reduced Motion)
Route<T> createSmoothRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        return child;
      }
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.035),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Reusable Staggered Entrance Wrapper
class StaggeredEntrance extends StatelessWidget {
  final Widget child;
  final int index;
  const StaggeredEntrance({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return child;
    }
    final duration = Duration(milliseconds: 300 + (index.clamp(0, 8) * 55));
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, builtChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: builtChild,
          ),
        );
      },
      child: child,
    );
  }
}

/// Reusable Skeleton Shimmer Loader
class ShimmerPlaceholder extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;
  const ShimmerPlaceholder({
    super.key,
    this.height = 72,
    this.width = double.infinity,
    this.borderRadius = 14,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Color.lerp(
              isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              _ctrl.value,
            ),
          ),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _initApp();
  }

  @override
  void dispose() {
    _animController.dispose();
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
            createSmoothRoute(DashboardScreen(studentData: studentData)),
            (route) => false,
          );
          return;
        }
      } else if (userType == 'admin') {
        final client = Supabase.instance.client;
        if (client.auth.currentSession != null && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            createSmoothRoute(const AdminHubScreen()),
            (route) => false,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Auto-login check notice: $e');
    }

    if (mounted) {
      setState(() => _checkingSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) => CustomPaint(
                  painter: BackgroundAnimationPainter(
                    reduceMotion ? 0.25 : _animController.value,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Theme Switcher Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withOpacity(isDark ? 0.3 : 0.08),
                          borderRadius: BorderRadius.circular(20),
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
                            const SizedBox(width: 6),
                            Text(
                              'SMART CAMPUS CLOUD',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        onPressed: toggleSSDTheme,
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF0F1E36),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StaggeredEntrance(
                          index: 0,
                          child: Container(
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
                                  blurRadius: 22,
                                  offset: Offset(0, 10),
                                )
                              ],
                            ),
                            child: const Icon(Icons.school_rounded, color: Colors.white, size: 46),
                          ),
                        ),
                        const SizedBox(height: 22),
                        StaggeredEntrance(
                          index: 1,
                          child: Text(
                            'S.S.D. CONVENT SCHOOL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F1E36),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        StaggeredEntrance(
                          index: 2,
                          child: Text(
                            'Knowledge • Discipline • Future',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        StaggeredEntrance(
                          index: 3,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: Colors.white.withOpacity(0.12)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x29000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
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
                                  child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 44),
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
                                  'Official Family & Administration Portal',
                                  style: TextStyle(color: Color(0xFF93C5FD), fontSize: 12.5),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildFeatureChip(Icons.verified_rounded, 'Live Attendance'),
                                    _buildFeatureChip(Icons.receipt_long_rounded, 'Digital Receipts'),
                                    _buildFeatureChip(Icons.workspace_premium_rounded, 'Report Cards'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              createSmoothRoute(const SchoolDiscoveryScreen()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_checkingSession) ...[
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                        '© S.S.D. Convent School • Champapur, Janghai, Prayagraj',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
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

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFBBF24), size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
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
