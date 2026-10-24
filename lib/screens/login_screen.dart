import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
import 'admin_hub_screen.dart';
import 'splash_screen.dart';

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

  bool _rememberMe = true;
  bool _isLoading = false;
  bool _obscureAdminPass = true;

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
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString('saved_phone');
      final savedDob = prefs.getString('saved_dob');
      final savedAdminEmail = prefs.getString('saved_admin_email');

      if (mounted) {
        setState(() {
          if (savedPhone != null) _mobileController.text = savedPhone;
          if (savedDob != null) _birthYearController.text = savedDob;
          if (savedAdminEmail != null) _adminIdController.text = savedAdminEmail;
        });
      }
    } catch (_) {}
  }

  // PARENT LOGIN (Multi-sibling safe!)
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
      final client = _supabaseClient;
      if (client == null) throw Exception('Database connection not ready.');

      // Fetch all children linked to this parent's mobile number
      final allSiblings = await client
          .from('students')
          .select()
          .or('mobile_number.eq.$mobile,parent_phone.eq.$mobile');

      // Filter by birth_year or student_dob
      final matching = allSiblings.where((s) {
        final by = (s['birth_year'] ?? '').toString().trim();
        final dob = (s['student_dob'] ?? '').toString().trim();
        return by == year || dob == year || dob.startsWith(year);
      }).toList();

      setState(() => _isLoading = false);

      if (matching.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No student record found matching credentials.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final selectedStudent = matching.first;

      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_user_type', 'parent');
        await prefs.setString('saved_student_data', jsonEncode(selectedStudent));
        await prefs.setString('saved_siblings_list', jsonEncode(allSiblings));
        await prefs.setString('saved_phone', mobile);
        await prefs.setString('saved_dob', year);
      } else {
        await prefs.remove('saved_user_type');
        await prefs.remove('saved_student_data');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        createSmoothRoute(DashboardScreen(studentData: selectedStudent)),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ADMIN LOGIN
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
      final client = _supabaseClient;
      if (client == null) throw Exception('Database connection not ready.');

      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) throw const AuthException('Invalid admin credentials.');

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
            content: Text('Access Denied: Account not authorized as Admin.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_user_type', 'admin');
        await prefs.setString('saved_admin_email', email);
      } else {
        await prefs.remove('saved_user_type');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        createSmoothRoute(const AdminHubScreen()),
      );
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin login error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // PASSWORD RECOVERY FOR ADMIN
  Future<void> _handleForgotPassword() async {
    final email = _adminIdController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your Staff/Admin Email above first to receive a password reset link.'),
          backgroundColor: Color(0xFF1E3A8A),
        ),
      );
      return;
    }
    try {
      final client = _supabaseClient;
      if (client != null) {
        await client.auth.resetPasswordForEmail(email);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password recovery link sent to $email'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recovery notice: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildRememberMeToggle(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _rememberMe ? Icons.verified_user_rounded : Icons.shield_outlined,
                size: 18,
                color: _rememberMe ? const Color(0xFF10B981) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                'Remember my login details',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
          Switch(
            value: _rememberMe,
            activeColor: const Color(0xFF1E3A8A),
            activeTrackColor: const Color(0xFF93C5FD),
            onChanged: (val) => setState(() => _rememberMe = val),
          ),
        ],
      ),
    );
  }

  Widget _buildParentLoginForm(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F1E36);
    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Column(
      key: const ValueKey('parent_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registered Mobile Number',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_rounded, color: Color(0xFF1E3A8A), size: 20),
                  const SizedBox(width: 8),
                  Text('+91', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ),
            hintText: 'Enter 10-digit number',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: fieldBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.6)),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Student's Birth Year / DOB",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _birthYearController,
          keyboardType: TextInputType.text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.cake_rounded, color: Color(0xFF1E3A8A), size: 20),
            hintText: 'e.g. 2012 or 2012-05-14',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: fieldBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.6)),
          ),
        ),
        _buildRememberMeToggle(isDark),
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
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Access Student Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  title: const Text('Parent Login Assistance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  content: const Text(
                    'Use the 10-digit mobile number registered at S.S.D. Convent School along with your child\'s birth year (e.g. 2012).\n\nIf your mobile number has changed, please contact the school office desk at +91 78808 84750.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got It')),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help_outline_rounded, size: 16, color: Color(0xFF64748B)),
            label: const Text('Trouble logging in? View Help', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminLoginForm(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F1E36);
    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Column(
      key: const ValueKey('admin_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff / Admin Email',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _adminIdController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF1E3A8A), size: 20),
            hintText: 'admin@ssdconvent.com',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: fieldBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.6)),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Security Passcode',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
            ),
            GestureDetector(
              onTap: _handleForgotPassword,
              child: const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _adminPassController,
          obscureText: _obscureAdminPass,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF1E3A8A), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureAdminPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: () => setState(() => _obscureAdminPass = !_obscureAdminPass),
            ),
            hintText: 'Enter password',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: fieldBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.6)),
          ),
        ),
        _buildRememberMeToggle(isDark),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFF0F1E36),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _handleAdminLogin,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1120) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F1E36),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: toggleSSDTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(color: Color(0x291E3A8A), blurRadius: 14, offset: Offset(0, 6)),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'S.S.D. CONVENT SCHOOL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F1E36),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Family & Staff Authentication Gateway',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? const Color(0xFF1E3A8A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Parent Portal',
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? const Color(0xFF0F1E36) : Colors.transparent,
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
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _selectedTab == 0
                    ? _buildParentLoginForm(isDark)
                    : _buildAdminLoginForm(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
