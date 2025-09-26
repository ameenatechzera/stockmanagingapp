import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'package:stockapp/core/theme/theme_provider.dart';
import 'package:stockapp/presentation/home/widgets/home_option_actions.dart';
import 'package:stockapp/presentation/home/widgets/option_buttons.dart';
import 'package:stockapp/presentation/settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<OptionItem> options = const [
    OptionItem(
      icon: Icons.download_rounded,
      label: 'Import Product',
      gradient: LinearGradient(
        colors: [Color.fromARGB(255, 82, 178, 210), Color(0xffc5fdd8)],
      ), // Softer cyan to mint
    ),
    OptionItem(
      icon: Icons.upload_rounded,
      label: 'Export Stock',
      gradient: LinearGradient(
        colors: [Color(0xffffd580), Color(0xfffff3b0)],
      ), // Light orange to pale yellow
    ),
    OptionItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Stock Take',
      gradient: LinearGradient(
        colors: [Color(0xffb2f3c2), Color(0xffa3fce8)],
      ), // Light green to aqua
    ),
    OptionItem(
      icon: Icons.delete_forever_rounded,
      label: 'Clear Stock',
      gradient: LinearGradient(
        colors: [Color(0xffffb3c1), Color(0xffffc19a)],
      ), // Soft pink to light coral
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xff0A192F) : const Color(0xffF5F7FA),
      appBar: AppBar(
        toolbarHeight: 36,
        backgroundColor:
            isDarkMode ? const Color(0xFF1C1243) : Color(0xFF1C1243),
        elevation: 1,
        // centerTitle: true,
        title: Text(
          "Stock Manager",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kwhite,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 20),
            color: kwhite,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsScreen();
                  },
                ),
              );
            },
          ), // 🔒
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: 20,
            ),
            color: kwhite,
            onPressed: () {
              final themeProvider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );
              themeProvider.toggleTheme(!isDarkMode);
            },
          ), // 🔒 Logout button
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            color: kwhite,
            tooltip: 'Logout & Exit',
            onPressed: () {
              // For Android:
              SystemNavigator.pop();
              // For iOS (or if you want to force exit everywhere), uncomment:
              // exit(0);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1C1243), Color.fromARGB(255, 22, 8, 20)],
                  )
                  : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5F7FA), Color(0xFFE4E7EB)],
                  ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: HomeOptionButton(
                      icon: options[0].icon,
                      label: options[0].label,
                      gradient: options[0].gradient,
                      onTap:
                          () => HomeOptionActions.handleTap(
                            context,
                            options[0].label,
                          ),
                      width: 400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HomeOptionButton(
                      icon: options[1].icon,
                      label: options[1].label,
                      gradient: options[1].gradient,
                      onTap:
                          () => HomeOptionActions.handleTap(
                            context,
                            options[1].label,
                          ),
                      width: 400,
                    ),
                  ),
                ],
              ),

              // Full-width Scan Barcode
              HomeOptionButton(
                icon: options[2].icon,
                label: options[2].label,
                gradient: options[2].gradient,
                onTap:
                    () =>
                        HomeOptionActions.handleTap(context, options[2].label),
                width: 400,

                // fill width
                // minHeight: 80,
              ),

              // Full-width Clear Stock
              HomeOptionButton(
                icon: options[3].icon,
                label: options[3].label,
                gradient: options[3].gradient,
                onTap:
                    () =>
                        HomeOptionActions.handleTap(context, options[3].label),

                // minHeight: 80,
                width: 400,
              ),
            ],
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
