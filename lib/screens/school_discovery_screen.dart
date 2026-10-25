import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class SchoolDiscoveryScreen extends StatefulWidget {
  const SchoolDiscoveryScreen({super.key});

  @override
  State<SchoolDiscoveryScreen> createState() => _SchoolDiscoveryScreenState();
}

class _SchoolDiscoveryScreenState extends State<SchoolDiscoveryScreen> {
  final PageController _heroPageCtrl = PageController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _heroTimer;
  int _currentHeroIndex = 0;

  // All School Classes for Class-Wise Question Papers & Mock Exams
  static const List<String> _examClasses = [
    'Nursery',
    'L.K.G.',
    'U.K.G.',
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11 - Science',
    'Class 11 - Commerce',
    'Class 11 - Arts',
    'Class 12 - Science',
    'Class 12 - Commerce',
    'Class 12 - Arts',
  ];

  String _selectedExamClass = 'Class 10';

  // Rotating Inspiring Quotes for each Hero Slide
  static const List<Map<String, String>> _defaultQuotes = [
    {
      'headline': 'A brighter future\nstarts here.',
      'sub':
          'Champapur, Janghai, Prayagraj — A modern space where students learn with confidence, curiosity, and care.',
    },
    {
      'headline': 'Where curiosity\nmeets excellence.',
      'sub':
          'Empowering young minds at S.S.D. Convent School with smart classrooms, science labs, and dedicated mentorship.',
    },
    {
      'headline': 'Character, knowledge\n& discipline.',
      'sub':
          'Nurturing tomorrow’s leaders through strong moral values, academic rigor, and holistic personality development.',
    },
    {
      'headline': 'Every child is born\nto achieve.',
      'sub':
          'From Nursery to Senior Secondary — guiding every student toward board exam success and life-long confidence.',
    },
  ];

  // Gallery state synced with Admin Panel (school_gallery table)
  List<Map<String, dynamic>> _allGalleryItems = [];
  bool _loadingGallery = true;

  // Exam state synced with Admin Panel (school_exams table)
  List<Map<String, dynamic>> _classMcqList = [];
  List<Map<String, dynamic>> _classPdfList = [];
  bool _loadingExams = false;

  // Default fallback practice questions if Admin hasn't uploaded MCQs for a class yet
  static const List<Map<String, dynamic>> _fallbackQuestions = [
    {
      'question': 'Which organelle is known as the powerhouse of the cell?',
      'option_a': 'Nucleus',
      'option_b': 'Mitochondria',
      'option_c': 'Ribosome',
      'option_d': 'Golgi Apparatus',
      'correct_index': 1,
      'explanation':
          'Mitochondria generate most of the chemical energy (ATP) needed to power the cell.',
    },
    {
      'question':
          'If a quadratic equation ax² + bx + c = 0 has equal roots, what is the value of its discriminant (b² - 4ac)?',
      'option_a': 'Greater than 0',
      'option_b': 'Less than 0',
      'option_c': 'Equal to 0',
      'option_d': 'Equal to 1',
      'correct_index': 2,
      'explanation':
          'When the discriminant D = b² - 4ac = 0, both roots of the quadratic equation are real and equal.',
    },
    {
      'question': 'What is the SI unit of electric current?',
      'option_a': 'Volt (V)',
      'option_b': 'Ohm (Ω)',
      'option_c': 'Ampere (A)',
      'option_d': 'Watt (W)',
      'correct_index': 2,
      'explanation':
          'Electric current is measured in Amperes (A), representing the flow of one coulomb of charge per second.',
    },
    {
      'question': 'Who authored the Indian National Anthem "Jana Gana Mana"?',
      'option_a': 'Bankim Chandra Chatterjee',
      'option_b': 'Rabindranath Tagore',
      'option_c': 'Sarojini Naidu',
      'option_d': 'Subramania Bharati',
      'correct_index': 1,
      'explanation':
          'Nobel Laureate Rabindranath Tagore composed "Jana Gana Mana".',
    },
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
    _fetchGalleryMedia();
    _fetchClassExams(_selectedExamClass);
    _startHeroAutoSlide();
  }

