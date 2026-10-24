import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class SchoolDiscoveryScreen extends StatefulWidget {
  const SchoolDiscoveryScreen({super.key});

  @override
  State<SchoolDiscoveryScreen> createState() => _SchoolDiscoveryScreenState();
}

class _SchoolDiscoveryScreenState extends State<SchoolDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _selectedExamClass = 'Class 10th - Board Practice';

  static const List<String> _examClasses = [
    'Class 10th - Board Practice',
    'Class 9th - Comprehensive Term',
    'Class 8th - Science & Math Prep',
    'Class 7th - General Assessment',
    'Class 6th - Fundamental Test',
    'Class 11th / 12th - Senior Stream Assessment',
  ];

  SupabaseClient? get _supabaseClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url')),
        );
      }
    }
  }

  // INTERACTIVE MOCK EXAM HALL MODAL
  void _openInteractiveExamHall() {
    final questions = [
      {
        'q': '1. Which organelle is known as the powerhouse of the cell?',
        'options': ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi Apparatus'],
        'ans': 1,
      },
      {
        'q': '2. If a triangle has angles 60° and 70°, what is the third angle?',
        'options': ['40°', '50°', '60°', '80°'],
        'ans': 1,
      },
      {
        'q': '3. What is the SI unit of electric current?',
        'options': ['Volt', 'Ohm', 'Ampere', 'Watt'],
        'ans': 2,
      },
    ];

    final Map<int, int> selectedAnswers = {};
    bool submitted = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          int score = 0;
          if (submitted) {
            for (int i = 0; i < questions.length; i++) {
              if (selectedAnswers[i] == questions[i]['ans']) score++;
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _selectedExamClass.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'S.S.D. Online Practice Test',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F1E36),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 20),
                if (submitted)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Color(0xFF059669), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Assessment Evaluated! You scored $score / ${questions.length} (${((score / questions.length) * 100).toInt()}%)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, qIdx) {
                      final q = questions[qIdx];
                      final opts = q['options'] as List<String>;
                      final correctIdx = q['ans'] as int;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q['q'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF0F1E36),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...List.generate(opts.length, (optIdx) {
                              final isSelected = selectedAnswers[qIdx] == optIdx;
                              Color borderColor = const Color(0xFFCBD5E1);
                              Color bgColor = Colors.white;
                              if (submitted) {
                                if (optIdx == correctIdx) {
                                  borderColor = const Color(0xFF10B981);
                                  bgColor = const Color(0xFFECFDF5);
                                } else if (isSelected && optIdx != correctIdx) {
                                  borderColor = const Color(0xFFEF4444);
                                  bgColor = const Color(0xFFFEF2F2);
                                }
                              } else if (isSelected) {
                                borderColor = const Color(0xFF1E3A8A);
                                bgColor = const Color(0xFFEFF6FF);
                              }

                              return GestureDetector(
                                onTap: submitted
                                    ? null
                                    : () => setModalState(() => selectedAnswers[qIdx] = optIdx),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        size: 18,
                                        color: isSelected
                                            ? const Color(0xFF1E3A8A)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          opts[optIdx],
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (submitted) {
                        Navigator.pop(ctx);
                      } else {
                        setModalState(() => submitted = true);
                      }
                    },
                    child: Text(
                      submitted ? 'Close Practice Portal' : 'Submit Answers & View Score',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F1E36), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded, color: Color(0xFF1E3A8A), size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'S.S.D. Convent School',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF0F1E36),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== AESTHETIC HERO BANNER ====================
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulse = _pulseController.value;
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(const Color(0xFF0F1E36), const Color(0xFF1E3A8A), pulse)!,
                        const Color(0xFF1E40AF),
                        const Color(0xFF0A1128),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withOpacity(0.25 + 0.1 * pulse),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -25,
                        top: -25,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -35,
                        left: -20,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD97706).withOpacity(0.12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFBBF24).withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'LEARN • GROW • ACHIEVE',
                                style: TextStyle(
                                  color: Color(0xFFFDE68A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'A brighter future\nstarts here.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                height: 1.2,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Champapur, Janghai, Prayagraj — A modern space where students learn with confidence, curiosity, and care.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ==================== CAMPUS HIGHLIGHTS BAR ====================
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBadge(title: 'Nursery–12th', subtitle: 'Classes'),
                  _StatBadge(title: 'Smart Labs', subtitle: 'Infrastructure'),
                  _StatBadge(title: '100% Safe', subtitle: 'Campus & Bus'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Label
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CAMPUS DIRECTORY & HELPLINE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ==================== 2x2 MODERN DIRECTORY CARDS ====================
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _buildModernCard(
                  icon: Icons.phone_in_talk_rounded,
                  iconBg: const Color(0xFF10B981).withOpacity(0.12),
                  iconColor: const Color(0xFF059669),
                  title: 'Phone Helpline',
                  subtitle: '+91 78808 84750\n+91 85608 22342',
                  actionLabel: 'Call Office →',
                  actionColor: const Color(0xFF059669),
                  onTap: () => _launchUrl('tel:+917880884750'),
                ),
                _buildModernCard(
                  icon: Icons.location_on_rounded,
                  iconBg: const Color(0xFFEF4444).withOpacity(0.12),
                  iconColor: const Color(0xFFDC2626),
                  title: 'Campus Location',
                  subtitle: 'Champapur, Handia Rd,\nJanghai, Prayagraj',
                  actionLabel: 'Open in Maps →',
                  actionColor: const Color(0xFFDC2626),
                  onTap: () => _launchUrl('https://maps.google.com/?q=SSD+Convent+School+Janghai+Prayagraj'),
                ),
                _buildModernCard(
                  icon: Icons.access_time_filled_rounded,
                  iconBg: const Color(0xFF3B82F6).withOpacity(0.12),
                  iconColor: const Color(0xFF2563EB),
                  title: 'Visiting Hours',
                  subtitle: 'Mon – Sat:\n8:00 AM – 2:00 PM\n(Closed Sundays)',
                  actionLabel: 'Front Office',
                  actionColor: const Color(0xFF64748B),
                  onTap: null,
                ),
                _buildModernCard(
                  icon: Icons.mark_email_read_rounded,
                  iconBg: const Color(0xFF8B5CF6).withOpacity(0.12),
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Official Email',
                  subtitle: 'info@ssdconvent.com\nPrincipal & Admin Desk',
                  actionLabel: 'Send Email →',
                  actionColor: const Color(0xFF7C3AED),
                  onTap: () => _launchUrl('mailto:info@ssdconvent.com'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================== FAST ACTION BUTTON ROW ====================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F1E36),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.call_rounded, size: 19),
                    label: const Text(
                      'Call School Office',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () => _launchUrl('tel:+917880884750'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
                    label: const Text(
                      'WhatsApp Chat',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () => _launchUrl('https://wa.me/917880884750?text=Hello%20SSD%20Convent%20School'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================== POLISHED EXAM PORTAL TILE ====================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.quiz_rounded, color: Color(0xFFD97706), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ASSESSMENT PORTAL',
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Online Exam & Practice Tests',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F1E36),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select your student class to access timed mock examinations and automatic practice evaluation results.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedExamClass,
                        isExpanded: true,
                        items: _examClasses
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedExamClass = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        'Proceed to Exam Hall',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: _openInteractiveExamHall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================== PUBLIC NOTICE BOARD PREVIEW ====================
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'LATEST CAMPUS ANNOUNCEMENTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _supabaseClient != null
                  ? _supabaseClient!
                      .from('school_notices')
                      .select()
                      .order('created_at', ascending: false)
                      .limit(3)
                  : Future.value([]),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      'Admissions & Academic Portal active for Session 2026–27.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  );
                }
                return Column(
                  children: snapshot.data!.map((n) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              n['tag'] ?? 'NOTICE',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              n['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                color: Color(0xFF0F1E36),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ==================== BOTTOM FLOATING LOGIN ACTION ====================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F1E36),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Icons.login_rounded, size: 19),
              label: const Text(
                'Login to Family Portal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required Color actionColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0F1E36),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Text(
              actionLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: actionColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StatBadge({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
