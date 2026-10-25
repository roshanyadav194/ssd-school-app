import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF040C1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SSDConventApp());
}

class SSDConventApp extends StatefulWidget {
  const SSDConventApp({super.key});

  @override
  State<SSDConventApp> createState() => _SSDConventAppState();
}

class _SSDConventAppState extends State<SSDConventApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.S.D. Convent School',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        primaryColor: const Color(0xFF1D4ED8),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF040D1A),
        primaryColor: const Color(0xFF2563EB),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeHeroIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<Map<String, String>> _heroBanners = [
    {
      'tag': 'LEARN • GROW • ACHIEVE',
      'title': 'A brighter future\nstarts here.',
      'desc':
          'Champapur, Janghai, Prayagraj — A modern space where students learn with confidence, curiosity, and care.',
    },
    {
      'tag': 'SMART DIGITAL CAMPUS',
      'title': 'Empowering Minds,\nShaping Future.',
      'desc':
          'Holistic academic excellence, state-of-the-art computer labs, science innovation, and rich moral discipline.',
    },
    {
      'tag': 'LEADERSHIP & VALUES',
      'title': 'Excellence in every\nendeavor.',
      'desc':
          'Nurturing students to become confident, compassionate, and visionary leaders in academics and life.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int next = (_activeHeroIndex + 1) % _heroBanners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showVisitingHoursDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A192F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 0.8),
        ),
        title: const Row(
          children: [
            Icon(Icons.schedule_rounded, color: Color(0xFF38BDF8), size: 24),
            SizedBox(width: 10),
            Text(
              'Campus Visiting Hours',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Monday - Saturday:', '8:00 AM - 2:00 PM'),
            const SizedBox(height: 8),
            _buildDialogRow('Sunday & Holidays:', 'Closed'),
            const SizedBox(height: 8),
            _buildDialogRow('Principal Meeting:', '10:00 AM - 12:30 PM'),
            const SizedBox(height: 14),
            const Text(
              'Parents and visitors are requested to collect a visitor entry pass from the main reception desk.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF38BDF8),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TOP HEADER =================
              _buildTopHeader(),

              const SizedBox(height: 14),

              // ================= HERO BANNER =================
              _buildHeroBanner(),

              const SizedBox(height: 22),

              // ================= SECTION TITLE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Campus Directory & Helpline',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        'Quick access to important contacts and campus information.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= 4 DIRECTORY CARDS (2x2 GRID) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // ROW 1: Phone Helpline & Campus Location
                    Row(
                      children: [
                        Expanded(
                          child: _buildDirectoryCard(
                            glowColor: const Color(0xFF10B981),
                            icon: Icons.phone_in_talk_rounded,
                            iconBg: const Color(0xFF064E3B),
                            title: 'Phone Helpline',
                            details: '+91 78808 84750\n+91 85608 22342',
                            buttonText: 'Call Now',
                            buttonIcon: Icons.call_rounded,
                            onTap: () => _launchExternal('tel:+917880884750'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDirectoryCard(
                            glowColor: const Color(0xFFF43F5E),
                            icon: Icons.location_on_rounded,
                            iconBg: const Color(0xFF881337),
                            title: 'Campus Location',
                            details:
                                'Champapur, Handia Rd,\nJanghai, Prayagraj',
                            buttonText: 'Open in Maps',
                            buttonIcon: Icons.map_rounded,
                            onTap: () => _launchExternal(
                                'https://maps.google.com/?q=Champapur+Janghai+Prayagraj'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ROW 2: Visiting Hours & Official Email
                    Row(
                      children: [
                        Expanded(
                          child: _buildDirectoryCard(
                            glowColor: const Color(0xFF38BDF8),
                            icon: Icons.schedule_rounded,
                            iconBg: const Color(0xFF0C4A6E),
                            title: 'Visiting Hours',
                            details:
                                'Mon - Sat:\n8:00 AM - 2:00 PM\n(Closed Sundays)',
                            buttonText: 'View Details',
                            buttonIcon: Icons.calendar_today_rounded,
                            onTap: _showVisitingHoursDialog,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDirectoryCard(
                            glowColor: const Color(0xFFA855F7),
                            icon: Icons.email_rounded,
                            iconBg: const Color(0xFF581C87),
                            title: 'Official Email',
                            details:
                                'info@ssdconvent.com\nPrincipal & Admin Desk',
                            buttonText: 'Send Email',
                            buttonIcon: Icons.send_rounded,
                            onTap: () => _launchExternal(
                                'mailto:info@ssdconvent.com?subject=Inquiry regarding S.S.D. Convent School'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= TWO BOTTOM PILL BUTTONS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBottomPillButton(
                        icon: Icons.phone_rounded,
                        label: 'Call School Office',
                        accentColor: const Color(0xFF38BDF8),
                        onTap: () => _launchExternal('tel:+917880884750'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBottomPillButton(
                        icon: Icons.chat_rounded,
                        label: 'WhatsApp Chat',
                        accentColor: const Color(0xFF10B981),
                        onTap: () =>
                            _launchExternal('https://wa.me/917880884750'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= LOGIN TO FAMILY PORTAL BUTTON =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF1D4ED8),
                        Color(0xFF38BDF8)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x662563EB),
                        blurRadius: 18,
                        offset: Offset(0, 6),
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
                          builder: (context) => const LoginPortalScreen(),
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
                            letterSpacing: 0.5,
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

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOP APP BAR =================
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Circular School Emblem
          Container(
            width: 46,
            height: 46,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD6AD55), width: 1.5),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40D6AD55),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFFD6AD55),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          // Title + Subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'S.S.D. Convent School',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Family Information Portal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'LEARN  •  GROW  •  ACHIEVE',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFFD6AD55),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Theme Toggle Switch
          GestureDetector(
            onTap: widget.onToggleTheme,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF0F223D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(
                widget.isDarkMode
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
                color: const Color(0xFFFDE68A),
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Menu Icon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF0F223D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  // ================= HERO BANNER CARD =================
  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2246), Color(0xFF06152C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x3338BDF8), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x400A2246),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _activeHeroIndex = i),
            itemCount: _heroBanners.length,
            itemBuilder: (context, i) {
              final item = _heroBanners[i];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Text Column
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x26FDE68A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school_outlined,
                                    size: 12, color: Color(0xFFFDE68A)),
                                const SizedBox(width: 5),
                                Text(
                                  item['tag']!,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFDE68A),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFCBD5E1),
                              height: 1.35,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Campus Image Container
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0x4038BDF8), width: 1.5),
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
                                color: const Color(0xFF0B1E38),
                                child: const Center(
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    size: 56,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'SSD CAMPUS',
                                    style: TextStyle(
                                      fontSize: 9,
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
          // Pagination Indicator Dots
          Positioned(
            bottom: 12,
            left: 20,
            child: Row(
              children: List.generate(
                _heroBanners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 5),
                  width: _activeHeroIndex == i ? 18 : 6,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _activeHeroIndex == i
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

  // ================= 2x2 DIRECTORY CARDS =================
  Widget _buildDirectoryCard({
    required Color glowColor,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String details,
    required String buttonText,
    required IconData buttonIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A182E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: glowColor.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: glowColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            details,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFCBD5E1),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: glowColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: glowColor.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(buttonIcon, size: 12, color: glowColor),
                      const SizedBox(width: 5),
                      Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: glowColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: glowColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM PILL BUTTONS =================
  Widget _buildBottomPillButton({
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF091629),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_rounded,
                size: 14, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

// ================= LOGIN TO FAMILY PORTAL SCREEN =================
class LoginPortalScreen extends StatefulWidget {
  const LoginPortalScreen({super.key});

  @override
  State<LoginPortalScreen> createState() => _LoginPortalScreenState();
}

class _LoginPortalScreenState extends State<LoginPortalScreen> {
  int _selectedTab = 0; // 0: Student / Parent, 1: Teacher / Staff
  bool _obscurePassword = true;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final id = _idController.text.trim();
    final pass = _passwordController.text.trim();

    if (id.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Registered ID / Mobile and Password.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verifying $_idController with Family Portal...'),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF040D1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Family Portal Login',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD6AD55), width: 2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF06152C)],
                    ),
                  ),
                  child: const Icon(Icons.lock_person_rounded,
                      color: Color(0xFFD6AD55), size: 36),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Welcome to S.S.D. Family Portal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Access attendance, report cards, fee receipts & notices',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 28),

              // Segmented Tab (Parent/Student vs Staff)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1E38),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? const Color(0xFF2563EB)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Student / Parent',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? const Color(0xFF2563EB)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Teacher / Staff',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // User ID / Admission Number
              const Text(
                'Admission No. / Registered Mobile',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _idController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0B1E38),
                  hintText: 'e.g., SSD2026/0412 or 9876543210',
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  prefixIcon: const Icon(Icons.person_rounded,
                      color: Color(0xFF38BDF8), size: 20),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Password / PIN
              const Text(
                'Password / Security PIN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0B1E38),
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: Color(0xFF38BDF8), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please contact school administration desk to reset credentials.'),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _handleLogin,
                  child: const Text(
                    'Sign In to Portal',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Help contact
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
