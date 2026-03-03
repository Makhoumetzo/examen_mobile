import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:projet_examen/models/config.dart';
import 'package:projet_examen/screens/second_screen.dart';
import 'package:projet_examen/theme/theme_manager.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fond dégradé ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF0A0E1A), Color(0xFF141929), Color(0xFF1B2B50)]
                    : const [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF38BDF8)],
              ),
            ),
          ),

          // ── Cercles décoratifs ─────────────────────────────────────────
          Positioned(
            top: -70,
            right: -50,
            child: _decorCircle(240, Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _decorCircle(300, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            top: size.height * 0.38,
            left: -30,
            child: _decorCircle(140, const Color(0xFF38BDF8).withValues(alpha: 0.12)),
          ),
          Positioned(
            top: size.height * 0.15,
            right: 20,
            child: _decorCircle(80, const Color(0xFF818CF8).withValues(alpha: 0.15)),
          ),

          // ── Contenu principal ──────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),

                      // Logo + nom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wb_sunny_rounded,
                              color: Colors.amber.shade300, size: 26),
                          const SizedBox(width: 10),
                          const Text(
                            'MétéoVision',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontFamily: family,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Séparateur gradient
                      Container(
                        height: 3,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                          ),
                        ),
                      ),
                      const SizedBox(height: 44),

                      // Animation météo dans un cercle lumineux
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                              blurRadius: 50,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Lottie.asset('assets/lotties/ensoleille.json'),
                        ),
                      ),
                      const SizedBox(height: 42),

                      // Titre bienvenue
                      const Text(
                        'Bienvenue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontFamily: family,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Sous-titre
                      Text(
                        'Des prévisions météo précises\npour votre quotidien',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 16,
                          fontFamily: family,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),

                      const Spacer(),

                      // Bouton démarrer
                      _buildStartButton(context),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (c, a1, a2) => const SecondScreen(),
                transitionsBuilder: (c, anim, a2, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Découvrir la météo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontFamily: family,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
