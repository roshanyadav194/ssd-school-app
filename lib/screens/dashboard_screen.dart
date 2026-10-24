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
  List<Map<String, dynamic>> _siblings = [];
  Set<String> _completedHomeworkIds = {};

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
    _loadSiblingsAndLocalState();
    _refreshStudentFromCloud();
  }

  Future<void> _loadSiblingsAndLocalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doneHw = prefs.getStringList('done_hw_${_student['id']}') ?? [];
      setState(() => _completedHomeworkIds = doneHw.toSet());

      final phone = (_student['parent_phone'] ?? _student['mobile_number'] ?? '').toString().trim();
      if (phone.isNotEmpty && _supabaseClient != null) {
        final list = await _supabaseClient!
            .from('students')
            .select()
            .or('mobile_number.eq.$phone,parent_phone.eq.$phone');
        if (mounted && list.isNotEmpty) {
          setState(() => _siblings = List<Map<String, dynamic>>.from(list));
        }
      }
    } catch (_) {}
  }

  Future<void> _refreshStudentFromCloud() async {
    try {
      if (_supabaseClient != null && _student['id'] != null) {
        final fresh = await _supabaseClient!
            .from('students')
            .select()
            .eq('id', _student['id'])
            .maybeSingle();
        if (fresh != null && mounted) {
          setState(() => _student = fresh);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_student_data', jsonEncode(fresh));
        }
      }
    } catch (_) {}
  }

  Future<void> _launchExternal(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // STANDARD ANDROID DOUBLE-TAP TO EXIT
  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
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
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of the student portal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_user_type');
      await prefs.remove('saved_student_data');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        createSmoothRoute(const SplashScreen()),
        (route) => false,
      );
    }
  }

  // ==================== OFFICIAL REPORT CARD PDF GENERATOR ====================
  Future<void> _downloadStudentReportPdf() async {
    final pdf = pw.Document();
    final name = (_student['student_name'] ?? 'Student').toString();
    final grade = (_student['class_grade'] ?? _student['class_name'] ?? 'Class').toString();
    final roll = (_student['roll_number'] ?? _student['roll_no'] ?? 'N/A').toString();
    final adm = (_student['admission_number'] ?? _student['scholar_no'] ?? 'SSD-2026').toString();
    final father = (_student['parent_name'] ?? _student['father_name'] ?? 'Parent').toString();
    final phone = (_student['parent_phone'] ?? _student['mobile_number'] ?? 'N/A').toString();
    final att = (_student['attendance_percentage'] ?? '92').toString();
    final marksGrade = (_student['marks_grade'] ?? 'A').toString();
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
                    pw.Text('Champapur, Handia Road, Janghai, Prayagraj, UP', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      color: PdfColors.blue900,
                      child: pw.Text(
                        'OFFICIAL ACADEMIC & PROGRESS REPORT (2026-27)',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 22),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(children: [
                    _pdfCell('Student Name', isHeader: true),
                    _pdfCell(name),
                    _pdfCell('Admission No', isHeader: true),
                    _pdfCell(adm),
                  ]),
                  pw.TableRow(children: [
                    _pdfCell('Class & Section', isHeader: true),
                    _pdfCell(grade),
                    _pdfCell('Roll Number', isHeader: true),
                    _pdfCell(roll),
                  ]),
                  pw.TableRow(children: [
                    _pdfCell('Father / Guardian', isHeader: true),
                    _pdfCell(father),
                    _pdfCell('Registered Mobile', isHeader: true),
                    _pdfCell('+91 $phone'),
                  ]),
                  pw.TableRow(children: [
                    _pdfCell('Attendance Standing', isHeader: true),
                    _pdfCell('$att%'),
                    _pdfCell('Overall Grade', isHeader: true),
                    _pdfCell('Grade $marksGrade'),
                  ]),
                  pw.TableRow(children: [
                    _pdfCell('Fee Account Status', isHeader: true),
                    _pdfCell(feeDue == '0' ? 'ALL DUES CLEARED' : 'Pending: INR $feeDue'),
                    _pdfCell('Portal Verification', isHeader: true),
                    _pdfCell('Verified Digital Copy'),
                  ]),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Class Teacher Sign', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Principal / Official Seal', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SSD_${name.replaceAll(' ', '_')}_ReportCard.pdf',
    );
  }

  // ==================== OFFICIAL FEE RECEIPT PDF GENERATOR ====================
  Future<void> _downloadFeeReceiptPdf(Map<String, dynamic> payment) async {
    final pdf = pw.Document();
    final name = (_student['student_name'] ?? 'Student').toString();
    final grade = (_student['class_grade'] ?? 'N/A').toString();
    final rcpt = (payment['receipt_no'] ?? 'SSD-REC').toString();
    final amount = (payment['amount'] ?? '0').toString();
    final mode = (payment['payment_mode'] ?? 'Cash').toString();
    final date = payment['payment_date'] != null
        ? payment['payment_date'].toString().substring(0, 10)
        : DateTime.now().toString().substring(0, 10);
    final remarks = (payment['remarks'] ?? 'Tuition / School Fee').toString();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
        build: (pw.Context ctx) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 1.5)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('S.S.D. CONVENT SCHOOL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Champapur, Handia Rd, Janghai, Prayagraj', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    color: PdfColors.green800,
                    child: pw.Text('OFFICIAL FEE RECEIPT', style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt No: $rcpt', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Date: $date', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(children: [
                    _pdfCell('Student Name', isHeader: true),
                    _pdfCell(name),
                    _pdfCell('Class', isHeader: true),
                    _pdfCell(grade),
                  ]),
                  pw.TableRow(children: [
                    _pdfCell('Amount Paid', isHeader: true),
                    _pdfCell('INR $amount /-'),
                    _pdfCell('Payment Mode', isHeader: true),
                    _pdfCell(mode),
                  ]),
                  pw.TableRow(children: [
                    _pdfCell('Remarks / Term', isHeader: true),
                    _pdfCell(remarks),
                    _pdfCell('Status', isHeader: true),
                    _pdfCell('PAID & VERIFIED'),
                  ]),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Computer Generated Digital Receipt', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Text('Authorized Signatory • S.S.D. Convent School', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SSD_FeeReceipt_$rcpt.pdf',
    );
  }

  static pw.Widget _pdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blue900 : PdfColors.black,
        ),
      ),
    );
  }

  // ==================== 1. ATTENDANCE MODAL ====================
  void _openAttendanceSheet() {
    final attRaw = double.tryParse((_student['attendance_percentage'] ?? '92').toString()) ?? 92.0;
    final attPercent = (attRaw.clamp(0.0, 100.0)) / 100.0;
    final isGood = attRaw >= 75;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Attendance Analytics', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: attPercent),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, val, _) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: val,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGood ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(val * 100).toInt()}%',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      const Text('Overall Present', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isGood ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    isGood ? Icons.verified_rounded : Icons.warning_amber_rounded,
                    color: isGood ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isGood
                          ? 'Excellent regularity! Meets S.S.D. Convent School\'s 75% mandatory board requirement.'
                          : 'Attendance is below 75%. Please ensure regular daily attendance.',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 2. FEES & RECEIPTS MODAL ====================
  void _openFeesSheet() {
    final pending = (_student['pending_fees'] ?? '0').toString();
    final isClear = pending == '0' || pending == '0.00' || pending.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fee Account & Digital Receipts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURRENT OUTSTANDING DUES', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        isClear ? '₹0 (All Dues Cleared ✓)' : '₹$pending',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text('Student: ${_student['student_name']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('OFFICIAL PAYMENT RECEIPTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _supabaseClient != null
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
                    return const Center(
                      child: Text(
                        'No digital payment receipts recorded yet.\nContact the school accounts desk for assistance.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981)),
                          ),
                          title: Text('₹${p['amount']} • ${p['payment_mode'] ?? 'Cash'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('Receipt: ${p['receipt_no'] ?? 'SSD'} • $date\n${p['remarks'] ?? 'School Fee'}', style: const TextStyle(fontSize: 11.5)),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'Download PDF Receipt',
                            icon: const Icon(Icons.download_rounded, color: Color(0xFF1E3A8A)),
                            onPressed: () => _downloadFeeReceiptPdf(p),
                          ),
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

  // ==================== 3. EXAM RESULTS & REPORT CARD MODAL ====================
  void _openResultsSheet() {
    final grade = (_student['marks_grade'] ?? 'A').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Examination Results & Report Card', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURRENT ACADEMIC STANDING', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Overall Grade: $grade', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('Class: ${_student['class_grade'] ?? 'Assigned'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFBBF24), size: 34),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F1E36),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Download Official Report Card (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadStudentReportPdf();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 4. CLASS TIME TABLE MODAL ====================
  void _openTimetableSheet() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    String selectedDay = days[(DateTime.now().weekday - 1).clamp(0, 5)];

    final scheduleMap = {
      'Mon': [
        {'time': '08:00 - 08:25 AM', 'sub': 'Morning Assembly & Prayer', 'room': 'Main Ground'},
        {'time': '08:25 - 09:10 AM', 'sub': 'Mathematics / Quantitative', 'room': 'Period 1'},
        {'time': '09:10 - 09:55 AM', 'sub': 'Science / Core Stream', 'room': 'Period 2'},
        {'time': '09:55 - 10:40 AM', 'sub': 'English Literature & Grammar', 'room': 'Period 3'},
        {'time': '10:40 - 11:05 AM', 'sub': 'Recess / Tiffin Break', 'room': 'Break'},
        {'time': '11:05 - 11:50 AM', 'sub': 'Social Studies / Humanities', 'room': 'Period 4'},
        {'time': '11:50 - 12:35 PM', 'sub': 'Hindi / Sanskrit', 'room': 'Period 5'},
        {'time': '12:35 - 01:30 PM', 'sub': 'Computer / Smart Lab', 'room': 'Period 6'},
      ],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final periods = scheduleMap[selectedDay] ?? scheduleMap['Mon']!;
          return Container(
            height: MediaQuery.of(context).size.height * 0.78,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Class Routine (${_student['class_grade'] ?? 'Daily'})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: days.map((d) {
                      final active = d == selectedDay;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(d),
                          selected: active,
                          selectedColor: const Color(0xFF1E3A8A),
                          labelStyle: TextStyle(
                            color: active ? Colors.white : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setSheetState(() => selectedDay = d),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: periods.length,
                    itemBuilder: (context, i) {
                      final p = periods[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF3B82F6).withOpacity(0.12),
                            child: Text('${i + 1}', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                          ),
                          title: Text(p['sub']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          subtitle: Text('${p['time']} • ${p['room']}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== 5. NOTICES, HOMEWORK & EVENTS SHEET ====================
  void _openNoticesOrEventsSheet({String initialFilter = 'ALL', String sheetTitle = 'Official School Circulars'}) {
    String selectedTag = initialFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.80,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sheetTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'URGENT', 'EXAMS', 'HOLIDAY', 'SPORTS', 'HOMEWORK', 'GENERAL'].map((tag) {
                    final active = selectedTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        selected: active,
                        selectedColor: const Color(0xFF1E3A8A),
                        labelStyle: TextStyle(
                          color: active ? Colors.white : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setSheetState(() => selectedTag = tag),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _supabaseClient != null
                      ? _supabaseClient!.from('school_notices').select().order('created_at', ascending: false)
                      : Future.value([]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var list = snapshot.data ?? [];
                    if (selectedTag != 'ALL') {
                      list = list.where((n) => (n['tag'] ?? 'GENERAL').toString().toUpperCase() == selectedTag).toList();
                    }
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'No circulars found under "$selectedTag".',
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final n = list[i];
                        final id = n['id'].toString();
                        final isHw = (n['tag'] ?? '').toString().toUpperCase() == 'HOMEWORK';
                        final isDone = _completedHomeworkIds.contains(id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
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
                                        (n['tag'] ?? 'NOTICE').toString(),
                                        style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      (n['date'] ?? 'Oct 2026').toString(),
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (n['title'] ?? '').toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                if ((n['content'] ?? '').toString().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    (n['content'] ?? '').toString(),
                                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                                  ),
                                ],
                                if (isHw) ...[
                                  const Divider(height: 16),
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        if (isDone) {
                                          _completedHomeworkIds.remove(id);
                                        } else {
                                          _completedHomeworkIds.add(id);
                                        }
                                      });
                                      setSheetState(() {});
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setStringList('done_hw_${_student['id']}', _completedHomeworkIds.toList());
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          isDone ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                          color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isDone ? 'Marked as Completed ✓' : 'Mark Homework as Completed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
      ),
    );
  }

  // ==================== 6. INTERACTIVE CONTACT DESK MODAL ====================
  void _showContactDeskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
              onTap: () => _launchExternal('tel:+917880884750'),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.chat_rounded,
              color: const Color(0xFF059669),
              title: 'Official WhatsApp Helpdesk',
              value: 'Chat directly with School Office',
              onTap: () => _launchExternal('https://wa.me/917880884750?text=Hello%20SSD%20Convent%20School'),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.location_on_rounded,
              color: const Color(0xFFDC2626),
              title: 'Campus Location (Tap for Maps)',
              value: 'Champapur, Handia Road, Janghai, Prayagraj',
              onTap: () => _launchExternal('https://maps.google.com/?q=SSD+Convent+School+Janghai+Prayagraj'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  // ==================== 7. TWO-WAY GRIEVANCE / COMPLAINT DESK ====================
  void _openComplaintModal(BuildContext context) {
    final complaintController = TextEditingController();
    String category = 'Academic';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Parent Grievance & Helpdesk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            setModalState(() => isSubmitting = false);
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
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Submit Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('YOUR RECENT SUBMISSIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _supabaseClient != null
                      ? _supabaseClient!
                          .from('school_complaints')
                          .select()
                          .eq('student_name', _student['student_name'] ?? '')
                          .order('created_at', ascending: false)
                          .limit(5)
                      : Future.value([]),
                  builder: (context, snapshot) {
                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No previous complaints filed.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      );
                    }
                    return Column(
                      children: list.map((c) {
                        final status = (c['status'] ?? 'Under Review').toString();
                        final isResolved = status == 'Resolved';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['category'] ?? 'Issue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(c['details'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (isResolved ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isResolved ? const Color(0xFF059669) : const Color(0xFFD97706),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parentName = _student['parent_name'] ?? _student['father_name'] ?? 'Parent';
    final studentName = _student['student_name'] ?? 'Student';
    final className = _student['class_grade'] ?? _student['class_name'] ?? 'Assigned';
    final att = _student['attendance_percentage'] ?? '92';
    final pendingFee = (_student['pending_fees'] ?? '0').toString();
    final grade = _student['marks_grade'] ?? 'A';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'S.S.D. Convent School',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF0F1E36),
                            ),
                          ),
                          const Text(
                            'Family Portal • Live Sync',
                            style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
                        size: 20,
                      ),
                      onPressed: toggleSSDTheme,
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 21),
                      tooltip: 'Log Out',
                      onPressed: _handleLogout,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshStudentFromCloud,
                  color: const Color(0xFF1E3A8A),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SIBLING SWITCHER (if parent has multiple children enrolled)
                        if (_siblings.length > 1) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _siblings.map((sib) {
                                final isCurrent = sib['id'] == _student['id'];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
                                  child: ChoiceChip(
                                    avatar: CircleAvatar(
                                      backgroundColor: isCurrent ? Colors.white : const Color(0xFF1E3A8A),
                                      child: Text(
                                        (sib['student_name'] ?? 'S').toString().substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent ? const Color(0xFF1E3A8A) : Colors.white,
                                        ),
                                      ),
                                    ),
                                    label: Text('${sib['student_name']} (${sib['class_grade'] ?? ''})'),
                                    selected: isCurrent,
                                    selectedColor: const Color(0xFF1E3A8A),
                                    labelStyle: TextStyle(
                                      color: isCurrent ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F1E36)),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    onSelected: (_) {
                                      setState(() => _student = sib);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        // ==================== HERO DIGITAL STUDENT ID CARD ====================
                        StaggeredEntrance(
                          index: 0,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F1E36), Color(0xFF1E3A8A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(color: Color(0x331E3A8A), blurRadius: 18, offset: Offset(0, 8)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: Colors.white.withOpacity(0.15),
                                      child: Text(
                                        studentName.toString().substring(0, 1).toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome, $parentName',
                                            style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            studentName.toString(),
                                            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
                                          ),
                                          Text(
                                            'Class: $className • Roll: ${_student['roll_number'] ?? 'Assigned'}',
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Download Student Dossier PDF',
                                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.12)),
                                      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                                      onPressed: _downloadStudentReportPdf,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildHeroStat('Attendance', '$att%', const Color(0xFF34D399), _openAttendanceSheet),
                                      Container(width: 1, height: 28, color: Colors.white24),
                                      _buildHeroStat(
                                        'Fee Status',
                                        pendingFee == '0' ? 'Cleared ✓' : '₹$pendingFee Due',
                                        pendingFee == '0' ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                                        _openFeesSheet,
                                      ),
                                      Container(width: 1, height: 28, color: Colors.white24),
                                      _buildHeroStat('Grade', 'Grade $grade', const Color(0xFF93C5FD), _openResultsSheet),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Motto Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A).withOpacity(isDark ? 0.3 : 1.0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.volunteer_activism_rounded, color: Color(0xFFD97706), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Together for a brighter future • Tap any service below',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text('QUICK SERVICES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.6)),
                        const SizedBox(height: 10),

                        // ==================== 3x3 INTERACTIVE SERVICES GRID ====================
                        StaggeredEntrance(
                          index: 1,
                          child: GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.98,
                            children: [
                              _buildGridCard(isDark, Icons.calendar_month_rounded, 'Attendance', const Color(0xFF10B981), _openAttendanceSheet),
                              _buildGridCard(isDark, Icons.account_balance_wallet_rounded, 'Fees', const Color(0xFF8B5CF6), _openFeesSheet),
                              _buildGridCard(isDark, Icons.insert_chart_rounded, 'Results', const Color(0xFFF59E0B), _openResultsSheet),
                              _buildGridCard(isDark, Icons.access_time_filled_rounded, 'Time Table', const Color(0xFF3B82F6), _openTimetableSheet),
                              _buildGridCard(
                                isDark,
                                Icons.campaign_rounded,
                                'Notices',
                                const Color(0xFFEC4899),
                                () => _openNoticesOrEventsSheet(initialFilter: 'ALL', sheetTitle: 'Official School Circulars'),
                              ),
                              _buildGridCard(isDark, Icons.report_problem_rounded, 'Complaint', const Color(0xFFDC2626), () => _openComplaintModal(context)),
                              _buildGridCard(isDark, Icons.contact_phone_rounded, 'Contact Desk', const Color(0xFF0284C7), () => _showContactDeskModal(context)),
                              _buildGridCard(
                                isDark,
                                Icons.menu_book_rounded,
                                'Homework',
                                const Color(0xFF06B6D4),
                                () => _openNoticesOrEventsSheet(initialFilter: 'HOMEWORK', sheetTitle: 'Daily Homework & Diary'),
                              ),
                              _buildGridCard(
                                isDark,
                                Icons.celebration_rounded,
                                'Events',
                                const Color(0xFF84CC16),
                                () => _openNoticesOrEventsSheet(initialFilter: 'HOLIDAY', sheetTitle: 'School Events & Holidays'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('LATEST CIRCULARS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.6)),
                            GestureDetector(
                              onTap: () => _openNoticesOrEventsSheet(initialFilter: 'ALL', sheetTitle: 'Official School Circulars'),
                              child: const Text('View All →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
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
                                  .limit(4)
                              : Future.value([]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Column(
                                children: [
                                  ShimmerPlaceholder(height: 60),
                                  SizedBox(height: 8),
                                  ShimmerPlaceholder(height: 60),
                                ],
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text('No circulars posted yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              );
                            }
                            return Column(
                              children: snapshot.data!.map((n) {
                                return InkWell(
                                  onTap: () => _openNoticesOrEventsSheet(initialFilter: 'ALL', sheetTitle: 'Official School Circulars'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                n['title'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: isDark ? Colors.white : const Color(0xFF0F1E36),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if ((n['content'] ?? '').toString().isNotEmpty)
                                                Text(
                                                  n['content'].toString(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
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

  Widget _buildHeroStat(String label, String val, Color valColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(val, style: TextStyle(color: valColor, fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _buildGridCard(bool isDark, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
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
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F1E36),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
