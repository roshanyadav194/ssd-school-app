import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> studentData;
  const DashboardScreen({super.key, required this.studentData});

  SupabaseClient? get _supabaseClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

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
                      final client = _supabaseClient;
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
                          'Parent of $studentName (Class $className)',
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
