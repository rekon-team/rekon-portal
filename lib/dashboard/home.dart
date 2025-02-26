import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rekonportal/dashboard/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  int pageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: switch (pageIndex) {
          0 => const Text('Dashboard'),
          1 => const Text('Search'),
          2 => const Text('Settings'),
          _ => const Text('Dashboard'),
        },
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: colorScheme.onPrimary,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            username,
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Navigation Menu',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: pageIndex == 0,
              onTap: () {
                setState(() {
                  pageIndex = 0;
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              selected: pageIndex == 1,
              onTap: () {
                setState(() {
                  pageIndex = 1;
                });
                Navigator.pop(context); // Close the drawer
                // Add navigation logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search page coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              selected: pageIndex == 2,
              onTap: () {
                setState(() {
                  pageIndex = 2;
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              selected: pageIndex == 3,
              onTap: () {
                setState(() {
                  pageIndex = 3;
                });
                Navigator.pop(context);
                // Add help page navigation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help page coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
      body: switch (pageIndex) {
        0 => MainBody(colorScheme: colorScheme),
        2 => SettingsPage(),
        _ => MainBody(colorScheme: colorScheme),
      },
    );
  }
}

class MainBody extends StatelessWidget {
  const MainBody({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home,
            size: 80,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Your Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This is a placeholder homepage. Add your content here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              // Add navigation or action here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Button pressed!')),
              );
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}
