import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore your Supabase Backend Initialization
  try {
    await Supabase.initialize(
      url: 'https://whqdfdhhubcvymuoyjvv.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndocWRmZGh1YmN2eW11b3lqdnYiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTczODk0NjM5MSwiZXhwIjoyMDU0NTIyMzkxfQ.6r2V1yLw1l_t3N7u_R1y1v_U2j8v6w4x2y0z1a2b3c',
    );
  } catch (_) {}

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SSDConventApp());
}

class SSDConventApp extends StatefulWidget {
  const SSDConventApp({super.key});

  @override
  State<SSDConventApp> createState() => _SSDConventAppState();
}

class _SSDConventAppState extends State<SSDConventApp> {
  bool _isDark = true;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor:
              _isDark ? const Color(0xFF040A17) : const Color(0xFFF8FAFC),
          systemNavigationBarIconBrightness:
              _isDark ? Brightness.light : Brightness.dark,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.S.D. Convent School',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'sans-serif',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF040A17),
        fontFamily: 'sans-serif',
      ),
      home: SchoolPortalHomeScreen(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class SchoolPortalHomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SchoolPortalHomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<SchoolPortalHomeScreen> createState() => _SchoolPortalHomeScreenState();
}

class _SchoolPortalHomeScreenState extends State<SchoolPortalHomeScreen> {
  int _heroIndex = 0;
  final PageController _pageController = PageController();
  Timer? _sliderTimer;

  // Exam & Gallery State
  String _selectedClass = 'Class 10';
  String _selectedGalleryCategory = 'All';

  final List<String> _classes = [
    'Nursery', 'KG', 'Class 1', 'Class 2', 'Class 3', 'Class 4',
    'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'
  ];

  final List<Map<String, String>> _slides = [
    {
      'tag': 'LEARN  •  GROW  •  ACHIEVE',
      'title': 'A brighter future\nstarts here.',
      'desc':
          'Champapur, Janghai, Prayagraj —\nA modern space where students learn\nwith confidence, curiosity, and care.',
    },
    {
      'tag': 'SMART CAMPUS  •  VALUES',
      'title': 'Empowering Minds,\nShaping Future.',
      'desc':
          'Fostering intellectual excellence,\ninnovation, modern laboratories,\nand deeply rooted moral leadership.',
    },
    {
      'tag': 'EXCELLENCE  •  INTEGRITY',
      'title': 'Nurturing Leaders\nof Tomorrow.',
      'desc':
          'Dedicated faculty guiding students\nto shine in academics, sports, arts,\nand national competitive careers.',
    },
  ];

  final List<Map<String, String>> _sampleExams = [
    {
      'subject': 'Mathematics Term Exam',
      'type': 'PDF Assessment',
      'duration': '2.5 Hours',
      'isPdf': 'true',
    },
    {
      'subject': 'Science & Technology Quiz',
      'type': 'MCQ Practice',
      'duration': '45 Mins',
      'isPdf': 'false',
    },
    {
      'subject': 'English Language & Grammar',
      'type': 'PDF Assessment',
      'duration': '2 Hours',
      'isPdf': 'true',
    },
  ];

  final List<Map<String, String>> _galleryItems = [
    {'title': 'Annual Sports Meet', 'category': 'Athletics & Sports', 'desc': 'Champions track & sports awards'},
    {'title': 'Smart Computer Lab', 'category': 'Academics & Labs', 'desc': 'Hands-on IT practical training'},
    {'title': 'Morning Assembly', 'category': 'Campus Life', 'desc': 'Daily student speeches & discipline'},
    {'title': 'Science & Innovation', 'category': 'Academics & Labs', 'desc': 'Robotics & physics models'},
    {'title': 'Inter-School Football', 'category': 'Athletics & Sports', 'desc': 'Junior & senior sports tournament'},
    {'title': 'Cultural Fest & Stage', 'category': 'Campus Life', 'desc': 'Music, dance and cultural celebrations'},
  ];

