import 'package:flutter/material.dart';
import 'package:projet_examen/models/config.dart';
import 'package:projet_examen/models/ville.dart';
import 'package:projet_examen/screens/ville_details_screen.dart';

class MeteoTable extends StatelessWidget {
  final List<Ville> villes;
  final List<Map<String, dynamic>> meteoDataList;

  const MeteoTable({
    super.key,
    required this.villes,
    required this.meteoDataList,
  });

  // Icône selon la condition météo
  IconData _weatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('pluie')) return Icons.grain_rounded;
    if (c.contains('cloud') || c.contains('nuage')) return Icons.cloud_rounded;
    if (c.contains('snow') || c.contains('neige')) return Icons.ac_unit_rounded;
    if (c.contains('storm') || c.contains('thunder')) return Icons.thunderstorm_rounded;
    if (c.contains('fog') || c.contains('mist') || c.contains('haze')) {
      return Icons.foggy;
    }
    return Icons.wb_sunny_rounded;
  }

  // Couleur selon la température
  Color _tempColor(double temp) {
    if (temp <= 0) return const Color(0xFF60A5FA);
    if (temp <= 10) return const Color(0xFF93C5FD);
    if (temp <= 20) return const Color(0xFF34D399);
    if (temp <= 30) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  // Emoji drapeau par ville
  String _cityFlag(String nom) {
    switch (nom.toLowerCase()) {
      case 'dakar': return '🇸🇳';
      case 'paris': return '🇫🇷';
      case 'tokyo': return '🇯🇵';
      case 'new york': return '🇺🇸';
      case 'london': return '🇬🇧';
      default: return '🌍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Météo des villes',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: family,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Liste des cartes villes ───────────────────────────────────
          ...List.generate(villes.length, (index) {
            final ville = villes[index];
            final meteoData =
                index < meteoDataList.length ? meteoDataList[index] : null;
            final color = _tempColor(ville.temperature);

            return _CityCard(
              ville: ville,
              meteoData: meteoData,
              icon: _weatherIcon(ville.couverture),
              iconColor: color,
              flag: _cityFlag(ville.nom),
              tempColor: color,
            );
          }),
        ],
      ),
    );
  }
}

class _CityCard extends StatefulWidget {
  final Ville ville;
  final Map<String, dynamic>? meteoData;
  final IconData icon;
  final Color iconColor;
  final String flag;
  final Color tempColor;

  const _CityCard({
    required this.ville,
    required this.meteoData,
    required this.icon,
    required this.iconColor,
    required this.flag,
    required this.tempColor,
  });

  @override
  State<_CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<_CityCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        if (widget.meteoData != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (c, a1, a2) => VilleDetailsScreen(
                ville: widget.ville,
                meteoData: widget.meteoData!,
              ),
              transitionsBuilder: (c, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        }
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Drapeau
              Text(widget.flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),

              // Nom + condition
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.ville.nom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: family,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.ville.couverture,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontFamily: family,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Icône météo
              Icon(widget.icon, color: widget.iconColor, size: 24),
              const SizedBox(width: 12),

              // Température badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.tempColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: widget.tempColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${widget.ville.temperature.toStringAsFixed(1)}°',
                  style: TextStyle(
                    color: widget.tempColor,
                    fontFamily: family,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Flèche
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}