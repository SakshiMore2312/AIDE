import 'package:flutter/material.dart';
import 'onboarding_page.dart';
import 'theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EduConnectApp());
}

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EduConnect',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            brightness: Brightness.light,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey.shade50,
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFF121212), // Deeper background
            cardColor: const Color(0xFF1E1E1E), // Lighter card for depth
            canvasColor: const Color(0xFF1E1E1E),
            dividerColor: Colors.white12,
            useMaterial3: true,
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              elevation: 0,
            ),
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              secondary: Colors.deepPurpleAccent,
              surface: const Color(0xFF1E1E1E),
              background: const Color(0xFF121212),
              onBackground: Colors.white,
              onSurface: Colors.white,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const OnboardingPage(),
        );
      },
    );
  }
}