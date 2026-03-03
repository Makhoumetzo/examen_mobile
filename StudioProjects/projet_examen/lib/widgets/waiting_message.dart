import 'dart:async';
import 'package:projet_examen/models/config.dart';
import 'package:projet_examen/models/ville.dart';
import 'package:projet_examen/widgets/meteo_table.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/weather_service.dart';

class WaitingMessage extends StatefulWidget {
  final VoidCallback onRestart;
  const WaitingMessage({super.key, required this.onRestart});

  @override
  State<WaitingMessage> createState() => _WaitingMessageState();
}

class _WaitingMessageState extends State<WaitingMessage>
    with SingleTickerProviderStateMixin {
  bool isFinish = false;
  final List<String> villesNames = ['Dakar', 'Paris', 'Tokyo', 'New York', 'London'];
  List<Ville> villes = [];
  List<Map<String, dynamic>> meteoDataList = [];

  int _msgIndex = 0;
  String message = 'Démarrage du téléchargement...';
  late Timer _msgTimer;

  int loadedCount = 0;
  double progressBar = 0;
  double widthProgress = 0;

  bool hasError = false;
  String errorMessage = '';

  // Animation controller pour le pulse du cercle météo
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startMessageTimer();
    _fetchAllWeatherData();
  }

  @override
  void dispose() {
    _msgTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startMessageTimer() {
    final msgs = [
      'Nous téléchargeons les données...',
      'C\'est presque fini...',
      'Plus que quelques instants...',
    ];
    _msgTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        message = msgs[_msgIndex % msgs.length];
        _msgIndex++;
      });
    });
  }

  Future<void> _fetchAllWeatherData() async {
    final meteo = Meteo();
    final total = villesNames.length;
    final futures = villesNames.map((name) => meteo.fetchWeatherData(name));

    try {
      for (final future in futures) {
        final data = await future;
        if (!mounted) return;
        setState(() {
          meteoDataList.add(data);
          villes.add(Ville(
            nom: data['name'],
            couverture: data['weather'][0]['description'],
            temperature: (data['main']['temp'] as num).toDouble(),
            humidite: data['main']['humidity'].toString(),
          ));
          loadedCount++;
          progressBar = (loadedCount / total) * 100;
          widthProgress = (progressBar / 100) * progressbarwidht;
          if (loadedCount >= total) {
            isFinish = true;
            _msgTimer.cancel();
          }
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        errorMessage = 'Erreur lors du chargement des données: $error';
      });
    }
  }

  void _restart() => widget.onRestart();

  Widget _getWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('pluie')) {
      return Lottie.asset('assets/lotties/nuage.json');
    } else if (c.contains('cloud') || c.contains('nuage')) {
      return Lottie.asset('assets/lotties/nuage.json');
    } else if (c.contains('snow') || c.contains('neige')) {
      return Lottie.asset('assets/lotties/nuageux.json');
    } else {
      return Lottie.asset('assets/lotties/ensoleille.json');
    }
  }

  @override
  Widget build(BuildContext context) {
    return hasError
        ? _buildErrorWidget()
        : isFinish
            ? _buildResultWidget()
            : _buildLoadingWidget();
  }

  // ── ÉTAT : ERREUR ────────────────────────────────────────────────────────
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.15),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Colors.redAccent, size: 50),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connexion échouée',
              style: TextStyle(
                color: Colors.white,
                fontFamily: family,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontFamily: family,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _gradientButton('Réessayer', Icons.refresh_rounded, _restart),
          ],
        ),
      ),
    );
  }

  // ── ÉTAT : RÉSULTATS ─────────────────────────────────────────────────────
  Widget _buildResultWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MeteoTable(villes: villes, meteoDataList: meteoDataList),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _gradientButton(
              'Recommencer', Icons.refresh_rounded, _restart),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── ÉTAT : CHARGEMENT ────────────────────────────────────────────────────
  Widget _buildLoadingWidget() {
    final currentVille = villes.isNotEmpty ? villes.last : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Carte glassmorphism ──
            Container(
              width: 310,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Nom de la ville
                  Text(
                    currentVille?.nom ?? 'Chargement...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: family,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Compteur de villes chargées
                  Text(
                    '$loadedCount / ${villesNames.length} villes',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontFamily: family,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animation météo pulsante
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: currentVille != null
                            ? _getWeatherIcon(currentVille.couverture)
                            : Lottie.asset('assets/lotties/nuage.json'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Température
                  Text(
                    currentVille != null
                        ? '${currentVille.temperature.toStringAsFixed(1)}°C'
                        : '-- °C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: family,
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Condition météo
                  Text(
                    currentVille?.couverture ?? '...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontFamily: family,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Humidité
                  if (currentVille != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop_rounded,
                            color: Colors.lightBlueAccent.withValues(alpha: 0.9),
                            size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Humidité : ${currentVille.humidite}%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontFamily: family,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Message d'attente
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                message,
                key: ValueKey(message),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontFamily: family,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Barre de progression gradient
            Container(
              width: progressbarwidht,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    width: widthProgress,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Pourcentage
            Text(
              '${progressBar.ceil()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontFamily: family,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bouton gradient réutilisable ─────────────────────────────────────────
  Widget _gradientButton(String label, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: family,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}