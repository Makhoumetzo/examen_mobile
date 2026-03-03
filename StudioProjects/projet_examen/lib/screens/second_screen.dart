import 'package:flutter/material.dart';
import 'package:projet_examen/models/config.dart';
import 'package:projet_examen/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import '../widgets/waiting_message.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.wb_sunny_rounded,
                color: Colors.amber.shade300, size: 20),
            const SizedBox(width: 8),
            const Text(
              'MétéoVision',
              style: TextStyle(
                color: Colors.white,
                fontFamily: family,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => themeManager.toggleTheme(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isDark ? 'Clair' : 'Sombre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: family,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF0A0E1A), Color(0xFF141929), Color(0xFF1B2B50)]
                : const [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF38BDF8)],
          ),
        ),
        child: Center(
          child: WaitingMessage(
            onRestart: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => const SecondScreen(),
                  transitionsBuilder: (c, anim, a2, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}