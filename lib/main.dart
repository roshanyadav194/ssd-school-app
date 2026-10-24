import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- YOUR SUPABASE CREDENTIALS ---
const String supabaseUrl = 'https://shlzyjkkckmdxolwenvk.supabase.co';
const String supabaseAnonKey = 'sb_publishable_6yYdqREcVbFa_65ARl1EWA_rGjENe1n';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F1E36),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SSDConventApp());
}

SupabaseClient? get supabaseClient {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

class SSDConventApp extends StatelessWidget {
  const SSDConventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.S.D. Convent School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        primaryColor: const Color(0xFF1E3A8A),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1E3A8A),
          secondary: Color(0xFFD97706),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 1. SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _initBackend();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initBackend() async {
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
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Color(0x331E3A8A), blurRadius: 15, offset: Offset(0, 6))
                            ],
                          ),
                          child: const Icon(Icons.school_rounded, color: Colors.white, size: 44),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'S.S.D. CONVENT SCHOOL',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F1E36),
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Knowledge • Discipline • Future',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(color: Color(0x29000000), blurRadius: 16, offset: Offset(0, 8))
                            ],
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.apartment_rounded, color: Colors.white, size: 54),
                              SizedBox(height: 12),
                              Text(
                                'S.S.D. CONVENT CAMPUS',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Family Information Portal',
                                style: TextStyle(color: Color(0xFF93C5FD), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F1E36),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
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
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Login to Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '© S.S.D. Convent School • Secure Access',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
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
}

