import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF060D17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SSDConventNativeApp());
}

class SSDConventNativeApp extends StatelessWidget {
  const SSDConventNativeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.S.D. Convent School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060D17),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF0A192F),
        ),
      ),
      home: const SchoolDashboardScreen(),
    );
  }
}

class SchoolDashboardScreen extends StatefulWidget {
  const SchoolDashboardScreen({super.key});

  @override
  State<SchoolDashboardScreen> createState() => _SchoolDashboardScreenState();
}

class _SchoolDashboardScreenState extends State<SchoolDashboardScreen> {
  int _currentTabIndex = 0;

  Future<void> _launchPortalUrl(String path) async {
    final uri = Uri.parse('https://ssdconvent.pages.dev$path');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  void _showNoticeDetail(String title, String date, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A192F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0x33D4AF37), width: 1),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign_rounded, color: Color(0xFFD4AF37), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(date, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF060D17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close Notice', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D17),
      body: SafeArea(
        child: Column(
          children: [
            // ================= 1. EXECUTIVE HEADER =================
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0A192F),
                border: Border(
                  bottom: BorderSide(color: Color(0x2BD4AF37), width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // School Crest / Logo Badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
                      color: const Color(0xFF0F2444),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.school_rounded,
                          color: Color(0xFFD4AF37),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // School Titles
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'S.S.D. CONVENT',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Excellence in Education',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Helpline Call Button
                  IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFD4AF37)),
                    tooltip: 'Call School Desk',
                    onPressed: () async {
                      final uri = Uri.parse('tel:+919876543210');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                  ),
                ],
              ),
            ),

            // ================= 2. DASHBOARD BODY =================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. VIP School Welcome Hero Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0F2544), Color(0xFF0A192F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x33D4AF37), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0x26D4AF37),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0x80D4AF37)),
                                ),
                                child: const Text(
                                  'ACADEMIC YEAR 2026-27',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Icon(Icons.verified_rounded, color: Color(0xFFD4AF37), size: 18),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Welcome to S.S.D. Convent',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Empowering young minds with modern knowledge, ethical values, and disciplined growth.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF060D17),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onPressed: () => _launchPortalUrl(''),
                            icon: const Icon(Icons.language_rounded, size: 16),
                            label: const Text(
                              'Open Full Web Portal',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // B. Quick Action Navigation Grid
                    const Text(
                      'QUICK ACTIONS',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        _buildActionTile(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Fee Payment',
                          subtitle: 'Online Receipts',
                          onTap: () => _launchPortalUrl('/fee'),
                        ),
                        _buildActionTile(
                          icon: Icons.calendar_today_rounded,
                          title: 'Attendance',
                          subtitle: 'Daily Records',
                          onTap: () => _launchPortalUrl('/attendance'),
                        ),
                        _buildActionTile(
                          icon: Icons.assignment_rounded,
                          title: 'Examination',
                          subtitle: 'Datesheet & Marks',
                          onTap: () => _launchPortalUrl('/exam'),
                        ),
                        _buildActionTile(
                          icon: Icons.photo_library_rounded,
                          title: 'Campus Gallery',
                          subtitle: 'Events & Sports',
                          onTap: () => _launchPortalUrl('/gallery'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // C. Live Digital Notice Board
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CAMPUS NOTICES',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _launchPortalUrl('/notices'),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _buildNoticeCard(
                      tag: 'EXAMS',
                      title: 'Annual Periodic Assessment Schedule',
                      date: 'Oct 20, 2026',
                      onTap: () => _showNoticeDetail(
                        'Annual Periodic Assessment Schedule',
                        'Oct 20, 2026',
                        'The examination timetable for Classes 1 to 12 has been officially published. Parents and students are requested to review the datesheet and syllabus details on the portal.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildNoticeCard(
                      tag: 'HOLIDAY',
                      title: 'School Closure for Festive Break',
                      date: 'Oct 18, 2026',
                      onTap: () => _showNoticeDetail(
                        'School Closure for Festive Break',
                        'Oct 18, 2026',
                        'The school will remain closed for the upcoming festive holidays. Normal classroom sessions will resume following the festive break as per regular schedules.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= 3. EXECUTIVE BOTTOM DOCK =================
            Container(
              height: 62,
              decoration: const BoxDecoration(
                color: Color(0xFF0A192F),
                border: Border(top: BorderSide(color: Color(0x2BD4AF37), width: 1.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
                  _buildBottomNavItem(1, Icons.campaign_rounded, 'Notices'),
                  _buildBottomNavItem(2, Icons.account_balance_wallet_rounded, 'Fees'),
                  _buildBottomNavItem(3, Icons.person_rounded, 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0A192F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AD4AF37), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x1AD4AF37),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeCard({
    required String tag,
    required String title,
    required String date,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A192F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1F334155)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x26D4AF37),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF475569), size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
        if (index == 1) _launchPortalUrl('/notices');
        if (index == 2) _launchPortalUrl('/fee');
        if (index == 3) _launchPortalUrl('/profile');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF475569),
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF475569),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
