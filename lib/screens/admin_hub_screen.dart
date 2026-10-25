import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class AdminHubScreen extends StatefulWidget {
  const AdminHubScreen({super.key});

  @override
  State<AdminHubScreen> createState() => _AdminHubScreenState();
}

class _AdminHubScreenState extends State<AdminHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & Filter state
  final TextEditingController _studentSearchCtrl = TextEditingController();
  final TextEditingController _feeSearchCtrl = TextEditingController();
  String _selectedClassFilter = 'ALL';
  String _attendanceClassFilter = 'ALL';
  String _feeClassFilter = 'ALL';
  String _studentQuery = '';
  String _feeQuery = '';

  // Comprehensive Class Hierarchy List
  static const List<String> schoolClasses = [
    'ALL',
    'Not Assigned',
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

  // Student Form Controllers
  final _studentNameCtrl = TextEditingController();
  final _rollNoCtrl = TextEditingController();
  final _admNoCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _birthYearCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _feeDueCtrl = TextEditingController();
  final _attCtrl = TextEditingController();
  final _marksCtrl = TextEditingController();
  String _formClass = 'Class 10';
  bool _isSavingStudent = false;

  // Notice Form Controllers
  final _noticeTitleCtrl = TextEditingController();
  final _noticeContentCtrl = TextEditingController();
  String _noticeTag = 'GENERAL';
  bool _isPublishingNotice = false;

  // Faculty Form Controllers
  final _facultyNameCtrl = TextEditingController();
  final _facultyDesigCtrl = TextEditingController();
  final _facultySubCtrl = TextEditingController();
  final _facultyQualCtrl = TextEditingController();

  // Gallery Upload State
  String _uploadGalleryCategory = 'Hero Slideshow';
  final _galleryTitleCtrl = TextEditingController();
  final _galleryQuoteCtrl = TextEditingController();
  bool _isUploadingGallery = false;

  // Exam Manager State
  String _manageExamClass = 'Class 10';
  final _examQuestionCtrl = TextEditingController();
  final _optACtrl = TextEditingController();
  final _optBCtrl = TextEditingController();
  final _optCCtrl = TextEditingController();
  final _optDCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  int _correctOptIndex = 0;
  bool _isSavingExam = false;

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
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentSearchCtrl.dispose();
    _feeSearchCtrl.dispose();
    _studentNameCtrl.dispose();
    _rollNoCtrl.dispose();
    _admNoCtrl.dispose();
    _parentNameCtrl.dispose();
    _motherNameCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _birthYearCtrl.dispose();
    _addressCtrl.dispose();
    _feeDueCtrl.dispose();
    _attCtrl.dispose();
    _marksCtrl.dispose();
    _noticeTitleCtrl.dispose();
    _noticeContentCtrl.dispose();
    _facultyNameCtrl.dispose();
    _facultyDesigCtrl.dispose();
    _facultySubCtrl.dispose();
    _facultyQualCtrl.dispose();
    _galleryTitleCtrl.dispose();
    _galleryQuoteCtrl.dispose();
    _examQuestionCtrl.dispose();
    _optACtrl.dispose();
    _optBCtrl.dispose();
    _optCCtrl.dispose();
    _optDCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  bool _matchesClass(String studentClass, String filter) {
    if (filter == 'ALL') return true;
    final scClean = studentClass.trim().toLowerCase();
    final fClean = filter.trim().toLowerCase();
    if (filter == 'Not Assigned') {
      return scClean.isEmpty || scClean.contains('not assigned') || scClean == 'null';
    }
    final normStudent = scClean.replaceAll('class', '').replaceAll('-', '').replaceAll(' ', '');
    final normFilter = fClean.replaceAll('class', '').replaceAll('-', '').replaceAll(' ', '');
    return normStudent == normFilter || scClean.contains(fClean) || fClean.contains(scClean);
  }

  // ==================== IMAGE UPLOADER FOR GALLERY ====================
  Future<void> _pickAndUploadGalleryImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() => _isUploadingGallery = true);
        final bytes = result.files.single.bytes!;
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        final client = _supabaseClient;
        if (client != null) {
          await client.from('school_gallery').insert({
            'category': _uploadGalleryCategory,
            'title': _galleryTitleCtrl.text.trim().isNotEmpty
                ? _galleryTitleCtrl.text.trim()
                : _uploadGalleryCategory,
            'quote': _galleryQuoteCtrl.text.trim(),
            'image_data': base64Image,
          });

          _galleryTitleCtrl.clear();
          _galleryQuoteCtrl.clear();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Photo successfully added to ' '$_uploadGalleryCategory!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        }
        setState(() => _isUploadingGallery = false);
      }
    } catch (e) {
      setState(() => _isUploadingGallery = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==================== PDF QUESTION PAPER UPLOADER ====================
  Future<void> _pickAndUploadExamPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final base64Pdf = base64Encode(bytes);
        final fileName = result.files.single.name;

        final client = _supabaseClient;
        if (client != null) {
          await client.from('school_exams').insert({
            'class_name': _manageExamClass,
            'exam_type': 'pdf',
            'title': fileName,
            'pdf_name': fileName,
            'pdf_base64': base64Pdf,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF Question Paper uploaded for $_manageExamClass!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
            setState(() {});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF upload error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==================== SAVE MCQ QUESTION ====================
  Future<void> _saveMcqQuestion() async {
    final qText = _examQuestionCtrl.text.trim();
    final aText = _optACtrl.text.trim();
    final bText = _optBCtrl.text.trim();

    if (qText.isEmpty || aText.isEmpty || bText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out the question and at least options A and B')),
      );
      return;
    }

    setState(() => _isSavingExam = true);
    try {
      final client = _supabaseClient;
      if (client != null) {
        await client.from('school_exams').insert({
          'class_name': _manageExamClass,
          'exam_type': 'mcq',
          'title': qText,
          'question': qText,
          'option_a': aText,
          'option_b': bText,
          'option_c': _optCCtrl.text.trim(),
          'option_d': _optDCtrl.text.trim(),
          'correct_index': _correctOptIndex,
          'explanation': _expCtrl.text.trim(),
        });

        _examQuestionCtrl.clear();
        _optACtrl.clear();
        _optBCtrl.clear();
        _optCCtrl.clear();
        _optDCtrl.clear();
        _expCtrl.clear();
        _correctOptIndex = 0;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MCQ Question added successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving question: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSavingExam = false);
    }
  }

  // --- PRINT FEE RECEIPT PDF (ADMIN) ---
  Future<void> _printFeeReceiptPdf(Map<String, dynamic> student, Map<String, dynamic> payment) async {
    final pdf = pw.Document();
    final name = (student['student_name'] ?? 'Student').toString();
    final grade = (student['class_grade'] ?? 'N/A').toString();
    final rcpt = (payment['receipt_no'] ?? 'SSD-REC').toString();
    final amount = (payment['amount'] ?? '0').toString();
    final mode = (payment['payment_mode'] ?? 'Cash').toString();
    final date = payment['payment_date'] != null
        ? payment['payment_date'].toString().substring(0, 10)
        : DateTime.now().toString().substring(0, 10);

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
                  pw.Text('S.S.D. CONVENT SCHOOL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text('RECEIPT: $rcpt', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Text('Champapur, Handia Road, Janghai, Prayagraj', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(children: [
                    _pdfCell('Student Name', isHeader: true),
                    _pdfCell(name),
                    _pdfCell('Class & Section', isHeader: true),
                    _pdfCell(grade),
                  ]),
                  pw.TableRow(children: [
                    _pdfCell('Amount Received', isHeader: true),
                    _pdfCell('INR $amount /-'),
                    _pdfCell('Payment Mode / Date', isHeader: true),
                    _pdfCell('$mode ($date)'),
                  ]),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Official Admin Copy', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Text('Cashier / Principal Sign', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SSD_Receipt_$rcpt.pdf',
    );
  }

  // --- PDF GENERATION & DOCUMENT VIEWER ---
  Future<void> _openStudentPdf(Map<String, dynamic> student) async {
    final pdf = pw.Document();

    final name = (student['student_name'] ?? 'Student Name').toString();
    final grade = (student['class_grade'] ?? 'Not Assigned').toString();
    final roll = (student['roll_number'] ?? student['roll_no'] ?? 'N/A').toString();
    final adm = (student['admission_number'] ?? student['scholar_no'] ?? 'SSD-${student['id'].toString().substring(0, 5)}').toString();
    final father = (student['parent_name'] ?? student['father_name'] ?? 'N/A').toString();
    final mother = (student['mother_name'] ?? 'N/A').toString();
    final phone = (student['parent_phone'] ?? student['mobile_number'] ?? 'N/A').toString();
    final dob = (student['birth_year'] ?? student['student_dob'] ?? 'N/A').toString();
    final address = (student['address'] ?? 'Prayagraj, Uttar Pradesh').toString();
    final feeDue = (student['pending_fees'] ?? '0').toString();
    final att = (student['attendance_percentage'] ?? '92').toString();
    final gradeChar = (student['marks_grade'] ?? 'A').toString();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
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
                      pw.Text(
                        'Affiliated & Recognized Senior Secondary Institution',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Champapur, Handia Road, Janghai, Prayagraj, UP',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue900,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'OFFICIAL STUDENT RECORD DOSSIER',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  children: [
                    pw.TableRow(children: [
                      _pdfCell('Student Full Name', isHeader: true),
                      _pdfCell(name),
                      _pdfCell('Scholar / Adm No', isHeader: true),
                      _pdfCell(adm),
                    ]),
                    pw.TableRow(children: [
                      _pdfCell('Class & Section', isHeader: true),
                      _pdfCell(grade),
                      _pdfCell('Roll Number', isHeader: true),
                      _pdfCell(roll),
                    ]),
                    pw.TableRow(children: [
                      _pdfCell("Father's Name", isHeader: true),
                      _pdfCell(father),
                      _pdfCell("Mother's Name", isHeader: true),
                      _pdfCell(mother),
                    ]),
                    pw.TableRow(children: [
                      _pdfCell('Contact Number', isHeader: true),
                      _pdfCell('+91 $phone'),
                      _pdfCell('Date of Birth / Key', isHeader: true),
                      _pdfCell(dob),
                    ]),
                    pw.TableRow(children: [
                      _pdfCell('Residential Address', isHeader: true),
                      _pdfCell(address),
                      _pdfCell('Campus', isHeader: true),
                      _pdfCell('Janghai, Prayagraj'),
                    ]),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('ACADEMIC & FINANCIAL STATUS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  children: [
                    pw.TableRow(children: [
                      _pdfCell('Attendance Percentage', isHeader: true),
                      _pdfCell('$att%'),
                      _pdfCell('Report Grade', isHeader: true),
                      _pdfCell(gradeChar),
                    ]),
                    pw.TableRow(children: [
                      _pdfCell('Fee Standing Status', isHeader: true),
                      _pdfCell(feeDue == '0' || feeDue == '0.00' ? 'ALL DUES CLEARED (NIL)' : 'PENDING: INR $feeDue'),
                      _pdfCell('System Verified', isHeader: true),
                      _pdfCell('YES - Supabase Cloud'),
                    ]),
                  ],
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(width: 140, height: 1, color: PdfColors.grey800),
                        pw.SizedBox(height: 4),
                        pw.Text('Class Teacher Signature', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(width: 140, height: 1, color: PdfColors.grey800),
                        pw.SizedBox(height: 4),
                        pw.Text('Principal / Admin Seal', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('Generated securely via S.S.D. Convent School Mobile Administration Portal', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (!mounted) return;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'SSD_${name.replaceAll(' ', '_')}_Record.pdf',
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

  // --- MODAL: ADD / EDIT STUDENT PROFILE ---
  void _openStudentModal({Map<String, dynamic>? student}) {
    final isEdit = student != null;
    if (isEdit) {
      _studentNameCtrl.text = student['student_name'] ?? '';
      _rollNoCtrl.text = (student['roll_number'] ?? student['roll_no'] ?? '').toString();
      _admNoCtrl.text = (student['admission_number'] ?? student['scholar_no'] ?? '').toString();
      _formClass = schoolClasses.contains(student['class_grade'])
          ? student['class_grade']
          : 'Class 10';
      _parentNameCtrl.text = student['parent_name'] ?? student['father_name'] ?? '';
      _motherNameCtrl.text = student['mother_name'] ?? '';
      _parentPhoneCtrl.text = student['parent_phone'] ?? student['mobile_number'] ?? '';
      _altPhoneCtrl.text = student['alternate_phone'] ?? '';
      _birthYearCtrl.text = student['birth_year'] ?? student['student_dob'] ?? '';
      _addressCtrl.text = student['address'] ?? '';
      _feeDueCtrl.text = (student['pending_fees'] ?? '0').toString();
      _attCtrl.text = (student['attendance_percentage'] ?? '92').toString();
      _marksCtrl.text = (student['marks_grade'] ?? 'A').toString();
    } else {
      _studentNameCtrl.clear();
      _rollNoCtrl.clear();
      _admNoCtrl.clear();
      _parentNameCtrl.clear();
      _motherNameCtrl.clear();
      _parentPhoneCtrl.clear();
      _altPhoneCtrl.clear();
      _birthYearCtrl.clear();
      _addressCtrl.clear();
      _feeDueCtrl.text = '0';
      _attCtrl.text = '92';
      _marksCtrl.text = 'A';
      _formClass = 'Class 10';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.90,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Student Details' : 'New Student Admission',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACADEMIC INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _studentNameCtrl,
                        decoration: const InputDecoration(labelText: 'Student Full Name *', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _formClass,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Class & Section *', border: OutlineInputBorder()),
                              items: schoolClasses
                                  .where((c) => c != 'ALL')
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12.5))))
                                  .toList(),
                              onChanged: (v) => setModalState(() => _formClass = v!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _rollNoCtrl,
                              decoration: const InputDecoration(labelText: 'Roll No', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _admNoCtrl,
                        decoration: const InputDecoration(labelText: 'Admission / Scholar No', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      const Text('PARENTS & LOGIN CREDENTIALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _parentNameCtrl,
                              decoration: const InputDecoration(labelText: "Father's Name", border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _motherNameCtrl,
                              decoration: const InputDecoration(labelText: "Mother's Name", border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _parentPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Parent Phone (Login ID) *',
                          prefixText: '+91 ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _birthYearCtrl,
                              decoration: const InputDecoration(
                                labelText: 'DOB / Birth Year (Key) *',
                                hintText: '2012 or 2012-05-14',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _altPhoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Alt Phone', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(labelText: 'Village / Town / Address', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      const Text('FEES & ACADEMIC STANDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _feeDueCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Pending Dues (₹)', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _attCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Attendance (%)', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _marksCtrl,
                              decoration: const InputDecoration(labelText: 'Grade', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSavingStudent
                      ? null
                      : () async {
                          final name = _studentNameCtrl.text.trim();
                          final phone = _parentPhoneCtrl.text.trim();
                          final bYear = _birthYearCtrl.text.trim();

                          if (name.isEmpty || phone.isEmpty || bYear.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Student Name, Phone, and Birth Year are mandatory')),
                            );
                            return;
                          }

                          setModalState(() => _isSavingStudent = true);
                          final client = _supabaseClient;
                          if (client != null) {
                            final data = {
                              'student_name': name,
                              'roll_number': _rollNoCtrl.text.trim(),
                              'admission_number': _admNoCtrl.text.trim(),
                              'class_grade': _formClass,
                              'parent_name': _parentNameCtrl.text.trim().isNotEmpty ? _parentNameCtrl.text.trim() : 'Parent',
                              'father_name': _parentNameCtrl.text.trim().isNotEmpty ? _parentNameCtrl.text.trim() : 'Parent',
                              'mother_name': _motherNameCtrl.text.trim(),
                              'parent_phone': phone,
                              'mobile_number': phone,
                              'alternate_phone': _altPhoneCtrl.text.trim(),
                              'birth_year': bYear,
                              'student_dob': bYear,
                              'address': _addressCtrl.text.trim(),
                              'pending_fees': _feeDueCtrl.text.trim(),
                              'attendance_percentage': _attCtrl.text.trim(),
                              'marks_grade': _marksCtrl.text.trim(),
                            };

                            try {
                              if (isEdit) {
                                await client.from('students').update(data).eq('id', student['id']);
                              } else {
                                await client.from('students').insert(data);
                              }
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              setState(() {});
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save error: $e')));
                            }
                          }
                          setModalState(() => _isSavingStudent = false);
                        },
                  child: _isSavingStudent
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEdit ? 'Save Changes' : 'Save & Register Student', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODAL: ADVANCED FEE LEDGER & RECEIPT ---
  void _openFeeLedgerModal(Map<String, dynamic> student) {
    final payAmountCtrl = TextEditingController(text: (student['pending_fees'] ?? '0').toString());
    final editDueCtrl = TextEditingController(text: (student['pending_fees'] ?? '0').toString());
    final remarksCtrl = TextEditingController();
    String payMode = 'Cash';
    String payTerm = 'Term 1 / Monthly Fee';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setFeeState) => Container(
          height: MediaQuery.of(context).size.height * 0.88,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student['student_name'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        'Class: ${student['class_grade'] ?? 'N/A'} • Due: ₹${student['pending_fees'] ?? 0}',
                        style: TextStyle(
                          color: (student['pending_fees'] ?? '0') == '0' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('RECORD NEW PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E3A8A))),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: payAmountCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Amount Paid (₹)', border: OutlineInputBorder()),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: payMode,
                                    decoration: const InputDecoration(labelText: 'Mode', border: OutlineInputBorder()),
                                    items: ['Cash', 'UPI / PhonePe', 'Bank Transfer', 'Cheque']
                                        .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12))))
                                        .toList(),
                                    onChanged: (v) => setFeeState(() => payMode = v!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: remarksCtrl,
                              decoration: const InputDecoration(labelText: 'Receipt Remarks / Note', hintText: 'e.g. October Fee Cleared', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                                label: const Text('Record Payment & Update Due', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  final amount = double.tryParse(payAmountCtrl.text.trim()) ?? 0;
                                  if (amount <= 0) return;

                                  final client = _supabaseClient;
                                  if (client != null) {
                                    final currentDue = double.tryParse((student['pending_fees'] ?? '0').toString()) ?? 0;
                                    final newDue = math.max(0.0, currentDue - amount).toInt().toString();
                                    final receiptNo = 'SSD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                                    try {
                                      await client.from('fee_payments').insert({
                                        'student_id': student['id'],
                                        'student_name': student['student_name'],
                                        'receipt_no': receiptNo,
                                        'amount': amount,
                                        'payment_mode': payMode,
                                        'term': payTerm,
                                        'remarks': remarksCtrl.text.trim(),
                                      });
                                    } catch (_) {}

                                    await client.from('students').update({'pending_fees': newDue}).eq('id', student['id']);

                                    if (!mounted) return;
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Payment recorded! Receipt: $receiptNo'), backgroundColor: Colors.green),
                                    );
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: editDueCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Set Outstanding Due (₹)', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                              onPressed: () async {
                                final client = _supabaseClient;
                                if (client != null) {
                                  await client.from('students').update({'pending_fees': editDueCtrl.text.trim()}).eq('id', student['id']);
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  setState(() {});
                                }
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('PAYMENT AUDIT TRAIL (TAP PRINT ICON FOR PDF RECEIPT)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _supabaseClient != null
                            ? _supabaseClient!
                                .from('fee_payments')
                                .select()
                                .eq('student_id', student['id'])
                                .order('payment_date', ascending: false)
                            : Future.value([]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('No recorded payment receipts yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            );
                          }
                          return Column(
                            children: snapshot.data!.map((p) {
                              final date = p['payment_date'] != null ? p['payment_date'].toString().substring(0, 10) : 'Recent';
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('₹${p['amount']} (${p['payment_mode'] ?? 'Cash'})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981))),
                                        Text('Rcpt: ${p['receipt_no'] ?? 'SSD-REC'} • $date', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                    IconButton(
                                      tooltip: 'Print Receipt PDF',
                                      icon: const Icon(Icons.print_rounded, color: Color(0xFF1E3A8A), size: 20),
                                      onPressed: () => _printFeeReceiptPdf(student, p),
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
            ],
          ),
        ),
      ),
    );
  }

  void _handleBackNavigation(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _showLogoutDialog(context);
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Admin Panel?'),
        content: const Text('Do you want to log out and return to the login screen?'),
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

    if (shouldLogout == true && mounted) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_user_type');
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        createSmoothRoute(const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _openFacultyModal() {
    _facultyNameCtrl.clear();
    _facultyDesigCtrl.clear();
    _facultySubCtrl.clear();
    _facultyQualCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Teacher / Faculty Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _facultyNameCtrl, decoration: const InputDecoration(labelText: 'Teacher Name *')),
            TextField(controller: _facultyDesigCtrl, decoration: const InputDecoration(labelText: 'Designation (e.g. Senior TGT)')),
            TextField(controller: _facultySubCtrl, decoration: const InputDecoration(labelText: 'Primary Subject (e.g. Mathematics)')),
            TextField(controller: _facultyQualCtrl, decoration: const InputDecoration(labelText: 'Qualification (e.g. M.Sc, B.Ed)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
            onPressed: () async {
              if (_facultyNameCtrl.text.isEmpty) return;
              final client = _supabaseClient;
              if (client != null) {
                try {
                  await client.from('school_faculty').insert({
                    'name': _facultyNameCtrl.text.trim(),
                    'designation': _facultyDesigCtrl.text.trim().isNotEmpty ? _facultyDesigCtrl.text.trim() : 'Teacher',
                    'subject': _facultySubCtrl.text.trim(),
                    'qualification': _facultyQualCtrl.text.trim(),
                  });
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Add Faculty'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBackNavigation(context);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            tooltip: 'Back',
            onPressed: () => _handleBackNavigation(context),
          ),
          title: const Text('Admin Management Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0F1E36),
          foregroundColor: Colors.white,
          elevation: 1,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? const Color(0xFFFBBF24) : Colors.white70,
                size: 20,
              ),
              onPressed: toggleSSDTheme,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'Sync Data',
              onPressed: () => setState(() {}),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              tooltip: 'Log Out',
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const Color(0xFFD97706),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF94A3B8),
            tabs: const [
              Tab(icon: Icon(Icons.school_rounded, size: 19), text: 'Students'),
              Tab(icon: Icon(Icons.account_balance_wallet_rounded, size: 19), text: 'Fees'),
              Tab(icon: Icon(Icons.calendar_month_rounded, size: 19), text: 'Attendance'),
              Tab(icon: Icon(Icons.badge_rounded, size: 19), text: 'Faculty'),
              Tab(icon: Icon(Icons.photo_library_rounded, size: 19), text: 'Gallery'),
              Tab(icon: Icon(Icons.campaign_rounded, size: 19), text: 'Circulars'),
              Tab(icon: Icon(Icons.report_problem_rounded, size: 19), text: 'Complaints'),
              Tab(icon: Icon(Icons.quiz_rounded, size: 19), text: 'Exams & Q-Papers'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // ==================== TAB 1: STUDENTS ====================
            Scaffold(
              backgroundColor: bgColor,
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add Student'),
                onPressed: () => _openStudentModal(),
              ),
              body: Column(
                children: [
                  Container(
                    color: cardBg,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _studentSearchCtrl,
                              onChanged: (v) => setState(() => _studentQuery = v.trim().toLowerCase()),
                              decoration: InputDecoration(
                                hintText: 'Search student name, roll, or phone...',
                                hintStyle: const TextStyle(fontSize: 12),
                                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedClassFilter,
                              items: schoolClasses
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold))))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedClassFilter = v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _supabaseClient != null
                          ? _supabaseClient!.from('students').select().order('student_name')
                          : Future.value([]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final allStudents = snapshot.data!;
                        var list = allStudents;

                        final totalEnrolled = allStudents.length;
                        final clearedFeesCount = allStudents.where((s) => (s['pending_fees'] ?? '0').toString() == '0').length;

                        if (_studentQuery.isNotEmpty) {
                          list = list.where((s) {
                            final name = (s['student_name'] ?? '').toString().toLowerCase();
                            final phone = (s['parent_phone'] ?? s['mobile_number'] ?? '').toString().toLowerCase();
                            final roll = (s['roll_number'] ?? '').toString().toLowerCase();
                            return name.contains(_studentQuery) || phone.contains(_studentQuery) || roll.contains(_studentQuery);
                          }).toList();
                        }

                        if (_selectedClassFilter != 'ALL') {
                          list = list.where((s) {
                            final grade = (s['class_grade'] ?? '').toString();
                            return _matchesClass(grade, _selectedClassFilter);
                          }).toList();
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                              child: Row(
                                children: [
                                  _buildKpiMiniCard('Total Students', '$totalEnrolled', const Color(0xFF1E3A8A)),
                                  const SizedBox(width: 8),
                                  _buildKpiMiniCard('Fees Cleared', '$clearedFeesCount', const Color(0xFF10B981)),
                                  const SizedBox(width: 8),
                                  _buildKpiMiniCard('Filtered View', '${list.length}', const Color(0xFFD97706)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: list.isEmpty
                                  ? const Center(child: Text('No matching students found in this category.'))
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 85),
                                      itemCount: list.length,
                                      itemBuilder: (context, i) {
                                        final s = list[i];
                                        final phone = s['parent_phone'] ?? s['mobile_number'] ?? 'N/A';
                                        final bYear = s['birth_year'] ?? s['student_dob'] ?? 'N/A';
                                        final grade = s['class_grade'] ?? 'Not Assigned';
                                        final fees = s['pending_fees'] ?? '0';

                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: cardBg,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                          ),
                                          child: Column(
                                            children: [
                                              InkWell(
                                                onTap: () => _openStudentPdf(s),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                                                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF1E3A8A)),
                                                  ),
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(s['student_name'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                                                        child: const Text('PDF Report', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 10, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Text('Class: $grade • Phone: $phone\nKey/DOB: $bYear', style: const TextStyle(fontSize: 11.5, height: 1.35)),
                                                  isThreeLine: true,
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit_rounded, color: Color(0xFF1E3A8A), size: 20),
                                                        onPressed: () => _openStudentModal(student: s),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                                        onPressed: () async {
                                                          final conf = await showDialog<bool>(
                                                            context: context,
                                                            builder: (_) => AlertDialog(
                                                              title: const Text('Delete Student?'),
                                                              content: Text('Remove ${s['student_name']} permanently?'),
                                                              actions: [
                                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                                              ],
                                                            ),
                                                          );
                                                          if (conf == true && _supabaseClient != null) {
                                                            await _supabaseClient!.from('students').delete().eq('id', s['id']);
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Divider(height: 1),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    _buildPill(
                                                      label: fees == '0' || fees == 0 ? 'Fee: Clear ✓' : 'Due: ₹$fees',
                                                      color: fees == '0' || fees == 0 ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                                                      onTap: () => _openFeeLedgerModal(s),
                                                    ),
                                                    _buildPill(
                                                      label: 'Att: ${s['attendance_percentage'] ?? 92}%',
                                                      color: const Color(0xFF3B82F6),
                                                      onTap: () => _openStudentModal(student: s),
                                                    ),
                                                    _buildPill(
                                                      label: 'Grade: ${s['marks_grade'] ?? 'A'}',
                                                      color: const Color(0xFF8B5CF6),
                                                      onTap: () => _openStudentModal(student: s),
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ==================== TAB 2: FEES ====================
            Column(
              children: [
                Container(
                  color: cardBg,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _feeSearchCtrl,
                            onChanged: (v) => setState(() => _feeQuery = v.trim().toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Search fee by name, roll, phone...',
                              hintStyle: const TextStyle(fontSize: 12),
                              prefixIcon: const Icon(Icons.search_rounded, size: 18),
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _feeClassFilter,
                            dropdownColor: cardBg,
                            items: schoolClasses
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold))))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _feeClassFilter = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _supabaseClient != null
                        ? _supabaseClient!.from('students').select().order('student_name')
                        : Future.value([]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      var list = snapshot.data!;

                      if (_feeQuery.isNotEmpty) {
                        list = list.where((s) {
                          final name = (s['student_name'] ?? '').toString().toLowerCase();
                          final phone = (s['parent_phone'] ?? s['mobile_number'] ?? '').toString().toLowerCase();
                          final roll = (s['roll_number'] ?? s['roll_no'] ?? '').toString().toLowerCase();
                          return name.contains(_feeQuery) || phone.contains(_feeQuery) || roll.contains(_feeQuery);
                        }).toList();
                      }

                      if (_feeClassFilter != 'ALL') {
                        list = list.where((s) {
                          final grade = (s['class_grade'] ?? '').toString();
                          return _matchesClass(grade, _feeClassFilter);
                        }).toList();
                      }

                      if (list.isEmpty) {
                        return const Center(
                          child: Text('No matching fee records found.', style: TextStyle(color: Color(0xFF64748B))),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final s = list[i];
                          final pending = (s['pending_fees'] ?? '0').toString();
                          final isClear = pending == '0' || pending == '0.00' || pending.isEmpty;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(s['student_name'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(
                                'Class: ${s['class_grade'] ?? 'Not Assigned'}\n${isClear ? 'All Dues Paid ✓' : 'Pending: ₹$pending'}',
                                style: TextStyle(color: isClear ? const Color(0xFF10B981) : const Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 11.5),
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isClear ? const Color(0xFFF1F5F9) : const Color(0xFF10B981),
                                  foregroundColor: isClear ? const Color(0xFF0F1E36) : Colors.white,
                                ),
                                onPressed: () => _openFeeLedgerModal(s),
                                child: Text(isClear ? 'Edit Due' : 'Collect Fee'),
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

            // ==================== TAB 3: ATTENDANCE ====================
            Column(
              children: [
                Container(
                  color: cardBg,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Class Attendance:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _attendanceClassFilter,
                          items: schoolClasses
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _attendanceClassFilter = v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _supabaseClient != null
                        ? _supabaseClient!.from('students').select().order('class_grade')
                        : Future.value([]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      var list = snapshot.data!;
                      if (_attendanceClassFilter != 'ALL') {
                        list = list.where((s) => _matchesClass((s['class_grade'] ?? '').toString(), _attendanceClassFilter)).toList();
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final s = list[i];
                          final att = s['attendance_percentage'] ?? '92';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(s['student_name'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Class: ${s['class_grade'] ?? 'N/A'} • Att: $att%'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    onPressed: () async {
                                      final updated = math.min(100, (int.tryParse(att.toString()) ?? 90) + 1).toString();
                                      if (_supabaseClient != null) {
                                        await _supabaseClient!.from('students').update({'attendance_percentage': updated}).eq('id', s['id']);
                                        setState(() {});
                                      }
                                    },
                                    child: const Text('Present'),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    onPressed: () async {
                                      final updated = math.max(0, (int.tryParse(att.toString()) ?? 90) - 1).toString();
                                      if (_supabaseClient != null) {
                                        await _supabaseClient!.from('students').update({'attendance_percentage': updated}).eq('id', s['id']);
                                        setState(() {});
                                      }
                                    },
                                    child: const Text('Absent'),
                                  ),
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

            // ==================== TAB 4: FACULTY ====================
            Scaffold(
              backgroundColor: bgColor,
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Add Faculty'),
                onPressed: _openFacultyModal,
              ),
              body: FutureBuilder<List<Map<String, dynamic>>>(
                future: _supabaseClient != null
                    ? _supabaseClient!.from('school_faculty').select().order('name')
                    : Future.value([]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No teachers added yet. Tap "+ Add Faculty" to start.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 80),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      final f = snapshot.data![i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                            child: const Icon(Icons.badge_rounded, color: Color(0xFF3B82F6)),
                          ),
                          title: Text(f['name'] ?? 'Faculty Member', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${f['designation'] ?? 'Teacher'} • Sub: ${f['subject'] ?? 'All'} (${f['qualification'] ?? ''})'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () async {
                              if (_supabaseClient != null) {
                                await _supabaseClient!.from('school_faculty').delete().eq('id', f['id']);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ==================== TAB 5: GALLERY & HERO SLIDESHOW MANAGER ====================
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UPLOAD CAMPUS & SLIDESHOW PHOTOS',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _uploadGalleryCategory,
                          decoration: const InputDecoration(labelText: 'Target Album / Category', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Hero Slideshow', child: Text('Hero Slideshow (Homepage Slider)')),
                            DropdownMenuItem(value: 'Campus Life', child: Text('Campus Life Gallery')),
                            DropdownMenuItem(value: 'Athletics', child: Text('Athletics Gallery')),
                            DropdownMenuItem(value: 'Daily Life', child: Text('Daily Life Gallery')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _uploadGalleryCategory = v);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _galleryTitleCtrl,
                          decoration: const InputDecoration(labelText: 'Photo Title / Caption', hintText: 'e.g. Smart Science Lab Demonstration', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _galleryQuoteCtrl,
                          decoration: const InputDecoration(labelText: 'Subtitle / Quote (Optional for Hero Slideshow)', hintText: 'e.g. Where curiosity meets excellence.', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: _isUploadingGallery
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.add_photo_alternate_rounded),
                            label: Text(_isUploadingGallery ? 'Uploading Photo...' : 'Select & Upload Photo from Device'),
                            onPressed: _isUploadingGallery ? null : _pickAndUploadGalleryImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('ACTIVE UPLOADED MEDIA & SLIDES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _supabaseClient != null
                        ? _supabaseClient!.from('school_gallery').select().order('created_at', ascending: false)
                        : Future.value([]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final galleryList = snapshot.data!;
                      if (galleryList.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No photos uploaded yet. Use the form above to add photos.', style: TextStyle(color: Color(0xFF64748B))),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: galleryList.length,
                        itemBuilder: (context, i) {
                          final item = galleryList[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.network(
                                    item['image_data']?.toString() ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              title: Text(item['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              subtitle: Text('Album: ${item['category']}\nQuote: ${item['quote'] ?? 'None'}', maxLines: 2, style: const TextStyle(fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                onPressed: () async {
                                  if (_supabaseClient != null) {
                                    await _supabaseClient!.from('school_gallery').delete().eq('id', item['id']);
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // ==================== TAB 6: CIRCULARS & HOMEWORK ====================
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PUBLISH NOTICE / HOMEWORK / EVENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A))),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _noticeTag,
                          items: ['GENERAL', 'EXAMS', 'HOLIDAY', 'SPORTS', 'URGENT', 'HOMEWORK']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (v) => setState(() => _noticeTag = v!),
                          decoration: const InputDecoration(labelText: 'Tag Category (Select HOMEWORK for Daily Diary)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        TextField(controller: _noticeTitleCtrl, decoration: const InputDecoration(labelText: 'Notice / Homework Title', border: OutlineInputBorder())),
                        const SizedBox(height: 10),
                        TextField(controller: _noticeContentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Full Details / Class Assignment', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                            onPressed: _isPublishingNotice
                                ? null
                                : () async {
                                    if (_noticeTitleCtrl.text.isEmpty) return;
                                    final client = _supabaseClient;
                                    if (client == null) return;
                                    setState(() => _isPublishingNotice = true);
                                    try {
                                      await client.from('school_notices').insert({
                                        'tag': _noticeTag,
                                        'title': _noticeTitleCtrl.text.trim(),
                                        'date': 'Oct 2026',
                                        'content': _noticeContentCtrl.text.trim(),
                                      });
                                      _noticeTitleCtrl.clear();
                                      _noticeContentCtrl.clear();
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcasted to App and Website!')));
                                      setState(() {});
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    } finally {
                                      setState(() => _isPublishingNotice = false);
                                    }
                                  },
                            child: _isPublishingNotice
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Publish Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('RECENT BROADCASTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _supabaseClient != null
                        ? _supabaseClient!.from('school_notices').select().order('created_at', ascending: false)
                        : Future.value([]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('No notices published.');
                      return Column(
                        children: snapshot.data!.map((n) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                                child: Text(n['tag'] ?? 'NOTICE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(n['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                onPressed: () async {
                                  if (_supabaseClient != null) {
                                    await _supabaseClient!.from('school_notices').delete().eq('id', n['id']);
                                    setState(() {});
                                  }
                                },
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

            // ==================== TAB 7: COMPLAINTS ====================
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _supabaseClient != null
                  ? _supabaseClient!.from('school_complaints').select().order('created_at', ascending: false)
                  : Future.value([]),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No parent grievances submitted.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final c = snapshot.data![i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFEE2E2))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c['category'] ?? 'Complaint', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                              DropdownButton<String>(
                                value: c['status'] ?? 'Under Review',
                                underline: const SizedBox(),
                                items: ['Under Review', 'Action Taken', 'Resolved']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) async {
                                  if (val != null && _supabaseClient != null) {
                                    await _supabaseClient!.from('school_complaints').update({'status': val}).eq('id', c['id']);
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('From: ${c['parent_name']} (Student: ${c['student_name']})', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 6),
                          Text(c['details'] ?? '', style: const TextStyle(fontSize: 12.5)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // ==================== TAB 8: EXAMS & Q-PAPERS MANAGER ====================
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD97706).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CLASS-WISE EXAM & QUESTION PAPER MANAGER',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFD97706)),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _manageExamClass,
                          decoration: const InputDecoration(labelText: 'Select Target Class', border: OutlineInputBorder()),
                          items: schoolClasses
                              .where((c) => c != 'ALL' && c != 'Not Assigned')
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _manageExamClass = v);
                          },
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Section A: PDF Question Paper Upload
                        const Text('1. Upload Question Paper PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF1E3A8A))),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97706),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                            label: Text('Upload PDF for $_manageExamClass'),
                            onPressed: _pickAndUploadExamPdf,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Section B: Add MCQ Question
                        const Text('2. Add Interactive MCQ Question', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF1E3A8A))),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _examQuestionCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Question Statement *', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: TextField(controller: _optACtrl, decoration: const InputDecoration(labelText: 'Option A *', border: OutlineInputBorder()))),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(controller: _optBCtrl, decoration: const InputDecoration(labelText: 'Option B *', border: OutlineInputBorder()))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: TextField(controller: _optCCtrl, decoration: const InputDecoration(labelText: 'Option C', border: OutlineInputBorder()))),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(controller: _optDCtrl, decoration: const InputDecoration(labelText: 'Option D', border: OutlineInputBorder()))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Correct Option:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 12),
                            DropdownButton<int>(
                              value: _correctOptIndex,
                              items: const [
                                DropdownMenuItem(value: 0, child: Text('Option A')),
                                DropdownMenuItem(value: 1, child: Text('Option B')),
                                DropdownMenuItem(value: 2, child: Text('Option C')),
                                DropdownMenuItem(value: 3, child: Text('Option D')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _correctOptIndex = val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _expCtrl,
                          decoration: const InputDecoration(labelText: 'Explanation (Shown after answering)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isSavingExam ? null : _saveMcqQuestion,
                            child: _isSavingExam
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Save MCQ for $_manageExamClass', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('ACTIVE EXAM MATERIALS FOR: $_manageExamClass', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _supabaseClient != null
                        ? _supabaseClient!.from('school_exams').select().eq('class_name', _manageExamClass).order('created_at', ascending: false)
                        : Future.value([]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final examItems = snapshot.data!;
                      if (examItems.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('No question papers or MCQs uploaded for $_manageExamClass yet.', style: const TextStyle(color: Color(0xFF64748B))),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: examItems.length,
                        itemBuilder: (context, i) {
                          final ex = examItems[i];
                          final isPdf = (ex['exam_type'] ?? '') == 'pdf';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                isPdf ? Icons.picture_as_pdf_rounded : Icons.quiz_rounded,
                                color: isPdf ? const Color(0xFFD97706) : const Color(0xFF1E3A8A),
                              ),
                              title: Text(ex['title'] ?? ex['question'] ?? 'Exam Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              subtitle: Text(isPdf ? 'PDF Question Paper' : 'MCQ Question • Correct: Option ${String.fromCharCode(65 + ((ex['correct_index'] as num?)?.toInt() ?? 0))}', style: const TextStyle(fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                onPressed: () async {
                                  if (_supabaseClient != null) {
                                    await _supabaseClient!.from('school_exams').delete().eq('id', ex['id']);
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiMiniCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
