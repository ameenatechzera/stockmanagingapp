import 'package:flutter/material.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'package:stockapp/presentation/home/widgets/home_option_actions.dart';
import 'package:stockapp/presentation/home/widgets/option_buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final List<OptionItem> options = const [
    OptionItem(
      icon: Icons.upload_file_rounded,
      label: 'Import Stock',
      gradient: LinearGradient(colors: [Color(0xff00C9FF), Color(0xff92FE9D)]),
    ),
    OptionItem(
      icon: Icons.download_rounded,
      label: 'Export Stock',
      gradient: LinearGradient(colors: [Color(0xfff7971e), Color(0xffffd200)]),
    ),
    OptionItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan Barcode',
      gradient: LinearGradient(colors: [Color(0xff43e97b), Color(0xff38f9d7)]),
    ),
    OptionItem(
      icon: Icons.delete_forever_rounded,
      label: 'Clear Stock',
      gradient: LinearGradient(colors: [Color(0xffee0979), Color(0xffff6a00)]),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF1C1243),

        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Stock Manager",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kwhite,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1243), // Top
              Color.fromARGB(255, 22, 8, 20), // Bottom
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            itemCount: options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              final option = options[index];
              return HomeOptionButton(
                icon: option.icon,
                label: option.label,
                gradient: option.gradient,
                onTap: () => HomeOptionActions.handleTap(context, option.label),
              );
            },
          ),
        ),
      ),
    );
  }
}

class OptionItem {
  final IconData icon;
  final String label;
  final Gradient gradient;

  const OptionItem({
    required this.icon,
    required this.label,
    required this.gradient,
  });
}