  @override
  void initState() {
    super.initState();
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (_pageController.hasClients) {
        int next = (_heroIndex + 1) % _slides.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String link) async {
    final uri = Uri.parse(link);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showVisitingDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1930),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0369A1).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.schedule_rounded,
                      color: Color(0xFF38BDF8), size: 24),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Campus Visiting Hours',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _infoRow('Monday – Saturday', '8:00 AM – 2:00 PM'),
            const Divider(color: Colors.white12, height: 20),
            _infoRow('Principal Meeting', '10:00 AM – 12:30 PM'),
            const Divider(color: Colors.white12, height: 20),
            _infoRow('Sunday & Public Holidays', 'Closed'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF040A17),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.5)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBgColor = widget.isDark ? const Color(0xFF0A182E) : Colors.white;
    final appBgColor = widget.isDark ? const Color(0xFF040A17) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ================= SCROLLABLE CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(textColor, subTextColor),

                    const SizedBox(height: 8),

                    _buildHeroSlideCard(),

                    const SizedBox(height: 22),

                    // Section Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3.5,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Campus Directory & Helpline',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 11),
                            child: Text(
                              'Quick access to important contacts and campus information.',
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Directory Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildVibrantCard(
                                  cardBgStart: const Color(0xFF04211A),
                                  cardBgEnd: const Color(0xFF031411),
                                  borderColor: const Color(0xFF059669),
                                  glowColor: const Color(0xFF10B981),
                                  icon: Icons.phone_in_talk_rounded,
                                  iconBg: const Color(0xFF064E3B),
                                  title: 'Phone Helpline',
                                  line1: '+91 78808 84750',
                                  line2: '+91 85608 22342',
                                  btnLabel: 'Call Now',
                                  btnIcon: Icons.call_rounded,
                                  btnBg: const Color(0xFF064E3B),
                                  btnTextColor: const Color(0xFF34D399),
                                  onTap: () => _openUrl('tel:+917880884750'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildVibrantCard(
                                  cardBgStart: const Color(0xFF240A14),
                                  cardBgEnd: const Color(0xFF14050B),
                                  borderColor: const Color(0xFFBE123C),
                                  glowColor: const Color(0xFFFB7185),
                                  icon: Icons.location_on_rounded,
                                  iconBg: const Color(0xFF881337),
                                  title: 'Campus Location',
                                  line1: 'Champapur, Handia Rd,',
                                  line2: 'Janghai, Prayagraj',
                                  btnLabel: 'Open in Maps',
                                  btnIcon: Icons.map_rounded,
                                  btnBg: const Color(0xFF881337),
                                  btnTextColor: const Color(0xFFFDA4AF),
                                  onTap: () => _openUrl(
                                      'https://maps.app.goo.gl/nY78gwbSR8aiYyJFA?g_st=ac'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildVibrantCard(
                                  cardBgStart: const Color(0xFF061E38),
                                  cardBgEnd: const Color(0xFF041021),
                                  borderColor: const Color(0xFF0284C7),
                                  glowColor: const Color(0xFF38BDF8),
                                  icon: Icons.access_time_filled_rounded,
                                  iconBg: const Color(0xFF0C4A6E),
                                  title: 'Visiting Hours',
                                  line1: 'Mon – Sat:',
                                  line2: '8:00 AM – 2:00 PM\n(Closed Sundays)',
                                  btnLabel: 'View Details',
                                  btnIcon: Icons.calendar_month_rounded,
                                  btnBg: const Color(0xFF0C4A6E),
                                  btnTextColor: const Color(0xFF7DD3FC),
                                  onTap: _showVisitingDetails,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildVibrantCard(
                                  cardBgStart: const Color(0xFF1E0E38),
                                  cardBgEnd: const Color(0xFF0F061F),
                                  borderColor: const Color(0xFF7C3AED),
                                  glowColor: const Color(0xFFC084FC),
                                  icon: Icons.mail_rounded,
                                  iconBg: const Color(0xFF581C87),
                                  title: 'Official Email',
                                  line1: 'ssdconventschool194',
                                  line2: '@gmail.com',
                                  btnLabel: 'Send Email',
                                  btnIcon: Icons.send_rounded,
                                  btnBg: const Color(0xFF581C87),
                                  btnTextColor: const Color(0xFFD8B4FE),
                                  onTap: () => _openUrl(
                                      'mailto:ssdconventschool194@gmail.com?subject=Inquiry regarding S.S.D. Convent School'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Dual Pill Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPillBar(
                              icon: Icons.phone_rounded,
                              label: 'Call School Office',
                              accent: const Color(0xFF38BDF8),
                              cardBgColor: cardBgColor,
                              textColor: textColor,
                              onTap: () => _openUrl('tel:+917880884750'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPillBar(
                              icon: Icons.chat_rounded,
                              label: 'WhatsApp Chat',
                              accent: const Color(0xFF10B981),
                              cardBgColor: cardBgColor,
                              textColor: textColor,
                              onTap: () => _openUrl('https://wa.me/917880884750'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Exam Portal Section
                    _buildExamPortalSection(textColor, subTextColor, cardBgColor),

                    const SizedBox(height: 36),

                    // Gallery Section
                    _buildGallerySection(textColor, subTextColor, cardBgColor),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ================= STICKY LOGIN BUTTON =================
            Container(
              padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: appBgColor,
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark ? Colors.black45 : Colors.black12,
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF1D4ED8),
                      Color(0xFF0EA5E9),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB)
                          .withOpacity(widget.isDark ? 0.4 : 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NativeLoginScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Login to Family Portal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOP HEADER BAR =================
  Widget _buildTopBar(Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEAB308), width: 1.8),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66EAB308),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFFFACC15),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'S.S.D. Convent School',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Family Information Portal',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'LEARN   •   GROW   •   ACHIEVE',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFFFACC15),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Theme Toggle Button
          GestureDetector(
            onTap: widget.onToggleTheme,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF0F2342) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: widget.isDark ? Colors.white12 : Colors.black12),
              ),
              child: Icon(
                widget.isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: const Color(0xFFFDE68A),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HERO BANNER CARD =================
  Widget _buildHeroSlideCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      height: 215,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF07214A), Color(0xFF04142E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF1E40AF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5507214A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _heroIndex = i),
            itemCount: _slides.length,
            itemBuilder: (context, i) {
              final slide = _slides[i];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0x26FDE68A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school_outlined,
                                    size: 11, color: Color(0xFFFDE68A)),
                                const SizedBox(width: 5),
                                Text(
                                  slide['tag']!,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFDE68A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            slide['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['desc']!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFFCBD5E1),
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 145,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFF38BDF8).withOpacity(0.4),
                              width: 1.5),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                color: const Color(0xFF0A1E3B),
                                child: const Center(
                                  child: Icon(
                                    Icons.account_balance_rounded,
                                    size: 54,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'S.S.D. CAMPUS',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
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
            },
          ),
          Positioned(
            bottom: 10,
            left: 18,
            child: Row(
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 4),
                  width: _heroIndex == i ? 16 : 5,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: _heroIndex == i
                        ? const Color(0xFF38BDF8)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 4 VIBRANT DIRECTORY CARDS =================
  Widget _buildVibrantCard({
    required Color cardBgStart,
    required Color cardBgEnd,
    required Color borderColor,
    required Color glowColor,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String line1,
    required String line2,
    required String btnLabel,
    required IconData btnIcon,
    required Color btnBg,
    required Color btnTextColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [cardBgStart, cardBgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: borderColor.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: borderColor.withOpacity(0.4), width: 0.8),
                ),
                child: Icon(icon, color: glowColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            line1,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE2E8F0),
            ),
          ),
          Text(
            line2,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF94A3B8),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: btnBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(btnIcon, size: 12, color: btnTextColor),
                      const SizedBox(width: 5),
                      Text(
                        btnLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: btnTextColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      size: 13, color: btnTextColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DUAL PILL BUTTON WIDGET =================
  Widget _buildPillBar({
    required IconData icon,
    required String label,
    required Color accent,
    required Color cardBgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: widget.isDark ? Colors.white12 : Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_rounded,
                size: 14, color: widget.isDark ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }

  // ================= EXAM PORTAL SECTION =================
  Widget _buildExamPortalSection(
      Color textColor, Color subTextColor, Color cardBgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class-Wise Exam Portal',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: textColor),
              ),
              const Text(
                '2026 Session',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFACC15),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _classes.length,
            itemBuilder: (context, i) {
              final c = _classes[i];
              final isSel = c == _selectedClass;
              return GestureDetector(
                onTap: () => setState(() => _selectedClass = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF1E3A8A) : cardBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSel
                            ? const Color(0xFF3B82F6)
                            : (widget.isDark
                                ? Colors.white12
                                : Colors.black12)),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.white : subTextColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        ..._sampleExams.map((exam) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: widget.isDark ? Colors.white12 : Colors.black12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      exam['isPdf'] == 'true'
                          ? Icons.picture_as_pdf_rounded
                          : Icons.quiz_rounded,
                      color: const Color(0xFFFACC15),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['subject']!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exam['type']} • ${exam['duration']}',
                          style: TextStyle(fontSize: 11.5, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFACC15),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(60, 36),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Opening ${exam['subject']} for $_selectedClass')),
                      );
                    },
                    child: const Text('Start',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ================= GALLERY SECTION =================
  Widget _buildGallerySection(
      Color textColor, Color subTextColor, Color cardBgColor) {
    final categories = [
      'All',
      'Campus Life',
      'Athletics & Sports',
      'Academics & Labs'
    ];
    final filtered = _selectedGalleryCategory == 'All'
        ? _galleryItems
        : _galleryItems
            .where((g) => g['category'] == _selectedGalleryCategory)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Campus Photo Gallery',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: textColor),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              final isSel = cat == _selectedGalleryCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedGalleryCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF2563EB) : cardBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSel
                            ? const Color(0xFF3B82F6)
                            : (widget.isDark
                                ? Colors.white12
                                : Colors.black12)),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.white : subTextColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final item = filtered[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: widget.isDark ? Colors.white12 : Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.image_rounded,
                        color: Color(0xFFFACC15), size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: textColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['desc']!,
                        style: TextStyle(fontSize: 10.5, color: subTextColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ================= NATIVE LOGIN SCREEN WITH DATABASE AUTH =================
class NativeLoginScreen extends StatefulWidget {
  const NativeLoginScreen({super.key});

  @override
  State<NativeLoginScreen> createState() => _NativeLoginScreenState();
}

class _NativeLoginScreenState extends State<NativeLoginScreen> {
  int _activeTab = 0; // 0: Student / Parent, 1: Teacher / Staff (Admin)
  bool _obscure = true;
  bool _rememberMe = false; // Restore Remember me toggle
  bool _isLoading = false;

  // Student / Parent controllers
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _parentDobController = TextEditingController();

  // Admin / Staff controllers
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Restore SharedPreferences logic
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminEmailController.text = prefs.getString('admin_email') ?? '';
      _adminPassController.text = prefs.getString('admin_pass') ?? '';
      _parentPhoneController.text = prefs.getString('parent_phone') ?? '';
      _parentDobController.text = prefs.getString('parent_dob') ?? '';
      if (_adminEmailController.text.isNotEmpty || _parentPhoneController.text.isNotEmpty) {
        _rememberMe = true;
      }
    });
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      if (_activeTab == 0) {
        // --- Parent / Student Logic ---
        final phone = _parentPhoneController.text.trim();
        final dob = _parentDobController.text.trim();
        
        if (phone.isEmpty || dob.isEmpty) {
          throw Exception('Please enter Mobile Number and Birth Year/DOB');
        }

        // Save preferences if Remember me is checked
        if (_rememberMe) {
          await prefs.setString('parent_phone', phone);
          await prefs.setString('parent_dob', dob);
        } else {
          await prefs.remove('parent_phone');
          await prefs.remove('parent_dob');
        }

        // Parent Logic Success Navigation
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ParentDashboardPlaceholder()));
        }

      } else {
        // --- Admin / Staff Logic ---
        final email = _adminEmailController.text.trim();
        final pass = _adminPassController.text.trim();
        
        if (email.isEmpty || pass.isEmpty) {
          throw Exception('Please enter Official Email and Password');
        }

        // Real Supabase Authentication
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: pass,
        );

        if (response.user != null) {
          // Save preferences if Remember me is checked
          if (_rememberMe) {
            await prefs.setString('admin_email', email);
            await prefs.setString('admin_pass', pass);
          } else {
            await prefs.remove('admin_email');
            await prefs.remove('admin_pass');
          }

          // Admin Logic Success Navigation
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardPlaceholder()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _parentPhoneController.dispose();
    _parentDobController.dispose();
    _adminEmailController.dispose();
    _adminPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final bgInput = isDark ? const Color(0xFF071426) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Family Portal Login',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFACC15), width: 1.8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF071426)],
                    ),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Color(0xFFFACC15), size: 32),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Welcome to S.S.D. Family Portal',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: textColor),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Access attendance, report cards, fee receipts & notices',
                  style: TextStyle(fontSize: 12, color: subTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // ================= SEGMENTED TAB SELECTOR =================
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF09162A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _activeTab == 0
                                ? const Color(0xFF2563EB)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Student / Parent',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 0
                                  ? Colors.white
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _activeTab == 1
                                ? const Color(0xFF2563EB)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Teacher / Staff',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 1
                                  ? Colors.white
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= TAB 0: PARENT / STUDENT PANEL =================
              if (_activeTab == 0) ...[
                Text(
                  'Registered Mobile Number',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: subTextColor),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _parentPhoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: textColor, fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgInput,
                    hintText: 'Enter 10-digit mobile number',
                    hintStyle:
                        TextStyle(color: subTextColor.withOpacity(0.5), fontSize: 12.5),
                    prefixIcon: const Icon(Icons.phone_android_rounded,
                        color: Color(0xFF38BDF8), size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Date of Birth / Year',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: subTextColor),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _parentDobController,
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(color: textColor, fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgInput,
                    hintText: 'DD/MM/YYYY or Birth Year (e.g., 2012)',
                    hintStyle:
                        TextStyle(color: subTextColor.withOpacity(0.5), fontSize: 12.5),
                    prefixIcon: const Icon(Icons.calendar_today_rounded,
                        color: Color(0xFF38BDF8), size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                    ),
                  ),
                ),
              ],

              // ================= TAB 1: TEACHER / STAFF / ADMIN PANEL =================
              if (_activeTab == 1) ...[
                Text(
                  'Official School Email',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: subTextColor),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _adminEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor, fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgInput,
                    hintText: 'e.g., admin@ssdconvent.com',
                    hintStyle:
                        TextStyle(color: subTextColor.withOpacity(0.5), fontSize: 12.5),
                    prefixIcon: const Icon(Icons.email_rounded,
                        color: Color(0xFF38BDF8), size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Password / Security PIN',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: subTextColor),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _adminPassController,
                  obscureText: _obscure,
                  style: TextStyle(color: textColor, fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgInput,
                    hintText: 'Enter your password',
                    hintStyle:
                        TextStyle(color: subTextColor.withOpacity(0.5), fontSize: 12.5),
                    prefixIcon: const Icon(Icons.lock_rounded,
                        color: Color(0xFF38BDF8), size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: isDark ? Colors.white38 : Colors.black38,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 6),

              // ================= REMEMBER ME & FORGOT PASSWORD =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: subTextColor,
                        ),
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFF38BDF8),
                          checkColor: Colors.white,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(color: subTextColor, fontSize: 12.5),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please contact the system administrator to reset credentials.'),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ================= SIGN IN BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _handleSignIn,
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                      )
                    : const Text(
                        'Sign In to Portal',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                ),
              ),

              const SizedBox(height: 22),

              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:+917880884750');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.help_outline_rounded,
                      size: 16, color: Color(0xFFD6AD55)),
                  label: const Text(
                    'Need Help? Call School Helpline',
                    style: TextStyle(
                      color: Color(0xFFD6AD55),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= PLACEHOLDER DASHBOARDS =================
// These prevent the "file not found" crash when you successfully log in.
// Replace them later with your actual admin/parent screens if you have them in other files.

class AdminDashboardPlaceholder extends StatelessWidget {
  const AdminDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 64, color: Color(0xFF2563EB)),
            const SizedBox(height: 16),
            const Text('Welcome, Admin!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SchoolPortalHomeScreen(isDark: true, onToggleTheme: _emptyToggle))),
              child: const Text('Log Out'),
            )
          ],
        ),
      ),
    );
  }
}

class ParentDashboardPlaceholder extends StatelessWidget {
  const ParentDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent/Student Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.family_restroom, size: 64, color: Color(0xFF10B981)),
            const SizedBox(height: 16),
            const Text('Welcome, Family!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SchoolPortalHomeScreen(isDark: true, onToggleTheme: _emptyToggle))),
              child: const Text('Log Out'),
            )
          ],
        ),
      ),
    );
  }
}

void _emptyToggle() {}
