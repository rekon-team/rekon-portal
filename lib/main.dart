import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:rekonportal/entry_flow/start.dart';
import 'package:rekonportal/theme/theme_provider.dart';

void main() {
  runApp(
    Phoenix(child:
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'RekonPortal',
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D53D4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D53D4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const StartPage(),
    );
  }
}
