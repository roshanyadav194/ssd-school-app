import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dashboard_screen.dart';
import 'admin_hub_screen.dart';

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

  // PARENT LOGIN
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
            content: Text('No student record found matching credentials.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_user_type', 'parent');
        await prefs.setString('saved_student_data', jsonEncode(res));
        await prefs.setString('saved_phone', mobile);
        await prefs.setString('saved_dob', year);
      } else {
        await prefs.remove('saved_user_type');
        await prefs.remove('saved_student_data');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(studentData: res)),
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
        MaterialPageRoute(builder: (_) => const AdminHubScreen()),
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

  void _openRecoverySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_center_rounded, color: Color(0xFF1E3A8A)),
                SizedBox(width: 8),
                Text(
                  'Login Assistance & Recovery',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F1E36)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _selectedTab == 0
                  ? 'Parents can log in using the registered 10-digit mobile number and student birth year (e.g. 2012). Need to update your registered phone number?'
                  : 'Enter your Admin Email in the field above and tap below to send a Supabase password reset link.',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 16),
            if (_selectedTab == 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text('Request Credential Help on WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final uri = Uri.parse('https://wa.me/917880884750?text=Hello%20SSD%20Convent%20School%2C%20I%20need%20help%20with%20my%20Parent%20Portal%20login%20credentials.');
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.mark_email_Read_rounded, size: 18),
                  label: const Text('Send Admin Password Reset Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final email = _adminIdController.text.trim();
                    Navigator.pop(ctx);
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your Admin email first.')),
                      );
                      return;
                    }
                    try {
                      await _supabaseClient?.auth.resetPasswordForEmail(email);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password reset link sent to $email'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reset error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRememberMeToggle() {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              const Text(
                'Remember my login details',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
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

  Widget _buildParentLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registered Mobile Number',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36)),
        ),
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
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Student's Birth Year / DOB",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _birthYearController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.cake_rounded, color: Color(0xFF1E3A8A), size: 20),
            hintText: 'e.g. 2012 or 2012-05-14',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        _buildRememberMeToggle(),
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
            onPressed: _openRecoverySheet,
            icon: const Icon(Icons.help_outline_rounded, size: 16, color: Color(0xFF64748B)),
            label: const Text(
              'Trouble logging in? Get Credential Help',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Staff / Admin Email',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _adminIdController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF1E3A8A), size: 20),
            hintText: 'admin@ssdconvent.com',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF0F1E36), width: 1.5),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Security Passcode',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _adminPassController,
          obscureText: _obscureAdminPass,
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
            fillColor: const Color(0xFFF8FAFC),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF0F1E36), width: 1.5),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        _buildRememberMeToggle(),
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
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Login to Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: _openRecoverySheet,
            icon: const Icon(Icons.lock_reset_rounded, size: 16, color: Color(0xFF64748B)),
            label: const Text(
              'Forgot Admin Passcode?',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
            ),
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
                          BoxShadow(color: Color(0x261E3A8A), blurRadius: 14, offset: Offset(0, 6)),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'S.S.D. CONVENT SCHOOL',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F1E36)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Family & Administration Gateway',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? const Color(0xFF1E3A8A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Parent / Student',
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
                          duration: const Duration(milliseconds: 200),
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
                duration: const Duration(milliseconds: 220),
                child: _selectedTab == 0 ? _buildParentLoginForm() : _buildAdminLoginForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
