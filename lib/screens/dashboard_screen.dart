import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'splash_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const DashboardScreen({super.key, required this.studentData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _lastBackPressTime;
  late Map<String, dynamic> _student;
  final Set<int> _completedHomework = {};

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
    _student = Map<String, dynamic>.from(widget.studentData);
    _refreshStudentRecord();
  }

  Future<void> _refreshStudentRecord() async {
    final client = _supabaseClient;
    if (client == null || _student['id'] == null) return;
    try {
      final latest = await client
          .from('students')
          .select()
          .eq('id', _student['id'])
          .maybeSingle();
      if (latest != null && mounted) {
        setState(() => _student = latest);
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getString('saved_user_type') == 'parent') {
          await prefs.setString('saved_student_data', jsonEncode(latest));
        }
      }
    } catch (_) {}
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    SystemNavigator.pop();
    return true;
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of the student portal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _launchAction(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // ==================== PDF REPORT & ID GENERATOR ====================
  Future<void> _generateStudentIdAndReportPdf() async {
    final pdf = pw.Document();
    final name = (_student['student_name'] ?? 'Student').toString();
    final grade = (_student['class_grade'] ?? _student['class_name'] ?? 'Class 10').toString();
    final roll = (_student['roll_number'] ?? _student['roll_no'] ?? '01').toString();
    final adm = (_student['admission_number'] ?? 'SSD-${_student['id']?.toString().substring(0, 4) ?? '101'}').toString();
    final father = (_student['parent_name'] ?? _student['father_name'] ?? 'Parent').toString();
    final phone = (_student['parent_phone'] ?? _student['mobile_number'] ?? 'N/A').toString();
    final att = (_student['attendance_percentage'] ?? '92').toString();
    final marks = (_student['marks_grade'] ?? 'A').toString();
    final feeDue = (_student['pending_fees'] ?? '0').toString();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Container(
          padding: const pw.EdgeInsets.all(28),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue900, width: 2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'S.S.D. CONVENT SCHOOL',
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Champapur, Handia Road, Janghai, Prayagraj, UP', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      color: PdfColors.blue900,
                      child: pw.Text(
                        'STUDENT ACADEMIC & IDENTITY SUMMARY',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 22),
              pw.Text('Student Name: $name', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text('Class & Section: $grade   |   Roll No: $roll   |   Admission No: $adm'),
              pw.SizedBox(height: 6),
              pw.Text('Father / Guardian: $father   |   Registered Mobile: +91 $phone'),
              pw.Divider(height: 24),
              pw.Text('ACADEMIC & FEE STANDING', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 8),
              pw.Text('• Overall Attendance: $att%'),
              pw.SizedBox(height: 4),
              pw.Text('• Current Term Evaluation Grade: $marks'),
              pw.SizedBox(height: 4),
              pw.Text('• Fee Balance Status: ${feeDue == '0' ? 'ALL DUES CLEARED' : 'Pending INR $feeDue'}'),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Verified Digital Copy • S.S.D. Convent School Family Portal',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SSD_${name.replaceAll(' ', '_')}_Summary.pdf',
    );
  }

  // ==================== 1. ATTENDANCE MODAL ====================
  void _openAttendanceModal() {
    final attRaw = double.tryParse((_student['attendance_percentage'] ?? '92').toString()) ?? 92.0;
    final attRatio = (attRaw / 100).clamp(0.0, 1.0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Student Attendance Tracker', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36))),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: attRatio,
                          strokeWidth: 7,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        ),
                        Center(
                          child: Text(
                            '${attRaw.toInt()}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _student['student_name'] ?? 'Student',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attRaw >= 75
                              ? 'Status: Regular & Eligible for Board/Term Exams ✓'
                              : 'Status: Below 75% Benchmark - Regularize Attendance',
                          style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('SESSION SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatBox('Minimum Required', '75%', const Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniStatBox('Current Standing', '${attRaw.toInt()}%', const Color(0xFF10B981)),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // ==================== 2. FEES & RECEIPTS MODAL ====================
  void _openFeesModal() {
    final pending = (_student['pending_fees'] ?? '0').toString();
    final isClear = pending == '0' || pending == '0.0' || pending.isEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fee Account & Digital Receipts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36))),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isClear ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isClear ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isClear ? 'ALL DUES CLEARED' : 'OUTSTANDING FEE DUE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isClear ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isClear ? '₹0 (No Pending Balance)' : '₹$pending',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isClear ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isClear ? Icons.verified_rounded : Icons.account_balance_wallet_rounded,
                    size: 36,
                    color: isClear ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('RECORDED PAYMENT RECEIPTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: (_supabaseClient != null && _student['id'] != null)
                    ? _supabaseClient!
                        .from('fee_payments')
                        .select()
                        .eq('student_id', _student['id'])
                        .order('payment_date', ascending: false)
                    : Future.value([]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        isClear
                            ? 'All fees are marked cleared by school administration.'
                            : 'No online receipts logged yet. Visit school accounts desk for payment.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final p = list[i];
                      final date = p['payment_date'] != null
                          ? p['payment_date'].toString().substring(0, 10)
                          : 'Verified';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${p['amount']} • ${p['payment_mode'] ?? 'Cash'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F1E36)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Receipt: ${p['receipt_no'] ?? 'SSD-REC'} • $date',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                                if ((p['remarks'] ?? '').toString().isNotEmpty)
                                  Text(
                                    'Note: ${p['remarks']}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF1E3A8A)),
                                  ),
                              ],
                            ),
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: const Text('Download Fee & Academic Statement PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _generateStudentIdAndReportPdf();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 3. RESULTS & REPORT CARD MODAL ====================
  void _openResultsModal() {
    final grade = (_student['marks_grade'] ?? 'A').toString();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Examination Results & Grade', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36))),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('OVERALL EVALUATION GRADE', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 10, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        _student['student_name'] ?? 'Student',
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Class: ${_student['class_grade'] ?? 'Assigned'}',
                        style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      grade,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F1E36),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.print_rounded, size: 18),
                label: const Text('Print Official Report Summary (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _generateStudentIdAndReportPdf();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ==================== 4. TIME TABLE MODAL ====================
  void _openTimeTableModal() {
    final schedule = [
      {'time': '08:00 AM - 08:25 AM', 'sub': 'Morning Assembly & Prayer', 'room': 'Main Ground'},
      {'time': '08:25 AM - 09:10 AM', 'sub': 'Mathematics / Quantitative', 'room': 'Period 1'},
      {'time': '09:10 AM - 09:55 AM', 'sub': 'Science (Physics / Chem / Bio)', 'room': 'Period 2'},
      {'time': '09:55 AM - 10:40 AM', 'sub': 'English Literature & Grammar', 'room': 'Period 3'},
      {'time': '10:40 AM - 11:05 AM', 'sub': 'Recess / Lunch Break', 'room': 'Break'},
      {'time': '11:05 AM - 11:50 AM', 'sub': 'Hindi / Sanskrit Literature', 'room': 'Period 4'},
      {'time': '11:50 AM - 12:35 PM', 'sub': 'Social Studies / Core Stream', 'room': 'Period 5'},
      {'time': '12:35 PM - 01:20 PM', 'sub': 'Computer / IT & Practical Lab', 'room': 'Period 6'},
      {'time': '01:20 PM - 02:00 PM', 'sub': 'Sports / Library / Revision', 'room': 'Period 7'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Class Time Table', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36))),
                    Text('Monday – Saturday • ${_student['class_grade'] ?? 'Standard Schedule'}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: schedule.length,
                itemBuilder: (context, idx) {
                  final item = schedule[idx];
                  final isBreak = item['room'] == 'Break';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBreak ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isBreak ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isBreak ? const Color(0xFFD97706) : const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['room']!,
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['sub']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36))),
                              const SizedBox(height: 2),
                              Text(item['time']!, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 5. NOTICES & CIRCULARS MODAL ====================
  void _openNoticesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Official School Circulars', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36))),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _supabaseClient != null
                    ? _supabaseClient!.from('school_notices').select().order('created_at', ascending: false)
                    : Future.value([]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notices = snapshot.data ?? [];
                  if (notices.isEmpty) {
                    return const Center(child: Text('No official notices published yet.'));
                  }
                  return ListView.builder(
                    itemCount: notices.length,
                    itemBuilder: (context, i) {
                      final n = notices[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    n['tag'] ?? 'NOTICE',
                                    style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  n['date'] ?? '',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              n['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F1E36)),
                            ),
                            if ((n['content'] ?? '').toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                n['content'].toString(),
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 6. HOMEWORK DIARY MODAL ====================
  void _openHomeworkModal() {
    final tasks = [
      {'sub': 'Mathematics', 'task': 'Complete Exercise problems & revise formulas in notebook.'},
      {'sub': 'Science', 'task': 'Prepare neat labeled diagrams & review chapter questions.'},
      {'sub': 'English', 'task': 'Complete grammar worksheet and reading comprehension.'},
      {'sub': 'Hindi / Social Science', 'task': 'Revise syllabus notes for upcoming class test.'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Daily Homework & Study Diary', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36))),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              ...List.generate(tasks.length, (idx) {
                final done = _completedHomework.contains(idx);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF10B981),
                  value: done,
                  onChanged: (v) {
                    setModalState(() {
                      if (v == true) {
                        _completedHomework.add(idx);
                      } else {
                        _completedHomework.remove(idx);
                      }
                    });
                  },
                  title: Text(
                    tasks[idx]['sub']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(tasks[idx]['task']!, style: const TextStyle(fontSize: 12)),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 7. EVENTS & HOLIDAYS MODAL ====================
  void _openEventsModal() {
    final events = [
      {'title': 'Parent-Teacher Meeting (PTM)', 'date': 'First Saturday of Month', 'type': 'Academic'},
      {'title': 'Unit & Term Assessments', 'date': 'As per Exam Circular', 'type': 'Examination'},
      {'title': 'Annual Sports & Cultural Meet', 'date': 'Winter Session', 'type': 'Campus Event'},
      {'title': 'Gazetted & Festival Holidays', 'date': 'Notified via Circulars', 'type': 'Holiday'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Academic Calendar & Events', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36))),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            ...events.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36))),
                          Text(e['date']!, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                        child: Text(e['type']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ==================== 8. CONTACT DESK MODAL ====================
  void _showContactDeskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.contact_phone_rounded, color: Color(0xFF1E3A8A), size: 24),
                    SizedBox(width: 10),
                    Text(
                      'School Contact Desk',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F1E36)),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(height: 24),
            _buildContactRow(
              icon: Icons.phone_in_talk_rounded,
              color: const Color(0xFF10B981),
              title: 'Principal / Admin Office',
              value: '+91 78808 84750 / +91 85608 22342',
              onTap: () => _launchAction('tel:+917880884750'),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.chat_bubble_rounded,
              color: const Color(0xFF059669),
              title: 'Official WhatsApp Desk',
              value: 'Tap to message +91 78808 84750',
              onTap: () => _launchAction('https://wa.me/917880884750'),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.location_on_rounded,
              color: const Color(0xFFDC2626),
              title: 'Campus Location',
              value: 'Champapur, Handia Road, Janghai, Prayagraj',
              onTap: () => _launchAction('https://maps.google.com/?q=SSD+Convent+School+Janghai+Prayagraj'),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.access_time_filled_rounded,
              color: const Color(0xFF3B82F6),
              title: 'Office Timings',
              value: 'Monday to Saturday: 8:00 AM – 2:00 PM',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36))),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ==================== 9. COMPLAINT / GRIEVANCE MODAL ====================
  void _openComplaintModal(BuildContext context) {
    final complaintController = TextEditingController();
    String category = 'Academic';
    bool isSubmitting = false;

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
                  const Text('Submit Grievance / Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (complaintController.text.trim().isEmpty) return;
                          setModalState(() => isSubmitting = true);
                          final client = _supabaseClient;
                          if (client != null) {
                            try {
                              await client.from('school_complaints').insert({
                                'parent_name': _student['parent_name'] ?? _student['father_name'] ?? 'Parent',
                                'student_name': _student['student_name'] ?? 'Student',
                                'category': category,
                                'details': complaintController.text.trim(),
                                'status': 'Under Review',
                              });
                            } catch (_) {}
                          }
                          if (!context.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Grievance submitted directly to school management.'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                  child: isSubmitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentName = _student['parent_name'] ?? _student['father_name'] ?? 'Parent';
    final studentName = _student['student_name'] ?? 'Student';
    final className = _student['class_grade'] ?? _student['class_name'] ?? 'Assigned';
    final att = _student['attendance_percentage'] ?? '92';
    final feeDue = (_student['pending_fees'] ?? '0').toString();
    final marks = _student['marks_grade'] ?? 'A';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)]),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'S.S.D. Convent School',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F1E36)),
                          ),
                          Text(
                            'Verified Family Portal',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.badge_rounded, color: Color(0xFF1E3A8A), size: 22),
                      tooltip: 'Download ID & Dossier PDF',
                      onPressed: _generateStudentIdAndReportPdf,
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 22),
                      tooltip: 'Log Out',
                      onPressed: _handleLogout,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF1E3A8A),
                  onRefresh: _refreshStudentRecord,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium Student Identity Hero Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF0F1E36)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(color: Color(0x291E3A8A), blurRadius: 18, offset: Offset(0, 8)),
                            ],
                          ),
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
                                        Text(
                                          'Welcome, $parentName',
                                          style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          studentName,
                                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Class: $className • Roll No: ${_student['roll_number'] ?? 'N/A'}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _generateStudentIdAndReportPdf,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFFDE68A), size: 15),
                                          SizedBox(width: 5),
                                          Text('ID / PDF', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.09),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildHeroMetric('Attendance', '$att%', _openAttendanceModal),
                                    Container(width: 1, height: 24, color: Colors.white24),
                                    _buildHeroMetric('Fee Status', feeDue == '0' ? 'Cleared ✓' : '₹$feeDue', _openFeesModal),
                                    Container(width: 1, height: 24, color: Colors.white24),
                                    _buildHeroMetric('Term Grade', '$marks', _openResultsModal),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'STUDENT & FAMILY SERVICES',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.95,
                          children: [
                            _buildGridCard(Icons.calendar_month_rounded, 'Attendance', const Color(0xFF10B981), _openAttendanceModal),
                            _buildGridCard(Icons.account_balance_wallet_rounded, 'Fees & Rcpt', const Color(0xFF8B5CF6), _openFeesModal),
                            _buildGridCard(Icons.insert_chart_rounded, 'Results', const Color(0xFFF59E0B), _openResultsModal),
                            _buildGridCard(Icons.access_time_filled_rounded, 'Time Table', const Color(0xFF3B82F6), _openTimeTableModal),
                            _buildGridCard(Icons.campaign_rounded, 'Notices', const Color(0xFFEC4899), _openNoticesModal),
                            _buildGridCard(Icons.report_problem_rounded, 'Complaint', const Color(0xFFDC2626), () => _openComplaintModal(context)),
                            _buildGridCard(Icons.contact_phone_rounded, 'Contact Desk', const Color(0xFF0284C7), () => _showContactDeskModal(context)),
                            _buildGridCard(Icons.menu_book_rounded, 'Homework', const Color(0xFF06B6D4), _openHomeworkModal),
                            _buildGridCard(Icons.celebration_rounded, 'Events', const Color(0xFF84CC16), _openEventsModal),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'LATEST CIRCULARS',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.8),
                            ),
                            TextButton(
                              onPressed: _openNoticesModal,
                              child: const Text('View All →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                            ),
                          ],
                        ),
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                                child: const Text('No circulars posted yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              );
                            }
                            return Column(
                              children: snapshot.data!
                                  .map((n) => InkWell(
                                        onTap: _openNoticesModal,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
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
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F1E36)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            );
                          },
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

  Widget _buildHeroMetric(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
        ],
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
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 3))],
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
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F1E36)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
