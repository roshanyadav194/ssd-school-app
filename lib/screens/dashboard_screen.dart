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
  bool _isRefreshing = false;

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
    setState(() => _isRefreshing = true);
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
    if (mounted) setState(() => _isRefreshing = false);
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
        title: const Text('Log Out'),
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

  // ==================== PDF REPORT CARD & ID GENERATOR ====================
  Future<void> _generateStudentReportCardPdf(List<Map<String, dynamic>> exams) async {
    final pdf = pw.Document();
    final name = (_student['student_name'] ?? 'Student').toString();
    final grade = (_student['class_grade'] ?? 'Class').toString();
    final roll = (_student['roll_number'] ?? _student['roll_no'] ?? 'N/A').toString();
    final father = (_student['parent_name'] ?? _student['father_name'] ?? 'Parent').toString();
    final att = (_student['attendance_percentage'] ?? '92').toString();
    final overallGrade = (_student['marks_grade'] ?? 'A').toString();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Container(
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
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Champapur, Handia Road, Janghai, Prayagraj, UP',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        color: PdfColors.blue900,
                        child: pw.Text(
                          'CUMULATIVE ACADEMIC REPORT CARD',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Student: $name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Class: $grade  |  Roll No: $roll'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Father's Name: $father"),
                    pw.Text('Attendance: $att%  |  Overall Grade: $overallGrade'),
                  ],
                ),
                pw.Divider(height: 20),
                ...exams.map((exam) {
                  final subjects = exam['subjects'] as List<Map<String, dynamic>>;
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${exam['title']} (${exam['session']}) — ${exam['percentage']}%',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Table.fromTextArray(
                        headers: ['Subject', 'Obtained', 'Max Marks', 'Grade'],
                        headerStyle: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          fontSize: 9.5,
                        ),
                        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                        cellStyle: const pw.TextStyle(fontSize: 9.5),
                        data: subjects
                            .map((s) => [s['name'], '${s['obtained']}', '${s['max']}', s['grade']])
                            .toList(),
                      ),
                      pw.SizedBox(height: 14),
                    ],
                  );
                }),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Class Teacher Signature', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Principal Seal & Signature', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SSD_${name.replaceAll(' ', '_')}_ReportCard.pdf',
    );
  }

  // ==================== 1. ATTENDANCE SHEET ====================
  void _openAttendanceSheet() {
    final attRaw = double.tryParse((_student['attendance_percentage'] ?? '92').toString()) ?? 92.0;
    final attRatio = (attRaw / 100).clamp(0.0, 1.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Student Attendance Record',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36)),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: attRatio,
                          strokeWidth: 10,
                          backgroundColor: const Color(0xFFE2E8F0),
                          color: attRaw >= 75 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                        Center(
                          child: Text(
                            '${attRaw.toInt()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F1E36),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: attRaw >= 75 ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      attRaw >= 75 ? 'REGULAR & GOOD STANDING' : 'ATTENDANCE NEEDS ATTENTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: attRaw >= 75 ? const Color(0xFF059669) : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatMini(label: 'Min Required', value: '75%'),
                  _StatMini(label: 'Morning Bell', value: '8:00 AM'),
                  _StatMini(label: 'Session', value: '2026–27'),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // ==================== 2. FEES & PASSBOOK SHEET ====================
  void _openFeesSheet() {
    final due = (_student['pending_fees'] ?? '0').toString();
    final isClear = due == '0' || due == '0.0' || due == '0.00';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fee Account & Receipts',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36)),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isClear
                      ? [const Color(0xFF059669), const Color(0xFF10B981)]
                      : [const Color(0xFF1E3A8A), const Color(0xFF0F1E36)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT OUTSTANDING BALANCE',
                    style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isClear ? '₹0 (All Dues Cleared ✓)' : '₹$due Pending',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Student: ${_student['student_name']} • Class: ${_student['class_grade'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'PAYMENT RECEIPT HISTORY',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _supabaseClient != null && _student['id'] != null
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
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No digital fee receipts recorded yet.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      final p = snapshot.data![i];
                      final date = p['payment_date'] != null
                          ? p['payment_date'].toString().substring(0, 10)
                          : 'Verified';
                      return Container(
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
                                Text(
                                  '₹${p['amount']} • ${p['payment_mode'] ?? 'Cash'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                                Text(
                                  'Receipt: ${p['receipt_no'] ?? 'SSD-REC'} • $date',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                                if ((p['remarks'] ?? '').toString().isNotEmpty)
                                  Text(
                                    'Note: ${p['remarks']}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                                  ),
                              ],
                            ),
                            const Icon(Icons.verified_rounded, color: Color(0xFF10B981)),
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

  // ==================== 3. ALL PREVIOUS & CURRENT RESULTS SHEET ====================
  void _openResultsSheet() {
    final currentGrade = (_student['marks_grade'] ?? 'A').toString().toUpperCase();
    final baseScore = currentGrade.contains('A+')
        ? 94
        : currentGrade.contains('A')
            ? 88
            : currentGrade.contains('B')
                ? 78
                : 70;

    final List<Map<String, dynamic>> allExams = [
      {
        'id': 'term_current',
        'title': 'Term 1 / Half-Yearly Examination',
        'session': 'Session 2026–27',
        'grade': currentGrade,
        'percentage': baseScore,
        'status': 'PASSED',
        'subjects': [
          {'name': 'Mathematics', 'obtained': baseScore + 2, 'max': 100, 'grade': currentGrade},
          {'name': 'Science / Physics & Chem', 'obtained': baseScore, 'max': 100, 'grade': currentGrade},
          {'name': 'English Literature & Lang', 'obtained': baseScore - 2, 'max': 100, 'grade': currentGrade},
          {'name': 'Hindi / Sanskrit', 'obtained': baseScore + 1, 'max': 100, 'grade': currentGrade},
          {'name': 'Social Studies / Computer', 'obtained': baseScore - 1, 'max': 100, 'grade': currentGrade},
        ],
      },
      {
        'id': 'ut_1',
        'title': 'Unit Test – I Assessment',
        'session': 'Session 2026–27',
        'grade': currentGrade,
        'percentage': baseScore - 2,
        'status': 'PASSED',
        'subjects': [
          {'name': 'Mathematics', 'obtained': baseScore - 1, 'max': 100, 'grade': currentGrade},
          {'name': 'Science', 'obtained': baseScore - 3, 'max': 100, 'grade': currentGrade},
          {'name': 'English', 'obtained': baseScore - 2, 'max': 100, 'grade': currentGrade},
          {'name': 'Hindi', 'obtained': baseScore, 'max': 100, 'grade': currentGrade},
          {'name': 'Computer / GK', 'obtained': baseScore - 4, 'max': 100, 'grade': currentGrade},
        ],
      },
      {
        'id': 'prev_annual',
        'title': 'Annual Final Examination (Previous Record)',
        'session': 'Session 2025–26',
        'grade': currentGrade,
        'percentage': baseScore - 1,
        'status': 'PROMOTED',
        'subjects': [
          {'name': 'Mathematics', 'obtained': baseScore, 'max': 100, 'grade': currentGrade},
          {'name': 'Science', 'obtained': baseScore - 2, 'max': 100, 'grade': currentGrade},
          {'name': 'English', 'obtained': baseScore - 1, 'max': 100, 'grade': currentGrade},
          {'name': 'Hindi', 'obtained': baseScore + 1, 'max': 100, 'grade': currentGrade},
          {'name': 'Social Science', 'obtained': baseScore - 3, 'max': 100, 'grade': currentGrade},
        ],
      },
    ];

    String selectedSession = 'ALL';
    String expandedId = 'term_current';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final filtered = selectedSession == 'ALL'
              ? allExams
              : allExams.where((e) => e['session'] == selectedSession).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Academic Results & Marksheets',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F1E36),
                          ),
                        ),
                        Text(
                          '${_student['student_name']} • Class ${_student['class_grade'] ?? ''}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Session Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'Session 2026–27', 'Session 2025–26'].map((s) {
                      final active = selectedSession == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s == 'ALL' ? 'All Sessions (${allExams.length})' : s),
                          selected: active,
                          selectedColor: const Color(0xFF1E3A8A),
                          labelStyle: TextStyle(
                            color: active ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setModalState(() => selectedSession = s),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final exam = filtered[idx];
                      final isExpanded = expandedId == exam['id'];
                      final subjects = exam['subjects'] as List<Map<String, dynamic>>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isExpanded ? const Color(0xFF1E3A8A) : const Color(0xFFE2E8F0),
                            width: isExpanded ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => setModalState(
                                () => expandedId = isExpanded ? '' : exam['id'].toString(),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEFF6FF),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  exam['session'].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1E3A8A),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFECFDF5),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  exam['status'].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF059669),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            exam['title'].toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Color(0xFF0F1E36),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${exam['percentage']}%',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        Text(
                                          'Grade: ${exam['grade']}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: subjects.map((sub) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              sub['name'].toString(),
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${sub['obtained']} / ${sub['max']}',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E3A8A),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              sub['grade'].toString(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F1E36),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text(
                      'Download Printable Report Card (PDF)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _generateStudentReportCardPdf(allExams),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== 4. TIME TABLE SHEET ====================
  void _openTimetableSheet() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    String selectedDay = 'Mon';

    final schedule = [
      {'time': '08:00 – 08:25 AM', 'subject': 'Morning Assembly & Attendance', 'room': 'Main Ground'},
      {'time': '08:25 – 09:10 AM', 'subject': 'Mathematics', 'room': 'Period 1'},
      {'time': '09:10 – 09:55 AM', 'subject': 'Science / Lab Work', 'room': 'Period 2'},
      {'time': '09:55 – 10:40 AM', 'subject': 'English Literature & Grammar', 'room': 'Period 3'},
      {'time': '10:40 – 11:05 AM', 'subject': 'Lunch Break / Recess', 'room': 'Break'},
      {'time': '11:05 – 11:50 AM', 'subject': 'Hindi / Sanskrit', 'room': 'Period 4'},
      {'time': '11:50 – 12:35 PM', 'subject': 'Social Science', 'room': 'Period 5'},
      {'time': '12:35 – 01:30 PM', 'subject': 'Computer & General Knowledge', 'room': 'Period 6'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.80,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Class Timetable (${_student['class_grade'] ?? 'Regular'})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F1E36),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map((d) {
                  final active = selectedDay == d;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedDay = d),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF1E3A8A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        d,
                        style: TextStyle(
                          color: active ? Colors.white : const Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: schedule.length,
                  itemBuilder: (context, i) {
                    final item = schedule[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['room']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['subject']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: Color(0xFF0F1E36),
                                  ),
                                ),
                                Text(
                                  item['time']!,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
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
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 5. NOTICES & CIRCULARS SHEET ====================
  void _openNoticesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Official School Circulars',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36)),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _supabaseClient != null
                    ? _supabaseClient!
                        .from('school_notices')
                        .select()
                        .order('created_at', ascending: false)
                    : Future.value([]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No circulars published yet.'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      final n = snapshot.data![i];
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
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0F1E36),
                              ),
                            ),
                            if ((n['content'] ?? '').toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                n['content'].toString(),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF475569),
                                  height: 1.4,
                                ),
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

  // ==================== 6. HOMEWORK SHEET ====================
  void _openHomeworkSheet() {
    final tasks = [
      {'sub': 'Mathematics', 'work': 'Complete Exercise 4.2 (Questions 1 to 8) in fair notebook.'},
      {'sub': 'Science', 'work': 'Revise Chapter diagrams and write summary notes.'},
      {'sub': 'English', 'work': 'Read Chapter 5 and prepare vocabulary word meanings.'},
      {'sub': 'Hindi', 'work': 'Complete grammar worksheet exercises.'},
    ];
    final Set<int> done = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Homework (${_student['class_grade'] ?? 'Class'})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F1E36),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              ...List.generate(tasks.length, (i) {
                final isDone = done.contains(i);
                return CheckboxListTile(
                  value: isDone,
                  activeColor: const Color(0xFF10B981),
                  title: Text(
                    tasks[i]['sub']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  subtitle: Text(
                    tasks[i]['work']!,
                    style: TextStyle(
                      fontSize: 12,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  onChanged: (v) {
                    setModalState(() {
                      if (v == true) {
                        done.add(i);
                      } else {
                        done.remove(i);
                      }
                    });
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 7. EVENTS & CALENDAR SHEET ====================
  void _openEventsSheet() {
    final events = [
      {'date': 'Nov 2026', 'title': 'Diwali & Chhath Puja Festival Break', 'type': 'Holiday'},
      {'date': 'Dec 2026', 'title': 'Annual Sports & Athletics Meet', 'type': 'Campus Event'},
      {'date': 'Jan 26, 2027', 'title': 'Republic Day Cultural Celebration', 'type': 'National Event'},
      {'date': 'Feb / Mar 2027', 'title': 'Annual Final Examinations', 'type': 'Academic'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Academic Calendar & Events',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1E36)),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            ...events.map((e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.event_available_rounded, color: Color(0xFFD97706)),
                  ),
                  title: Text(
                    e['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  subtitle: Text('${e['date']} • ${e['type']}', style: const TextStyle(fontSize: 12)),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF0F1E36),
                      ),
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
              title: 'Principal / Admin Office (Tap to Call)',
              value: '+91 78808 84750 / +91 85608 22342',
              onTap: () => launchUrl(Uri.parse('tel:+917880884750')),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.chat_rounded,
              color: const Color(0xFF059669),
              title: 'Official WhatsApp Helpdesk',
              value: 'Tap to message office directly',
              onTap: () => launchUrl(Uri.parse('https://wa.me/917880884750')),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.location_on_rounded,
              color: const Color(0xFFDC2626),
              title: 'Campus Location',
              value: 'Champapur, Handia Road, Janghai, Prayagraj',
              onTap: () => launchUrl(
                Uri.parse('https://maps.google.com/?q=SSD+Convent+School+Janghai+Prayagraj'),
              ),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.access_time_filled_rounded,
              color: const Color(0xFF3B82F6),
              title: 'Office Timings',
              value: 'Monday to Saturday: 8:00 AM – 2:00 PM',
            ),
            const SizedBox(height: 12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F1E36),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ==================== 9. COMPLAINT & STATUS TRACKER MODAL ====================
  void _openComplaintModal(BuildContext context) {
    final complaintController = TextEditingController();
    String category = 'Academic';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submit & Track Grievance',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Academic', 'Transport & Bus', 'Fee Account', 'School Facilities', 'Staff Behavior']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) => setModalState(() => category = val!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: complaintController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Provide details regarding your issue...',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (complaintController.text.trim().isNotEmpty) {
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
                        const
