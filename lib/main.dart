import 'dart:ui'; // *** NEW: Import for ImageFilter ***
import 'package:empower_ananya/screens/dashboard_screen.dart';
import 'package:empower_ananya/screens/login_screen.dart';
import 'package:empower_ananya/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EmpowerAnanyaApp());
}

class EmpowerAnanyaApp extends StatelessWidget {
  const EmpowerAnanyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- "GLASSMORPHISM" THEME ---
    const Color primaryColor = Color(0xFF0052D4);
    const Color accentColor = Color(0xFF65C7F7);
    const Color backgroundColor = Color(0xFF0D1117);

    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
      title: 'Empower Ananya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
        textTheme: textTheme.apply(
            bodyColor: Colors.white, displayColor: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor
                .withAlpha(204), // FIX: Replaced deprecated withOpacity
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: backgroundColor
              .withAlpha(204), // FIX: Replaced deprecated withOpacity
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white
              .withAlpha(153), // FIX: Replaced deprecated withOpacity
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ).copyWith(secondary: accentColor),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// --- Glass Card Widget ---
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white
                .withAlpha(51)), // FIX: Replaced deprecated withOpacity
        gradient: LinearGradient(
          colors: [
            Colors.white.withAlpha(26), // FIX: Replaced deprecated withOpacity
            Colors.white.withAlpha(13), // FIX: Replaced deprecated withOpacity
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          // ImageFilter is now correctly recognized
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
