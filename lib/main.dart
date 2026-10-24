import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved theme preference
  try {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('ssd_dark_mode') ?? false;
    appThemeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  } catch (_) {}

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0F1E36),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SSDConventApp());
}

class SSDConventApp extends StatelessWidget {
  const SSDConventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'S.S.D. Convent School',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            primaryColor: const Color(0xFF1E3A8A),
            cardColor: Colors.white,
            dividerColor: const Color(0xFFE2E8F0),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              secondary: Color(0xFFD97706),
              surface: Colors.white,
              error: Color(0xFFDC2626),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF0F1E36),
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0B1120),
            primaryColor: const Color(0xFF3B82F6),
            cardColor: const Color(0xFF1E293B),
            dividerColor: const Color(0xFF334155),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              secondary: Color(0xFFF59E0B),
              surface: Color(0xFF1E293B),
              error: Color(0xFFEF4444),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
