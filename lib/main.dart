import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Cloud safely
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

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF061123),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SSDConventApp());
}

class SSDConventApp extends StatelessWidget {
  const SSDConventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.S.D. Convent School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF061123),
        primaryColor: const Color(0xFF2563EB),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD6AD55),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF0C1B33),
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const NativeSchoolHomeScreen(),
    );
  }
}

class NativeSchoolHomeScreen extends StatefulWidget {
  const NativeSchoolHomeScreen({super.key});

  @override
  State<NativeSchoolHomeScreen> createState() => _NativeSchoolHomeScreenState();
}

class _NativeSchoolHomeScreenState extends State<NativeSchoolHomeScreen> {
  int _currentSlide = 0;
  final PageController _slideController = PageController();
  Timer? _sliderTimer;
  String _selectedClass = 'Class 10';
  String _selectedGalleryCategory = 'All';

  final List<Map<String, String>> _heroSlides = [
    {
      'title': 'Excellence in Education',
      'quote': 'Nurturing young minds to achieve academic brilliance and discipline.',
      'tag': 'Academic Integrity',
    },
    {
      'title': 'Holistic Growth & Ethics',
      'quote': 'Knowledge is power, character is strength. Building leaders of tomorrow.',
      'tag': 'Values & Leadership',
    },
    {
      'title': 'Modern Digital Campus',
      'quote': 'Smart classrooms, advanced science laboratories, and digital exam systems.',
      'tag': 'Innovation',
    },
  ];

  final List<String> _classes = [
    'Nursery', 'KG', 'Class 1', 'Class 2', 'Class 3', 'Class 4',
    'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'
  ];

  final List<Map<String, String>> _sampleExams = [
    {
      'subject': 'Mathematics Term Exam',
      'type': 'PDF Assessment',
      'date': 'Oct 2026',
      'duration': '2.5 Hours',
      'class': 'Class 10',
    },
    {
      'subject': 'Science & Technology Quiz',
      'type': 'MCQ Practice',
      'date': 'Active',
      'duration': '45 Mins',
      'class': 'Class 10',
    },
    {
      'subject': 'English Language & Grammar',
      'type': 'PDF Assessment',
      'date': 'Upcoming',
      'duration': '2 Hours',
      'class': 'Class 10',
    },
  ];

  final List<Map<String, String>> _galleryItems = [
    {'title': 'Annual Sports Meet', 'category': 'Athletics & Sports', 'desc': 'Champions track & sports awards'},
    {'title': 'Smart Computer Lab', 'category': 'Academics & Labs', 'desc': 'Hands-on IT practical training'},
    {'title': 'Morning Assembly & Prayer', 'category': 'Campus Life', 'desc': 'Daily student speeches & discipline'},
    {'title': 'Science & Innovation Exhibition', 'category': 'Academics & Labs', 'desc': 'Robotics & physics models'},
    {'title': 'Inter-School Football Trophy', 'category': 'Athletics & Sports', 'desc': 'Junior & senior sports tournament'},
    {'title': 'Cultural Fest & Stage Drama', 'category': 'Campus Life', 'desc': 'Music, dance and cultural celebrations'},
  ];

  @override
  void initState() {
    super.initState();
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_slideController.hasClients) {
        int nextPage = (_currentSlide + 1) % _heroSlides.length;
        _slideController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061123),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08162B),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD6AD55), Color(0xFFFDE68A)],
                ),
              ),
              child: const Icon(Icons.school_rounded, color: Color(0xFF071324), size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'S.S.D. CONVENT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Champapur, Janghai',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFD6AD55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFD6AD55)),
            onPressed: () => _launchExternal('tel:+917880884750'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO SLIDESHOW WITH DYNAMIC QUOTES
            _buildHeroSlideshow(),

            const SizedBox(height: 18),

            // 2. QUICK ACTION TILES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildQuickAction('Online Exam', Icons.assignment_turned_in_rounded, const Color(0xFF3B82F6), () {}),
                  const SizedBox(width: 10),
                  _buildQuickAction('Gallery', Icons.photo_library_rounded, const Color(0xFFD6AD55), () {}),
                  const SizedBox(width: 10),
                  _buildQuickAction('Call Office', Icons.call_rounded, const Color(0xFF10B981), () => _launchExternal('tel:+917880884750')),
                  const SizedBox(width: 10),
                  _buildQuickAction('Location', Icons.location_on_rounded, const Color(0xFFEC4899), () => _launchExternal('https://maps.google.com')),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. CLASS-WISE ONLINE EXAM PORTAL
            _buildExamPortalSection(),

            const SizedBox(height: 24),

            // 4. CAMPUS GALLERY CATEGORIES
            _buildCampusGallerySection(),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSlideshow() {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 12),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _slideController,
            onPageChanged: (index) => setState(() => _currentSlide = index),
            itemCount: _heroSlides.length,
            itemBuilder: (context, index) {
              final item = _heroSlides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F274A), Color(0xFF0A1830)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x33D6AD55)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x26D6AD55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['tag']!,
                        style: const TextStyle(
                          color: Color(0xFFD6AD55),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${item['quote']!}"',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFCBD5E1),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _heroSlides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentSlide == i ? 18 : 6,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _currentSlide == i ? const Color(0xFFD6AD55) : Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1B33),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamPortalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class-Wise Exam Portal',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '2026 Session',
                style: TextStyle(fontSize: 12, color: Color(0xFFD6AD55), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFD6AD55) : const Color(0xFF0C1B33),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? const Color(0xFFD6AD55) : Colors.white12),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSel ? const Color(0xFF071324) : Colors.white70,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        ..._sampleExams.map((exam) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1B33),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  exam['type']!.contains('MCQ') ? Icons.quiz_rounded : Icons.picture_as_pdf_rounded,
                  color: const Color(0xFFD6AD55),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam['subject']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exam['type']} • ${exam['duration']}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6AD55),
                  foregroundColor: const Color(0xFF071324),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${exam['subject']} for $_selectedClass...')),
                  );
                },
                child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCampusGallerySection() {
    final categories = ['All', 'Campus Life', 'Athletics & Sports', 'Academics & Labs'];
    final filtered = _selectedGalleryCategory == 'All'
        ? _galleryItems
        : _galleryItems.where((g) => g['category'] == _selectedGalleryCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Campus Photo Gallery',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF2563EB) : const Color(0xFF0C1B33),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSel ? const Color(0xFF3B82F6) : Colors.white12),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.white : Colors.white60,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final item = filtered[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1B33),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0x33D6AD55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_rounded, color: Color(0xFFD6AD55), size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['desc']!,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
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
