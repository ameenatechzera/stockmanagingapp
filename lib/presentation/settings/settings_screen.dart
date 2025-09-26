import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'package:stockapp/data/services/db_helper.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  String? _savedDeviceNumber;

  Future<String?> _loadDeviceNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_number');
  }

  Future<void> _showSaveDeviceNumberDialog(
    BuildContext context,
    void Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: _savedDeviceNumber ?? '');

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save Device Number'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Device Number',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final deviceNumber = controller.text.trim();
                  if (deviceNumber.isNotEmpty) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('device_number', deviceNumber);
                    onSave(deviceNumber); // Update local state
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Device number saved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadDeviceNumber(),
      builder: (context, snapshot) {
        _savedDeviceNumber = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            foregroundColor: kwhite,
            toolbarHeight: 48,

            elevation: 2,
            title: const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSettingsTile(
                icon: Icons.upload,
                title: 'Export Database',

                onTap: () async {
                  try {
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) =>
                              const Center(child: CircularProgressIndicator()),
                    );

                    // Export the file
                    final exportedFile =
                        await StockDatabase.instance.exportDatabaseToDevice();

                    // Hide loading
                    Navigator.pop(context);

                    // Show success message with file path
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Database exported successfully!'),
                            Text(
                              'Location: ${exportedFile!.path}',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 4),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Hide loading if still showing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Export failed: Database not found'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.download,
                title: 'Import Database',

                onTap:
                    () async =>
                        await StockDatabase.instance.importDatabase(context),
              ),
              const SizedBox(height: 12),
              // Wrap tile with StatefulBuilder to update subtitle locally
              StatefulBuilder(
                builder: (context, setState) {
                  return _buildSettingsTile(
                    icon: Icons.phone_iphone,
                    title: 'Save Device Number',
                    subtitle:
                        (_savedDeviceNumber != null &&
                                _savedDeviceNumber!.isNotEmpty)
                            ? 'Saved Device Number: $_savedDeviceNumber'
                            : 'No device number saved',
                    onTap: () async {
                      await _showSaveDeviceNumberDialog(context, (newNumber) {
                        setState(() {
                          _savedDeviceNumber = newNumber;
                        });
                      });
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF1C1243).withOpacity(0.15),
          child: Icon(icon, color: const Color(0xFF1C1243)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
