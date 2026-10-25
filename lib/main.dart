import 'dart:async';
import 'package:flutter/material.dart';
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
      systemNavigationBarColor: Color(0xFF030914),
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
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.S.D. Convent School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF040A17),
        fontFamily: 'sans-serif',
      ),
      home: SchoolPortalHomeScreen(
        isDark: _isDark,
        onToggleTheme: () => setState(() => _isDark = !_isDark),
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
    return Scaffold(
      backgroundColor: const Color(0xFF040A17),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TOP BAR =================
              _buildTopBar(),

              const SizedBox(height: 8),

              // ================= HERO BANNER SLIDESHOW =================
              _buildHeroSlideCard(),

              const SizedBox(height: 22),

              // ================= SECTION HEADER =================
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
                        const Text(
                          'Campus Directory & Helpline',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 11),
                      child: Text(
                        'Quick access to important contacts and campus information.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ================= 4 VIBRANT COLORFUL CARDS (2x2) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    // ROW 1: EMERALD GREEN (Phone) + CRIMSON RED (Exact Maps Location)
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
                            onTap: () => _openUrl('https://maps.app.goo.gl/nY78gwbSR8aiYyJFA?g_st=ac'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ROW 2: OCEAN BLUE (Visiting Hours) + ROYAL PURPLE (Updated Official Email)
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

              // ================= DUAL PILL BUTTONS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPillBar(
                        icon: Icons.phone_rounded,
                        label: 'Call School Office',
                        accent: const Color(0xFF38BDF8),
                        onTap: () => _openUrl('tel:+917880884750'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPillBar(
                        icon: Icons.chat_rounded,
                        label: 'WhatsApp Chat',
                        accent: const Color(0xFF10B981),
                        onTap: () => _openUrl('https://wa.me/917880884750'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= BIG GLOWING LOGIN BUTTON =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x662563EB),
                        blurRadius: 20,
                        offset: Offset(0, 8),
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
                        Icon(Icons.login_rounded,
                            color: Colors.white, size: 20),
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

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOP HEADER BAR =================
  Widget _buildTopBar() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'S.S.D. Convent School',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Family Information Portal',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2342),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: Color(0xFFFDE68A),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2342),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 18,
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF071426),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
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

// ================= NATIVE LOGIN SCREEN =================
class NativeLoginScreen extends StatefulWidget {
  const NativeLoginScreen({super.key});

  @override
  State<NativeLoginScreen> createState() => _NativeLoginScreenState();
}

class _NativeLoginScreenState extends State<NativeLoginScreen> {
  int _activeTab = 0;
  bool _obscure = true;
  final TextEditingController _id = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  @override
  void dispose() {
    _id.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF040A17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Family Portal Login',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
              const Center(
                child: Text(
                  'Welcome to S.S.D. Portal',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Sign in to access student grades, fees & records',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF09162A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
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
                                  : Colors.white60,
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
                                  : Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text('Registered ID / Mobile Number',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCBD5E1))),
              const SizedBox(height: 6),
              TextField(
                controller: _id,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF071426),
                  hintText: 'e.g. SSD2026/0412 or 9876543210',
                  hintStyle:
                      const TextStyle(color: Colors.white24, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.person_rounded,
                      color: Color(0xFF38BDF8), size: 18),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              const SizedBox(height: 16),
              const Text('Password',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCBD5E1))),
              const SizedBox(height: 6),
              TextField(
                controller: _pass,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF071426),
                  hintText: 'Enter your password',
                  hintStyle:
                      const TextStyle(color: Colors.white24, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.lock_rounded,
                      color: Color(0xFF38BDF8), size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              const SizedBox(height: 20),
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
                  onPressed: () {
                    if (_id.text.isEmpty || _pass.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter ID and password'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verifying credentials...'),
                        backgroundColor: Color(0xFF2563EB),
                      ),
                    );
                  },
                  child: const Text('Sign In',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
