import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your custom native screens
import 'school_discovery_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend for gallery, exams, and notices
  try {
    await Supabase.initialize(
      url: 'https://whqdfdhhubcvymuoyjvv.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndocWRmZGh1YmN2eW11b3lqdnYiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTczODk0NjM5MSwiZXhwIjoyMDU0NTIyMzkxfQ.6r2V1yLw1l_t3N7u_R1y1v_U2j8v6w4x2y0z1a2b3c',
    );
  } catch (_) {}

  // Lock status bar and navigation bar to Dark Royal branding
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF061123),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SSDConventApp());
}

// Global Theme Toggle Notifier for Dark Royal / Light Theme
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void toggleSSDTheme() {
  themeNotifier.value = themeNotifier.value == ThemeMode.dark
      ? ThemeMode.light
      : ThemeMode.dark;
}

class SSDConventApp extends StatelessWidget {
  const SSDConventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'S.S.D. Convent School',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF1E3A8A),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            fontFamily: 'Roboto',
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF2563EB),
            scaffoldBackgroundColor: const Color(0xFF061123),
            fontFamily: 'Roboto',
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          // Directly launches your native Dark Royal interface!
          home: const SchoolDiscoveryScreen(),
        );
      },
    );
  }
}
