import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekonportal/dashboard/home.dart';
import 'package:rekonportal/entry_flow/create_account.dart';
import 'package:rekonportal/entry_flow/log_in.dart';
import 'package:rekonportal/entry_flow/verification.dart';
import 'package:rekonportal/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // Get shared preferences instance
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString('stage') == null) {
      prefs.setString('stage', 'start');
    } else if (prefs.getString('stage') == 'start') {
      setState(() {
        _isLoading = false;
      });
    } else if (prefs.getString('stage') == 'verification') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VerificationPage(email: prefs.getString('email') ?? '')),
      );
    } else if (prefs.getString('stage') == 'home') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              iconSize: 32, // Larger icon
              icon: Icon(
                Provider.of<ThemeProvider>(context).isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo placeholder
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    size: 60,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Welcome text
              Text(
                'Welcome to RēkonPortal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The all-in-one platform for managing your scouting team and analyzing data',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              MainButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class MainButtons extends StatelessWidget {
  const MainButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          // Use Column for smaller screens
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountPage(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        } else {
          // Use Row for larger screens
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountPage(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
