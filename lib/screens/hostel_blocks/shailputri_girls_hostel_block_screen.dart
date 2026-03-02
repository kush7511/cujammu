import 'package:flutter/material.dart';

import '../hostel_block_auth_screen.dart';
import '../../data/hostel_student_db.dart';

class ShailputriGirlsHostelBlockScreen extends StatelessWidget {
  const ShailputriGirlsHostelBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HostelBlockAuthScreen(hostelBlock: HostelBlock.shailputriGirls);
  }
}
