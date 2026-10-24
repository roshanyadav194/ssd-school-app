import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

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

  // Built-in interactive practice questions per stream/class
  static const List<Map<String, dynamic>> _practiceQuestions = [
    {
      'q': 'Which organelle is known as the powerhouse of the cell?',
      'options': ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi Apparatus'],
      'ans': 1,
      'exp': 'Mitochondria generate most of the chemical energy (ATP) needed to power the cell.',
    },
    {
      'q': 'If a quadratic equation ax² + bx + c = 0 has equal roots, what is the value of its discriminant (b² - 4ac)?',
      'options': ['Greater than 0', 'Less than 0', 'Equal to 0', 'Equal to 1'],
      'ans': 2,
      'exp': 'When the discriminant D = b² - 4ac = 0, both roots of the quadratic equation are real and equal.',
    },
    {
      'q': 'What is the SI unit of electric current?',
      'options': ['Volt (V)', 'Ohm (Ω)', 'Ampere (A)', 'Watt (W)'],
      'ans': 2,
      'exp': 'Electric current is measured in Amperes (A), representing the flow of one coulomb of charge per second.',
    },
    {
      'q': 'Who authored the Indian National Anthem "Jana Gana Mana"?',
      'options': ['Bankim Chandra Chatterjee', 'Rabindranath Tagore', 'Sarojini Naidu', 'Subramania Bharati'],
      'ans': 1,
      'exp': 'Nobel Laureate Rabindranath Tagore composed "Jana Gana Mana".',
    },
  ];

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

  void _openInteractivePracticeExam() {
    int currentQ = 0;
    int? selectedOption;
    bool submittedCurrent = false;
    int score = 0;
    bool quizCompleted = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final qData = _practiceQuestions[currentQ];

          return Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedExamClass.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD97706),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            quizCompleted
                                ? 'Assessment Evaluation Summary'
                                : 'Question ${currentQ + 1} of ${_practiceQuestions.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F1E36),
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
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: quizCompleted
                        ? 1.0
                        : (currentQ + 1) / _practiceQuestions.length,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                  ),
                ),
                const SizedBox(height: 18),
                if (quizCompleted) ...[
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF10B981), size: 40),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You Scored $score / ${_practiceQuestions.length}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F1E36),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          score >= 3
                              ? 'Excellent performance! Keep up your preparation.'
                              : 'Good effort! Review your class notes and try again.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Done & Return to Campus Portal', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    qData['q'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: isDark ? Colors.white : const Color(0xFF0F1E36),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate((qData['options'] as List).length, (idx) {
                    final optionText = (qData['options'] as List)[idx] as String;
                    final isCorrect = idx == (qData['ans'] as int);
                    final isSelected = selectedOption == idx;

                    Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
                    Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

                    if (submittedCurrent) {
                      if (isCorrect) {
                        borderColor = const Color(0xFF10B981);
                        bgColor = const Color(0xFF10B981).withOpacity(0.12);
                      } else if (isSelected && !isCorrect) {
                        borderColor = const Color(0xFFDC2626);
                        bgColor = const Color(0xFFDC2626).withOpacity(0.12);
                      }
                    } else if (isSelected) {
                      borderColor = const Color(0xFF1E3A8A);
                      bgColor = const Color(0xFF1E3A8A).withOpacity(0.1);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: submittedCurrent
                            ? null
                            : () => setModalState(() => selectedOption = idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${String.fromCharCode(65 + idx)}.  $optionText',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : const Color(0xFF0F1E36),
                                  ),
                                ),
                              ),
                              if (submittedCurrent && isCorrect)
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                              if (submittedCurrent && isSelected && !isCorrect)
                                const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (submittedCurrent) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Explanation: ${qData['exp']}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: selectedOption == null
                          ? null
                          : () {
                              if (!submittedCurrent) {
                                setModalState(() {
                                  submittedCurrent = true;
                                  if (selectedOption == (qData['ans'] as int)) {
                                    score++;
                                  }
                                });
                              } else {
                                setModalState(() {
                                  if (currentQ + 1 < _practiceQuestions.length) {
                                    currentQ++;
                                    selectedOption = null;
                                    submittedCurrent = false;
                                  } else {
                                    quizCompleted = true;
                                  }
                                });
                              }
                            },
                      child: Text(
                        !submittedCurrent
                            ? 'Check Answer'
                            : (currentQ + 1 < _practiceQuestions.length ? 'Next Question →' : 'View Final Score'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F1E36),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(isDark ? 0.3 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.school_rounded,
                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'S.S.D. Convent School',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F1E36),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: toggleSSDTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== AESTHETIC HERO BANNER ====================
            StaggeredEntrance(
              index: 0,
              child: AnimatedBuilder(
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
            ),

            const SizedBox(height: 26),

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
            StaggeredEntrance(
              index: 1,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.90,
                children: [
                  _buildModernCard(
                    isDark: isDark,
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
                    isDark: isDark,
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
                    isDark: isDark,
                    icon: Icons.access_time_filled_rounded,
                    iconBg: const Color(0xFF3B82F6).withOpacity(0.12),
                    iconColor: const Color(0xFF2563EB),
                    title: 'Visiting Hours',
                    subtitle: 'Mon – Sat:\n8:00 AM – 2:00 PM\n(Closed Sundays)',
                    actionLabel: 'Front Office Desk',
                    actionColor: const Color(0xFF3B82F6),
                    onTap: () => _launchUrl('tel:+918560822342'),
                  ),
                  _buildModernCard(
                    isDark: isDark,
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
            ),

            const SizedBox(height: 16),

            // ==================== FAST ACTION BUTTON ROW ====================
            StaggeredEntrance(
              index: 2,
              child: Row(
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
                      label: const Text('Call School Office', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                      label: const Text('WhatsApp Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () => _launchUrl('https://wa.me/917880884750?text=Hello%20SSD%20Convent%20School'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================== POLISHED EXAM PORTAL TILE ====================
            StaggeredEntrance(
              index: 3,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
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
                                  color: isDark ? Colors.white : const Color(0xFF0F1E36),
                                ),
                              ),
                            ],
                          ),
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
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedExamClass,
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          items: _examClasses
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF0F1E36),
                                    ),
                                  ),
                                ),
                              )
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
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                        label: const Text('Start Interactive Mock Test', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: _openInteractivePracticeExam,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ==================== BOTTOM FLOATING LOGIN ACTION ====================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFF0F1E36),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Icons.login_rounded, size: 19),
              label: const Text('Login to Family Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () {
                Navigator.push(
                  context,
                  createSmoothRoute(const LoginScreen()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required bool isDark,
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
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF0F1E36),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.3),
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