// ==========================================
// 2. LOGIN SCREEN (Parent & Admin Panel)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedTab = 0; // 0 = Parent, 1 = Admin Panel
  final _mobileController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _adminIdController = TextEditingController();
  final _adminPassController = TextEditingController();
  bool _isLoading = false;

  // PARENT LOGIN VERIFICATION
  Future<void> _handleParentLogin() async {
    final mobile = _mobileController.text.trim();
    final year = _birthYearController.text.trim();

    if (mobile.isEmpty || year.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both mobile number and birth year / DOB'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = supabaseClient;
      if (client == null) {
        throw Exception('Database connection not ready.');
      }

      // Check if Phone & Birth Year match a student created by the Admin
      final res = await client
          .from('students')
          .select()
          .or('mobile_number.eq.$mobile,parent_phone.eq.$mobile')
          .or('birth_year.eq.$year,student_dob.eq.$year')
          .maybeSingle();

      setState(() => _isLoading = false);

      if (res == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No student found matching these details. Please contact school office.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Match found -> open dashboard with that specific student's data
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(studentData: res)),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ADMIN LOGIN VERIFICATION
  Future<void> _handleAdminLogin() async {
    final email = _adminIdController.text.trim();
    final password = _adminPassController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Admin Email and Password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = supabaseClient;
      if (client == null) {
        throw Exception('Database connection not ready.');
      }

      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthException('Invalid admin credentials.');
      }

      final profile = await client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      setState(() => _isLoading = false);

      if (profile == null || profile['role'] != 'admin') {
        await client.auth.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access Denied: This account is not authorized as Admin.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHubScreen()),
      );
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildParentLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registered Mobile Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36))),
        const SizedBox(height: 8),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_rounded, color: Color(0xFF1E3A8A), size: 20),
                  SizedBox(width: 8),
                  Text('+91', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F1E36))),
                ],
              ),
            ),
            hintText: 'Enter 10-digit number',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 18),
        const Text("Student's Birth Year / DOB", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36))),
        const SizedBox(height: 8),
        TextField(
          controller: _birthYearController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.cake_rounded, color: Color(0xFF1E3A8A), size: 20),
            hintText: 'e.g. 2010',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFF1E3A8A), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No password required. Login using your registered mobile number and student birth year.',
                  style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 11.5, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _handleParentLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Access Student Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Staff / Admin Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36))),
        const SizedBox(height: 8),
        TextField(
          controller: _adminIdController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF1E3A8A), size: 20),
            hintText: 'admin@ssdconvent.com',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Security Passcode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36))),
        const SizedBox(height: 8),
        TextField(
          controller: _adminPassController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF1E3A8A), size: 20),
            hintText: 'Enter password',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F1E36),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _handleAdminLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Login to Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _birthYearController.dispose();
    _adminIdController.dispose();
    _adminPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F1E36), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'S.S.D. CONVENT SCHOOL',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F1E36)),
                    ),
                    const Text('Family Information Portal', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? const Color(0xFF1E3A8A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Parent',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTab == 0 ? Colors.white : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
                            color: _selectedTab == 1 ? const Color(0xFF1E3A8A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Admin Panel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTab == 1 ? Colors.white : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (_selectedTab == 0) _buildParentLoginForm() else _buildAdminLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. STUDENT DASHBOARD
// ==========================================
class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> studentData;
  const DashboardScreen({super.key, required this.studentData});

  void _openComplaintModal(BuildContext context) {
    final complaintController = TextEditingController();
    String category = 'Academic';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Submit Grievance / Complaint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Academic', 'Transport & Bus', 'Fee Account', 'School Facilities', 'Staff Behavior']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) => setModalState(() => category = val!),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Describe Your Issue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 6),
              TextField(
                controller: complaintController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Provide details regarding your issue...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (complaintController.text.trim().isNotEmpty) {
                      final client = supabaseClient;
                      if (client != null) {
                        try {
                          await client.from('school_complaints').insert({
                            'parent_name': studentData['parent_name'] ?? studentData['father_name'] ?? 'Parent',
                            'student_name': studentData['student_name'] ?? 'Student',
                            'category': category,
                            'details': complaintController.text.trim(),
                            'status': 'Under Review',
                          });
                        } catch (_) {}
                      }
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Grievance submitted directly to school management.')),
                      );
                    }
                  },
                  child: const Text('Submit Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentName = studentData['parent_name'] ?? studentData['father_name'] ?? 'Parent';
    final studentName = studentData['student_name'] ?? 'Student';
    final className = studentData['class_grade'] ?? studentData['class_name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'S.S.D. Convent School',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F1E36)),
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF1E3A8A), size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Good Morning,', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        Text(
                          parentName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F1E36)),
                        ),
                        Text(
                          'Parent of $studentName (Class$className)',
                          style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.volunteer_activism_rounded, color: Color(0xFFD97706), size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Together for a brighter future',
                            style: TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('QUICK SERVICES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                      children: [
                        _buildGridCard(Icons.calendar_month_rounded, 'Attendance', const Color(0xFF10B981), () {}),
                        _buildGridCard(Icons.account_balance_wallet_rounded, 'Fees', const Color(0xFF8B5CF6), () {}),
                        _buildGridCard(Icons.insert_chart_rounded, 'Results', const Color(0xFFF59E0B), () {}),
                        _buildGridCard(Icons.access_time_filled_rounded, 'Time Table', const Color(0xFF3B82F6), () {}),
                        _buildGridCard(Icons.campaign_rounded, 'Notices', const Color(0xFFEC4899), () {}),
                        _buildGridCard(Icons.report_problem_rounded, 'Complaint', const Color(0xFFDC2626), () => _openComplaintModal(context)),
                        _buildGridCard(Icons.menu_book_rounded, 'Homework', const Color(0xFF06B6D4), () {}),
                        _buildGridCard(Icons.celebration_rounded, 'Events', const Color(0xFF84CC16), () {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('LATEST CIRCULARS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: supabaseClient != null
                          ? supabaseClient!
                              .from('school_notices')
                              .select()
                              .order('created_at', ascending: false)
                              .limit(3)
                          : Future.value([]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: const Text('No circulars posted yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          );
                        }
                        return Column(
                          children: snapshot.data!.map((n) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    n['tag'] ?? 'NOTICE',
                                    style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    n['title'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F1E36)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. ADMIN CONTROL HUB
// ==========================================
class AdminHubScreen extends StatefulWidget {
  const AdminHubScreen({super.key});

  @override
  State<AdminHubScreen> createState() => _AdminHubScreenState();
}

class _AdminHubScreenState extends State<AdminHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Student form controllers
  final _studentNameCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _classGradeCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  final _birthYearCtrl = TextEditingController();
  bool _isAddingStudent = false;

  // Circular form controllers
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _selectedTag = 'EXAMS';
  bool _isPostingNotice = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentNameCtrl.dispose();
    _parentNameCtrl.dispose();
    _classGradeCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _birthYearCtrl.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // 1. ADMIN REGISTERS A STUDENT (Instantly creates parent login credentials)
  Future<void> _addNewStudent() async {
    final sName = _studentNameCtrl.text.trim();
    final pName = _parentNameCtrl.text.trim();
    final cGrade = _classGradeCtrl.text.trim();
    final phone = _parentPhoneCtrl.text.trim();
    final bYear = _birthYearCtrl.text.trim();

    if (sName.isEmpty || phone.isEmpty || bYear.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Student Name, Parent Phone, and Birth Year/DOB'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAddingStudent = true);
    final client = supabaseClient;
    if (client == null) {
      setState(() => _isAddingStudent = false);
      return;
    }

    try {
      await client.from('students').insert({
        'student_name': sName,
        'parent_name': pName.isNotEmpty ? pName : 'Parent',
        'father_name': pName.isNotEmpty ? pName : 'Parent',
        'class_grade': cGrade.isNotEmpty ? cGrade : 'General',
        'parent_phone': phone,
        'mobile_number': phone,
        'birth_year': bYear,
        'student_dob': bYear,
      });

      _studentNameCtrl.clear();
      _parentNameCtrl.clear();
      _classGradeCtrl.clear();
      _parentPhoneCtrl.clear();
      _birthYearCtrl.clear();

      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student registered! Parent can login using Phone: $phone and Year:$bYear'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding student: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isAddingStudent = false);
    }
  }

  // 2. BROADCAST CIRCULAR
  Future<void> _publishNotice() async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) return;
    final client = supabaseClient;
    if (client == null) return;

    setState(() => _isPostingNotice = true);
    try {
      await client.from('school_notices').insert({
        'tag': _selectedTag,
        'title': _titleCtrl.text.trim(),
        'date': 'Oct 2026',
        'content': _contentCtrl.text.trim(),
      });
      _titleCtrl.clear();
      _contentCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice broadcasted to App and Website!'), backgroundColor: Colors.green),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notice error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isPostingNotice = false);
    }
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Student / Parent Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _studentNameCtrl,
                decoration: const InputDecoration(labelText: 'Student Full Name *', hintText: 'e.g. Vinayak Yadav'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _parentNameCtrl,
                decoration: const InputDecoration(labelText: 'Parent Name', hintText: 'e.g. Ramesh Yadav'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _classGradeCtrl,
                decoration: const InputDecoration(labelText: 'Class / Section', hintText: 'e.g. 5-B'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _parentPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Parent Phone (Login ID) *', hintText: '10-digit mobile'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _birthYearCtrl,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Birth Year / DOB (Login Key) *', hintText: 'e.g. 2015'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
            onPressed: _isAddingStudent ? null : _addNewStudent,
            child: _isAddingStudent
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save & Create Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Management Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F1E36),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD97706),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: const [
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Students'),
            Tab(icon: Icon(Icons.campaign_rounded), text: 'Circulars'),
            Tab(icon: Icon(Icons.report_problem_rounded), text: 'Complaints'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: STUDENT DIRECTORY & PARENT CREDENTIALS
          Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Student'),
              onPressed: _showAddStudentDialog,
            ),
            body: FutureBuilder<List<Map<String, dynamic>>>(
              future: supabaseClient != null
                  ? supabaseClient!.from('students').select().order('created_at', ascending: false)
                  : Future.value([]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final students = snapshot.data!;
                if (students.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No students added yet. Tap "+ Add Student" below to register one.', textAlign: TextAlign.center),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, i) {
                    final s = students[i];
                    final phone = s['parent_phone'] ?? s['mobile_number'] ?? 'N/A';
                    final bYear = s['birth_year'] ?? s['student_dob'] ?? 'N/A';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                          child: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                        ),
                        title: Text(s['student_name'] ?? 'Student
