import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHubScreen extends StatefulWidget {
  const AdminHubScreen({super.key});

  @override
  State<AdminHubScreen> createState() => _AdminHubScreenState();
}

class _AdminHubScreenState extends State<AdminHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _studentNameCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _classGradeCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  final _birthYearCtrl = TextEditingController();
  bool _isAddingStudent = false;

  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _selectedTag = 'EXAMS';
  bool _isPostingNotice = false;

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
    final client = _supabaseClient;
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student registered! Parent can login using Phone: $phone and Year: $bYear'),
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

  Future<void> _publishNotice() async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) return;
    final client = _supabaseClient;
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
              future: _supabaseClient != null
                  ? _supabaseClient!.from('students').select().order('created_at', ascending: false)
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
                        title: Text(s['student_name'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Class: ${s['class_grade'] ?? 'N/A'}\nLogin Phone: $phone • DOB/Year: $bYear'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Student?'),
                                content: Text('Remove ${s['student_name']} permanently? Parent will no longer be able to log in.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true && _supabaseClient != null) {
                              await _supabaseClient!.from('students').delete().eq('id', s['id']);
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BROADCAST CIRCULAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedTag,
                        items: ['EXAMS', 'HOLIDAY', 'SPORTS', 'URGENT']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedTag = val!),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                          hintText: 'Notice Title',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _contentCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Full Announcement Details',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _isPostingNotice ? null : _publishNotice,
                          child: _isPostingNotice
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Publish (Sync to Web & App)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _supabaseClient != null
                ? _supabaseClient!.from('school_complaints').select().order('created_at', ascending: false)
                : Future.value([]),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No complaints submitted.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) {
                  final c = snapshot.data![i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c['category'] ?? 'Complaint', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                            Text(c['status'] ?? 'Under Review', style: const TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('From: ${c['parent_name']} (Student: ${c['student_name']})', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 6),
                        Text(c['details'] ?? '', style: const TextStyle(fontSize: 13)),
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
}
