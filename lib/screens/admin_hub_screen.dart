import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHubScreen extends StatefulWidget {
  const AdminHubScreen({super.key});

  @override
  State<AdminHubScreen> createState() => _AdminHubScreenState();
}

class _AdminHubScreenState extends State<AdminHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & Filter state
  final TextEditingController _studentSearchCtrl = TextEditingController();
  final TextEditingController _feeSearchCtrl = TextEditingController();
  String _selectedClassFilter = 'ALL';
  String _studentQuery = '';
  String _feeQuery = '';

  // Comprehensive Class Hierarchy List
  static const List<String> schoolClasses = [
    'Nursery', 'L.K.G.', 'U.K.G.',
    'Class 1-A', 'Class 1-B', 'Class 2-A', 'Class 2-B',
    'Class 3-A', 'Class 3-B', 'Class 4-A', 'Class 4-B',
    'Class 5-A', 'Class 5-B', 'Class 6-A', 'Class 6-B',
    'Class 7-A', 'Class 7-B', 'Class 8-A', 'Class 8-B',
    'Class 9-A', 'Class 9-B', 'Class 10-A', 'Class 10-B',
    'Class 11 - Science', 'Class 11 - Commerce', 'Class 11 - Arts',
    'Class 12 - Science', 'Class 12 - Commerce', 'Class 12 - Arts',
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
  String _formClass = 'Class 10-A';
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
    _tabController = TabController(length: 7, vsync: this);
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
    super.dispose();
  }

  // ==========================================
  // MODAL: ADD / EDIT FULL STUDENT PROFILE
  // ==========================================
  void _openStudentModal({Map<String, dynamic>? student}) {
    final isEdit = student != null;
    if (isEdit) {
      _studentNameCtrl.text = student['student_name'] ?? '';
      _rollNoCtrl.text = (student['roll_number'] ?? student['roll_no'] ?? '').toString();
      _admNoCtrl.text = (student['admission_number'] ?? student['scholar_no'] ?? '').toString();
      _formClass = schoolClasses.contains(student['class_grade'])
          ? student['class_grade']
          : 'Class 10-A';
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
      _formClass = 'Class 10-A';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F1E36)),
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

  // ==========================================
  // MODAL: ADVANCED FEE LEDGER & RECEIPT
  // ==========================================
  void _openFeeLedgerModal(Map<String, dynamic> student) {
    final payAmountCtrl = TextEditingController(text: (student['pending_fees'] ?? '0').toString());
    final editDueCtrl = TextEditingController(text: (student['pending_fees'] ?? '0').toString());
    final remarksCtrl = TextEditingController();
    String payMode = 'Cash';
    String payTerm = 'Term 1 / Monthly Fee';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                          color: const Color(0xFFF8FAFC),
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
                          color: Colors.white,
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
                      const Text('PAYMENT AUDIT TRAIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
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
                                  color: Colors.white,
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
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
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

  // ==========================================
  // MODAL: ADD NEW FACULTY / TEACHER
  // ==========================================
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Management Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F1E36),
        foregroundColor: Colors.white,
        elevation: 1,
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: STUDENTS
          Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
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
                  color: Colors.white,
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
                              hintText: 'Search student name or phone...',
                              hintStyle: const TextStyle(fontSize: 12),
                              prefixIcon: const Icon(Icons.search_rounded, size: 18),
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedClassFilter,
                            items: ['ALL', ...schoolClasses]
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
                      var list = snapshot.data!;

                      if (_studentQuery.isNotEmpty) {
                        list = list.where((s) {
                          final name = (s['student_name'] ?? '').toString().toLowerCase();
                          final phone = (s['parent_phone'] ?? s['mobile_number'] ?? '').toString().toLowerCase();
                          return name.contains(_studentQuery) || phone.contains(_studentQuery);
                        }).toList();
                      }

                      if (_selectedClassFilter != 'ALL') {
                        list = list.where((s) {
                          final grade = (s['class_grade'] ?? '').toString();
                          return grade == _selectedClassFilter;
                        }).toList();
                      }

                      if (list.isEmpty) {
                        return const Center(child: Text('No matching students found.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 85),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                                    child: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                                  ),
                                  title: Text(s['student_name'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // TAB 2: FEES
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: TextField(
                  controller: _feeSearchCtrl,
                  onChanged: (v) => setState(() => _feeQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search fee by student name or roll...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
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
                      list = list.where((s) => (s['student_name'] ?? '').toString().toLowerCase().contains(_feeQuery)).toList();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final s = list[i];
                        final pending = s['pending_fees'] ?? '0';
                        final isClear = pending == '0' || pending == 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(s['student_name'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(
                              'Class: ${s['class_grade'] ?? 'N/A'}\n${isClear ? 'All Dues Paid ✓' : 'Pending: ₹$pending'}',
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

          // TAB 3: ATTENDANCE
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _supabaseClient != null
                ? _supabaseClient!.from('students').select().order('class_grade')
                : Future.value([]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final list = snapshot.data!;
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

          // TAB 4: FACULTY
          Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
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

          // TAB 5: GALLERY
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HOMEPAGE HERO SLIDESHOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 6),
                      const Text('Update homepage hero photos and campus highlight pictures directly.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                          icon: const Icon(Icons.add_photo_alternate_rounded),
                          label: const Text('Select Photos from Device'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Media picker connected.')));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('ACTIVE CAMPUS MEDIA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildGalleryThumb('Main Campus Building', 'Hero Slideshow'),
                    _buildGalleryThumb('Smart Science Lab', 'Campus Life'),
                    _buildGalleryThumb('Sports & Playground', 'Athletics'),
                    _buildGalleryThumb('Morning Assembly', 'Daily Life'),
                  ],
                ),
              ],
            ),
          ),

          // TAB 6: CIRCULARS
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PUBLISH NOTICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _noticeTag,
                        items: ['GENERAL', 'EXAMS', 'HOLIDAY', 'SPORTS', 'URGENT']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (v) => setState(() => _noticeTag = v!),
                        decoration: const InputDecoration(labelText: 'Tag Category', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(controller: _noticeTitleCtrl, decoration: const InputDecoration(labelText: 'Notice Title', border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(controller: _noticeContentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Full Announcement Details', border: OutlineInputBorder())),
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
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notice broadcasted to App and Website!')));
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
                              : const Text('Publish Notice', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
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

          // TAB 7: COMPLAINTS
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFEE2E2))),
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
        ],
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

  Widget _buildGalleryThumb(String title, String tag) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(4)),
            child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