  void _startHeroAutoSlide() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_heroPageCtrl.hasClients) return;
      final heroSlides = _heroSlidesList;
      final count = heroSlides.isEmpty ? 3 : heroSlides.length;
      if (count <= 1) return;
      final next = (_currentHeroIndex + 1) % count;
      _heroPageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _fetchGalleryMedia() async {
    final client = _supabaseClient;
    if (client == null) {
      if (mounted) setState(() => _loadingGallery = false);
      return;
    }
    try {
      final res = await client
          .from('school_gallery')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _allGalleryItems = List<Map<String, dynamic>>.from(res);
          _loadingGallery = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingGallery = false);
    }
  }

  Future<void> _fetchClassExams(String className) async {
    final client = _supabaseClient;
    if (client == null) return;
    setState(() => _loadingExams = true);
    try {
      final res = await client
          .from('school_exams')
          .select()
          .eq('class_name', className)
          .order('created_at', ascending: false);
      if (mounted) {
        final items = List<Map<String, dynamic>>.from(res);
        setState(() {
          _classPdfList =
              items.where((e) => (e['exam_type'] ?? '') == 'pdf').toList();
          _classMcqList =
              items.where((e) => (e['exam_type'] ?? 'mcq') == 'mcq').toList();
          _loadingExams = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExams = false);
    }
  }

  List<Map<String, dynamic>> get _heroSlidesList {
    return _allGalleryItems
        .where((item) =>
            (item['category'] ?? '').toString().toLowerCase() ==
            'hero slideshow')
        .toList();
  }

  List<Map<String, dynamic>> _itemsForCategory(String category) {
    return _allGalleryItems
        .where((item) =>
            (item['category'] ?? '').toString().toLowerCase() ==
            category.toLowerCase())
        .toList();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageCtrl.dispose();
    _scrollCtrl.dispose();
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

  // Helper to render Base64 or URL or Asset images cleanly
  Widget _buildDynamicImage(
    String? imageData, {
    BoxFit fit = BoxFit.cover,
    Widget? fallback,
  }) {
    final defaultFallback = fallback ??
        Image.asset(
          'app_logo.png',
          fit: fit,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF102747),
            alignment: Alignment.center,
            child: const Icon(
              Icons.apartment_rounded,
              color: Color(0xFFD6AD55),
              size: 42,
            ),
          ),
        );

    if (imageData == null || imageData.trim().isEmpty) {
      return defaultFallback;
    }

    final clean = imageData.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return Image.network(
        clean,
        fit: fit,
        errorBuilder: (_, __, ___) => defaultFallback,
      );
    }

    try {
      final rawBase64 = clean.contains(',') ? clean.split(',').last : clean;
      final Uint8List bytes = base64Decode(rawBase64);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (_, __, ___) => defaultFallback,
      );
    } catch (_) {
      return defaultFallback;
    }
  }

  // ==================== OPEN CATEGORY GALLERY VIEWER PAGE ====================
  void _openCategoryGalleryScreen(String categoryTitle, String subtitle) {
    final photos = _itemsForCategory(categoryTitle);

    Navigator.push(
      context,
      createSmoothRoute(
        CategoryGalleryViewerPage(
          categoryTitle: categoryTitle,
          subtitle: subtitle,
          photos: photos,
          imageBuilder: _buildDynamicImage,
        ),
      ),
    );
  }

  // ==================== VIEW / DOWNLOAD QUESTION PAPER PDF ====================
  Future<void> _openQuestionPaperPdfModal() async {
    if (_classPdfList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No PDF Question Paper uploaded for $_selectedExamClass yet.'),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
      );
      return;
    }

    if (_classPdfList.length == 1) {
      await _renderPdfFromBase64(_classPdfList.first);
      return;
    }

    // Multiple question papers available for this class
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1E36),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedExamClass — Question Papers (PDF)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._classPdfList.map(
              (pdfItem) => Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  title: Text(
                    (pdfItem['title'] ?? pdfItem['pdf_name'] ?? 'Question Paper')
                        .toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: Text(
                    'Class: $_selectedExamClass • Tap to View / Download',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11.5,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _renderPdfFromBase64(pdfItem);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renderPdfFromBase64(Map<String, dynamic> pdfItem) async {
    try {
      final raw = (pdfItem['pdf_base64'] ?? '').toString().trim();
      if (raw.isEmpty) return;
      final cleanBase64 = raw.contains(',') ? raw.split(',').last : raw;
      final Uint8List pdfBytes = base64Decode(cleanBase64);
      final title =
          (pdfItem['title'] ?? pdfItem['pdf_name'] ?? 'Question_Paper')
              .toString();

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: '${_selectedExamClass}_$title.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open PDF: $e')),
        );
      }
    }
  }

  // ==================== INTERACTIVE CLASS-WISE MOCK EXAM ====================
  void _openInteractivePracticeExam() {
    final activeQuestions =
        _classMcqList.isNotEmpty ? _classMcqList : _fallbackQuestions;
    final isCustomClassExam = _classMcqList.isNotEmpty;

    int currentQ = 0;
    int? selectedOption;
    bool submittedCurrent = false;
    int score = 0;
    bool quizCompleted = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1E36),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final qData = activeQuestions[currentQ];
          final options = [
            (qData['option_a'] ?? 'Option A').toString(),
            (qData['option_b'] ?? 'Option B').toString(),
            (qData['option_c'] ?? 'Option C').toString(),
            (qData['option_d'] ?? 'Option D').toString(),
          ];
          final correctIdx =
              int.tryParse((qData['correct_index'] ?? 0).toString()) ?? 0;
          final explanation =
              (qData['explanation'] ?? 'Review class notes for details.')
                  .toString();

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
                            isCustomClassExam
                                ? '$_selectedExamClass • OFFICIAL SCHOOL EXAM'
                                : '$_selectedExamClass • GENERAL PRACTICE',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFBBF24),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            quizCompleted
                                ? 'Assessment Evaluation Summary'
                                : 'Question ${currentQ + 1} of ${activeQuestions.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
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
                        : (currentQ + 1) / activeQuestions.length,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
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
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFF10B981),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You Scored $score / ${activeQuestions.length}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          score >= (activeQuestions.length * 0.6)
                              ? 'Excellent performance! Keep up your preparation.'
                              : 'Good effort! Review your class notes and try again.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
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
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Done & Return to Campus Portal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    (qData['question'] ?? '').toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(options.length, (idx) {
                    final optionText = options[idx];
                    final isCorrect = idx == correctIdx;
                    final isSelected = selectedOption == idx;

                    Color borderColor = const Color(0xFF334155);
                    Color bgColor = const Color(0xFF1E293B);

                    if (submittedCurrent) {
                      if (isCorrect) {
                        borderColor = const Color(0xFF10B981);
                        bgColor = const Color(0xFF10B981).withOpacity(0.18);
                      } else if (isSelected && !isCorrect) {
                        borderColor = const Color(0xFFEF4444);
                        bgColor = const Color(0xFFEF4444).withOpacity(0.18);
                      }
                    } else if (isSelected) {
                      borderColor = const Color(0xFF3B82F6);
                      bgColor = const Color(0xFF3B82F6).withOpacity(0.2);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: submittedCurrent
                            ? null
                            : () => setModalState(() => selectedOption = idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (submittedCurrent && isCorrect)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                              if (submittedCurrent && isSelected && !isCorrect)
                                const Icon(
                                  Icons.cancel_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (submittedCurrent && explanation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF60A5FA).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Explanation: $explanation',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF93C5FD),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: selectedOption == null
                          ? null
                          : () {
                              if (!submittedCurrent) {
                                setModalState(() {
                                  submittedCurrent = true;
                                  if (selectedOption == correctIdx) {
                                    score++;
                                  }
                                });
                              } else {
                                setModalState(() {
                                  if (currentQ + 1 < activeQuestions.length) {
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
                            : (currentQ + 1 < activeQuestions.length
                                ? 'Next Question →'
                                : 'View Final Score'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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

  void _showVisitingHoursDetails() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        title: const Row(
          children: [
            Icon(Icons.access_time_filled_rounded, color: Color(0xFF60A5FA)),
            SizedBox(width: 10),
            Text(
              'Campus Visiting Hours',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          '• Monday to Saturday: 8:00 AM – 2:00 PM\n'
          '• Principal Visiting Hours: 9:30 AM – 12:30 PM\n'
          '• Fee Counter & Admission Desk: 8:30 AM – 1:30 PM\n'
          '• Closed on Sundays & Gazetted Holidays',
          style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroSlides = _heroSlidesList;
    final totalHeroSlides = heroSlides.isEmpty ? 3 : heroSlides.length;

    return Scaffold(
      backgroundColor: const Color(0xFF061123),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF091B3A),
              Color(0xFF061123),
              Color(0xFF050D1C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==================== 1. CUSTOM TOP SCHOOL HEADER ====================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // School Crest Emblem
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFDE68A),
                            Color(0xFFD97706),
                            Color(0xFFB45309),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD97706).withOpacity(0.35),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'app_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF0F2952),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFFFDE68A),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // School Name & Motto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'S.S.D. Convent School',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Family Information Portal',
                            style: TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'LEARN   •   GROW   •   ACHIEVE',
                            style: TextStyle(
                              color: const Color(0xFF60A5FA).withOpacity(0.85),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sun / Moon Pill Toggle
                    GestureDetector(
                      onTap: toggleSSDTheme,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF112240),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_rounded,
                              size: 16,
                              color: !isDark
                                  ? const Color(0xFFFBBF24)
                                  : const Color(0xFFFBBF24).withOpacity(0.85),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.nightlight_round,
                              size: 15,
                              color: isDark
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quick Menu Button
                    PopupMenuButton<String>(
                      color: const Color(0xFF0F1E36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (val) {
                        if (val == 'login') {
                          Navigator.push(
                            context,
                            createSmoothRoute(const LoginScreen()),
                          );
                        } else if (val == 'refresh') {
                          _fetchGalleryMedia();
                          _fetchClassExams(_selectedExamClass);
                        } else if (val == 'galleries') {
                          _scrollCtrl.animateTo(
                            _scrollCtrl.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(
                          value: 'login',
                          child: Row(
                            children: [
                              Icon(Icons.login_rounded,
                                  color: Color(0xFF60A5FA), size: 18),
                              SizedBox(width: 10),
                              Text('Login to Family Portal',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'galleries',
                          child: Row(
                            children: [
                              Icon(Icons.photo_library_rounded,
                                  color: Color(0xFFFBBF24), size: 18),
                              SizedBox(width: 10),
                              Text('Explore Campus Galleries',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(Icons.sync_rounded,
                                  color: Color(0xFF34D399), size: 18),
                              SizedBox(width: 10),
                              Text('Sync Latest Photos & Exams',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF112240),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subtle glowing divider line
              Container(
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF3B82F6).withOpacity(0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // ==================== MAIN SCROLLABLE BODY ====================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _fetchGalleryMedia();
                    await _fetchClassExams(_selectedExamClass);
                  },
                  color: const Color(0xFF3B82F6),
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================== 2. ADMIN-CONTROLLED SPLIT HERO SLIDESHOW ====================
                        Container(
                          height: 215,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF102A56),
                                Color(0xFF0A1D3B),
                                Color(0xFF08152C),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.35),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3A8A).withOpacity(0.35),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(23),
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: _heroPageCtrl,
                                  itemCount: totalHeroSlides,
                                  onPageChanged: (idx) {
                                    setState(() => _currentHeroIndex = idx);
                                  },
                                  itemBuilder: (context, index) {
                                    final slideItem = heroSlides.isNotEmpty
                                        ? heroSlides[index % heroSlides.length]
                                        : null;
                                    final quoteObj = _defaultQuotes[
                                        index % _defaultQuotes.length];

                                    // Use Admin's custom quote if entered, otherwise use rotating quote
                                    final customQuote =
                                        (slideItem?['quote'] ?? '').toString().trim();
                                    final customTitle =
                                        (slideItem?['title'] ?? '').toString().trim();

                                    final headlineText = customQuote.isNotEmpty
                                        ? customQuote
                                        : quoteObj['headline']!;
                                    final subText = customTitle.isNotEmpty
                                        ? '$customTitle — Champapur, Janghai, Prayagraj.'
                                        : quoteObj['sub']!;

                                    return Row(
                                      children: [
                                        // LEFT HALF: Rotating Quote & Badge
                                        Expanded(
                                          flex: 54,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 16, 6, 24),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 9,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFD97706)
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: const Color(
                                                              0xFFFBBF24)
                                                          .withOpacity(0.55),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.school_rounded,
                                                        color:
                                                            Color(0xFFFDE68A),
                                                        size: 11,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Flexible(
                                                        child: Text(
                                                          'LEARN • GROW • ACHIEVE',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFFFDE68A),
                                                            fontSize: 8.5,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            letterSpacing: 0.7,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  headlineText,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 19.5,
                                                    height: 1.15,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  subText,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.82),
                                                    fontSize: 10.5,
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // RIGHT HALF: Curved Arch Campus Photo with Gold Accent Border
                                        Expanded(
                                          flex: 46,
                                          child: Container(
                                            height: double.infinity,
                                            margin: const EdgeInsets.only(
                                                left: 4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.horizontal(
                                                left: Radius.elliptical(
                                                    110, 190),
                                              ),
                                              border: Border.all(
                                                color: const Color(0xFFFBBF24)
                                                    .withOpacity(0.65),
                                                width: 2.2,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.horizontal(
                                                left: Radius.elliptical(
                                                    108, 188),
                                              ),
                                              child: _buildDynamicImage(
                                                slideItem?['image_data']
                                                    ?.toString(),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                // Bottom Center Pagination Dots
                                Positioned(
                                  bottom: 9,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        List.generate(totalHeroSlides, (i) {
                                      final active = i ==
                                          (_currentHeroIndex % totalHeroSlides);
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        width: active ? 18 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: active
                                              ? const Color(0xFF38BDF8)
                                              : Colors.white.withOpacity(0.35),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================== 3. CAMPUS DIRECTORY & HELPLINE ====================
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
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            'Quick access to important contacts and campus information.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 2x2 Glowing Directory Cards (Exact Match to Screenshot 1)
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 11,
                          mainAxisSpacing: 11,
                          childAspectRatio: 1.05,
                          children: [
                            _buildGlowingDirectoryCard(
                              gradientColors: const [
                                Color(0xFF0D3B38),
                                Color(0xFF082226)
                              ],
                              borderColor: const Color(0xFF10B981),
                              iconBgColor: const Color(0xFF10B981),
                              icon: Icons.phone_in_talk_rounded,
                              title: 'Phone Helpline',
                              subtitle: '+91 78808 84750\n+91 85608 22342',
                              pillLabel: 'Call Now',
                              pillIcon: Icons.call_rounded,
                              onTap: () => _launchUrl('tel:+917880884750'),
                            ),
                            _buildGlowingDirectoryCard(
                              gradientColors: const [
                                Color(0xFF3B1528),
                                Color(0xFF210D1B)
                              ],
                              borderColor: const Color(0xFFEF4444),
                              iconBgColor: const Color(0xFFDC2626),
                              icon: Icons.location_on_rounded,
                              title: 'Campus Location',
                              subtitle:
                                  'Champapur, Handia Rd,\nJanghai, Prayagraj',
                              pillLabel: 'Open in Maps',
                              pillIcon: Icons.map_rounded,
                              onTap: () => _launchUrl(
                                  'https://maps.google.com/?q=SSD+Convent+School+Janghai+Prayagraj'),
                            ),
                            _buildGlowingDirectoryCard(
                              gradientColors: const [
                                Color(0xFF102A58),
                                Color(0xFF0A1936)
                              ],
                              borderColor: const Color(0xFF3B82F6),
                              iconBgColor: const Color(0xFF2563EB),
                              icon: Icons.access_time_filled_rounded,
                              title: 'Visiting Hours',
                              subtitle:
                                  'Mon – Sat:\n8:00 AM – 2:00 PM\n(Closed Sundays)',
                              pillLabel: 'View Details',
                              pillIcon: Icons.calendar_today_rounded,
                              onTap: _showVisitingHoursDetails,
                            ),
                            _buildGlowingDirectoryCard(
                              gradientColors: const [
                                Color(0xFF2B1954),
                                Color(0xFF170E33)
                              ],
                              borderColor: const Color(0xFF8B5CF6),
                              iconBgColor: const Color(0xFF7C3AED),
                              icon: Icons.email_rounded,
                              title: 'Official Email',
                              subtitle:
                                  'info@ssdconvent.com\nPrincipal & Admin Desk',
                              pillLabel: 'Send Email',
                              pillIcon: Icons.mark_email_read_rounded,
                              onTap: () =>
                                  _launchUrl('mailto:info@ssdconvent.com'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ==================== 4. CALL & WHATSAPP PILL ROW ====================
                        Row(
                          children: [
                            Expanded(
                              child: _buildWideActionPill(
                                icon: Icons.call_rounded,
                                label: 'Call School Office',
                                gradient: const [
                                  Color(0xFF102A58),
                                  Color(0xFF0B1C3D)
                                ],
                                borderColor: const Color(0xFF3B82F6),
                                iconColor: const Color(0xFF60A5FA),
                                onTap: () => _launchUrl('tel:+917880884750'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildWideActionPill(
                                icon: Icons.chat_bubble_outline_rounded,
                                label: 'WhatsApp Chat',
                                gradient: const [
                                  Color(0xFF0D3B38),
                                  Color(0xFF072624)
                                ],
                                borderColor: const Color(0xFF10B981),
                                iconColor: const Color(0xFF34D399),
                                onTap: () => _launchUrl(
                                    'https://wa.me/917880884750?text=Hello%20SSD%20Convent%20School'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ==================== 5. GLOWING LOGIN TO FAMILY PORTAL BUTTON ====================
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1D4ED8),
                                Color(0xFF2563EB),
                                Color(0xFF3B82F6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF2563EB).withOpacity(0.45),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                createSmoothRoute(const LoginScreen()),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login_rounded, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Login to Family Portal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15.5,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // ==================== 6. CLASS-WISE ONLINE EXAM & QUESTION PAPER PORTAL ====================
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E1E38),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFF334155),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706)
                                          .withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.quiz_rounded,
                                      color: Color(0xFFFBBF24),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ASSESSMENT PORTAL',
                                          style: TextStyle(
                                            color: Color(0xFFFBBF24),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        Text(
                                          'Online Exam & Question Papers',
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_loadingExams)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFFBBF24),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Select your class below to download official PDF Question Papers or start an interactive practice test.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF081224),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedExamClass,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF0F1E36),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white70,
                                    ),
                                    items: _examClasses
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _selectedExamClass = v);
                                        _fetchClassExams(v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // PDF Question Paper Button (Shown prominently when available or always clickable)
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFDE68A),
                                    side: BorderSide(
                                      color: _classPdfList.isNotEmpty
                                          ? const Color(0xFFFBBF24)
                                          : const Color(0xFF334155),
                                    ),
                                    backgroundColor: _classPdfList.isNotEmpty
                                        ? const Color(0xFFD97706)
                                            .withOpacity(0.15)
                                        : Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _classPdfList.isNotEmpty
                                        ? 'Download $_selectedExamClass Question Paper (${_classPdfList.length} PDF)'
                                        : 'Question Paper PDF ($_selectedExamClass)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  onPressed: _openQuestionPaperPdfModal,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Interactive MCQ Mock Test Button
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _classMcqList.isNotEmpty
                                        ? 'Start $_selectedExamClass Exam (${_classMcqList.length} Qs)'
                                        : 'Start Interactive Mock Test',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  onPressed: _openInteractivePracticeExam,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==================== 7. THREE CAMPUS GALLERIES AT THE BOTTOM ====================
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Campus Life & Photo Galleries',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            'Tap any album below to view all photos uploaded by the school.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildBottomGalleryAlbumCard(
                          categoryTitle: 'Campus Life',
                          subtitle: 'Smart Science Lab, Classrooms & Facilities',
                          accentColor: const Color(0xFF3B82F6),
                          icon: Icons.science_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildBottomGalleryAlbumCard(
                          categoryTitle: 'Athletics',
                          subtitle: 'Sports, Playground & Annual Tournaments',
                          accentColor: const Color(0xFF10B981),
                          icon: Icons.emoji_events_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildBottomGalleryAlbumCard(
                          categoryTitle: 'Daily Life',
                          subtitle:
                              'Morning Assembly, Cultural Programs & Activities',
                          accentColor: const Color(0xFFF59E0B),
                          icon: Icons.wb_sunny_rounded,
                        ),
                      ],
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

  // ==================== WIDGET: 2x2 GLOWING DIRECTORY CARD ====================
  Widget _buildGlowingDirectoryCard({
    required List<Color> gradientColors,
    required Color borderColor,
    required Color iconBgColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required String pillLabel,
    required IconData pillIcon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(
            color: borderColor.withOpacity(0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: iconBgColor.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 10.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(pillIcon, color: Colors.white, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        pillLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white70,
                    size: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGET: WIDE FAST ACTION PILL ====================
  Widget _buildWideActionPill({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: gradient),
          border: Border.all(color: borderColor.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white60,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGET: 3 BOTTOM GALLERY ALBUM CARDS ====================
  Widget _buildBottomGalleryAlbumCard({
    required String categoryTitle,
    required String subtitle,
    required Color accentColor,
    required IconData icon,
  }) {
    final items = _itemsForCategory(categoryTitle);
    final coverImg =
        items.isNotEmpty ? items.first['image_data']?.toString() : null;

    return InkWell(
      onTap: () => _openCategoryGalleryScreen(categoryTitle, subtitle),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0E1E38),
          border: Border.all(color: accentColor.withOpacity(0.45), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Row(
            children: [
              // Left Album Info
              Expanded(
                flex: 60,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: accentColor.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, color: accentColor, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  categoryTitle.toUpperCase(),
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${items.length} Photos',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right Cover Thumbnail + Open Overlay
              Expanded(
                flex: 40,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildDynamicImage(coverImg, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFF0E1E38),
                            const Color(0xFF0E1E38).withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Open',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DEDICATED FULL-SCREEN GALLERY VIEWER PAGE (NAMED AFTER SELECTED OPTION)
// ============================================================================
class CategoryGalleryViewerPage extends StatelessWidget {
  final String categoryTitle;
  final String subtitle;
  final List<Map<String, dynamic>> photos;
  final Widget Function(String?, {BoxFit fit, Widget? fallback}) imageBuilder;

  const CategoryGalleryViewerPage({
    super.key,
    required this.categoryTitle,
    required this.subtitle,
    required this.photos,
    required this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061123),
      appBar: AppBar(
        backgroundColor: const Color(0xFF091B3A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryTitle, // Explicitly named after the option opened!
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF93C5FD),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: photos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF102A56),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF3B82F6)),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: Color(0xFF60A5FA),
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Photos in "$categoryTitle" Yet',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Photos uploaded by the Admin under this category will automatically appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final item = photos[index];
                final title =
                    (item['title'] ?? categoryTitle).toString().trim();
                final quote = (item['quote'] ?? '').toString().trim();
                final imgData = item['image_data']?.toString();

                return GestureDetector(
                  onTap: () {
                    // Open Full-Screen Zoomable Lightbox
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                color: const Color(0xFF091B3A),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.55,
                                      width: double.infinity,
                                      child: InteractiveViewer(
                                        child: imageBuilder(
                                          imgData,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title.isNotEmpty
                                                ? title
                                                : categoryTitle,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (quote.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              quote,
                                              style: const TextStyle(
                                                color: Color(0xFF93C5FD),
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1E38),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.35),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          imageBuilder(imgData, fit: BoxFit.cover),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.85),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Text(
                                title.isNotEmpty ? title : categoryTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
