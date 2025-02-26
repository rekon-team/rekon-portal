import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rekonportal/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_provider.dart';

class ConfirmLogoutDialog extends StatelessWidget {
  const ConfirmLogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          var storage = FlutterSecureStorage();
          await storage.deleteAll();
          prefs.clear();
          Phoenix.rebirth(context);
          Navigator.pop(context);
        }, child: const Text('Log Out')),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 24),
              const SizedBox(height: 12),
              Text('Theme Settings:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 24),
                  Text('Dark Mode', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Switch(value: themeProvider.isDarkMode, onChanged: (value) {
                    setState(() {
                      themeProvider.toggleTheme();
                    });
                  }),
                ],
              ),
              const SizedBox(height: 24),
              Text('Account Settings:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(context: context, builder: (context) => const ConfirmLogoutDialog());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onError,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Log Out', style: TextStyle(color: AppColors.onError, fontSize: 16,)),
                        const SizedBox(width: 12),
                        const Icon(Icons.logout, color: AppColors.onError, size: 16,),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

