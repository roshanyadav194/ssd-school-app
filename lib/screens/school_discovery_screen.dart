import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class SchoolDiscoveryScreen extends StatefulWidget {
  const SchoolDiscoveryScreen({super.key});

  @override
  State<SchoolDiscoveryScreen> createState() => _SchoolDiscoveryScreenState();
}

class _SchoolDiscoveryScreenState extends State<SchoolDiscoveryScreen> {
  String? _selectedClass;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMaps() async {
    final Uri mapUri = Uri.parse('https://maps.google.com/?q=S.S.D.+Convent+School+Champapur+Janghai+Prayagraj');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F1E36), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: Color(0xFF1E3A8A), size: 22),
            SizedBox(width: 8),
            Text(
              'S.S.D. Convent School',
              style: TextStyle(color: Color(0xFF0F1E36), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Intro Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F1E36), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEARN • GROW • ACHIEVE',
                    style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'A brighter future\nstarts here.',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Champapur, Janghai, Prayagraj — A place to learn with confidence, curiosity, and care.',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 1: Contact Details Header
            const Text(
              'GET IN TOUCH WITH US',
              style: TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
            ),
            const SizedBox(height: 4),
            const Text(
              'Contact & Campus Directory',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F1E36)),
            ),
            const SizedBox(height: 12),

            // --- 2x2 VERTICAL GRID FOR CONTACT CARDS ---
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                // Box 1: Phone Helpline
                _buildInfoCard(
                  icon: Icons.phone_in_talk_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Phone Helpline',
                  content: '+91 78808 84750\n+91 85608 22342',
                  actionText: 'Call Office',
                  onTap: () => _makePhoneCall('+917880884750'),
                ),

                // Box 2: Campus Address
                _buildInfoCard(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFFDC2626),
                  title: 'Campus Address',
                  content: 'Champapur, Handia Road, Janghai, Prayagraj',
                  actionText: 'Open in Maps',
                  onTap: _openMaps,
                ),

                // Box 3: Office Hours
                _buildInfoCard(
                  icon: Icons.access_time_filled_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Visiting Hours',
                  content: 'Mon – Sat:\n8:00 AM – 2:00 PM\n(Closed Sundays)',
                  actionText: null,
                  onTap: null,
                ),

                // Box 4: Official Email
                _buildInfoCard(
                  icon: Icons.email_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Official Email',
                  content: 'info@ssdconvent.com\nLogged queries via Parent Portal',
                  actionText: 'Send Email',
                  onTap: () async {
                    final Uri emailUri = Uri(scheme: 'mailto', path: 'info@ssdconvent.com');
                    if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Call & WhatsApp Action Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F1E36),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _makePhoneCall('+917880884750'),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Call School Office', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openWhatsApp('917880884750'),
                    icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                    label: const Text('WhatsApp Chat', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Section 2: Online Exam & Assessment Portal
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ASSESSMENT PORTAL',
                    style: TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SSD Online Exam & Practice Tests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F1E36)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select your class to access timed practice tests, mock exams, and instant evaluations.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    hint: const Text('-- Scroll & Choose Class --', style: TextStyle(fontSize: 13)),
                    items: ['Nursery / KG', 'Class 1 to 5', 'Class 6 to 8', 'Class 9 & 10', 'Class 11 & 12']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedClass = val),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (_selectedClass == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a class first')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Proceeding to practice exam for $_selectedClass...')),
                          );
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Proceed to Exam Hall', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section 3: Campus & Student Life
            const Text(
              'PHOTO SHOWCASE',
              style: TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            const Text(
              'Campus & Student Life',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F1E36)),
            ),
            const SizedBox(height: 12),
            _buildShowcaseTile(
              title: 'Main School Building & Grounds',
              subtitle: 'Modern campus located at Handia Road, Janghai',
              icon: Icons.apartment_rounded,
            ),
            const SizedBox(height: 10),
            _buildShowcaseTile(
              title: 'Interactive Smart Classrooms',
              subtitle: 'Equipped with visual educational tools',
              icon: Icons.computer_rounded,
            ),
            const SizedBox(height: 10),
            _buildShowcaseTile(
              title: 'Science Activities & Assembly',
              subtitle: 'Daily student growth, presentations, and morning assemblies',
              icon: Icons.science_rounded,
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  Text('Login to Family Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? actionText,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36)),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          if (actionText != null && onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: TextStyle(color: iconColor, fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: iconColor),
                ],
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildShowcaseTile({required String title, required String subtitle, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F1E36))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
