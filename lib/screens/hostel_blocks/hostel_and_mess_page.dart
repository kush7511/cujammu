import 'package:flutter/material.dart';

import 'brs_boys_hostel_block_screen.dart';
import 'shailputri_girls_hostel_block_screen.dart';
import 'spm_boys_hostel_block_screen.dart';

class HostelAndMessPage extends StatelessWidget {
  const HostelAndMessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hostel & Mess")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            "Hostel Blocks",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Select your hostel block to continue.",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 20),
          _HostelBlockCard(
            name: "SPM Boys Hostel",
            subtitle: "SPM Block",
            icon: Icons.apartment_rounded,
            backgroundColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF1565C0),
            destination: SpmBoysHostelBlockScreen(),
          ),
          SizedBox(height: 12),
          _HostelBlockCard(
            name: "BRS Boys Hostel",
            subtitle: "BRS Block",
            icon: Icons.apartment_rounded,
            backgroundColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF2E7D32),
            destination: BrsBoysHostelBlockScreen(),
          ),
          SizedBox(height: 12),
          _HostelBlockCard(
            name: "Shailputri Girls Hostel",
            subtitle: "Shailputri Block",
            icon: Icons.apartment_rounded,
            backgroundColor: Color(0xFFFCE4EC),
            iconColor: Color(0xFFAD1457),
            destination: ShailputriGirlsHostelBlockScreen(),
          ),
        ],
      ),
    );
  }
}

class _HostelBlockCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Widget destination;

  const _HostelBlockCard({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 106),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
