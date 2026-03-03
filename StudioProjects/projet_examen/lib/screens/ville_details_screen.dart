import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projet_examen/models/config.dart';
import 'package:projet_examen/models/ville.dart';

class VilleDetailsScreen extends StatefulWidget {
  final Ville ville;
  final Map<String, dynamic> meteoData;

  const VilleDetailsScreen({
    super.key,
    required this.ville,
    required this.meteoData,
  });

  @override
  State<VilleDetailsScreen> createState() => _VilleDetailsScreenState();
}

class _VilleDetailsScreenState extends State<VilleDetailsScreen> {
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    _center = LatLng(
      (widget.meteoData['coord']['lat'] as num).toDouble(),
      (widget.meteoData['coord']['lon'] as num).toDouble(),
    );
  }

  IconData _weatherIcon() {
    final c = widget.ville.couverture.toLowerCase();
    if (c.contains('rain') || c.contains('pluie')) return Icons.grain_rounded;
    if (c.contains('cloud') || c.contains('nuage')) return Icons.cloud_rounded;
    if (c.contains('snow') || c.contains('neige')) return Icons.ac_unit_rounded;
    if (c.contains('storm') || c.contains('thunder')) return Icons.thunderstorm_rounded;
    return Icons.wb_sunny_rounded;
  }

  Color _weatherColor() {
    final c = widget.ville.couverture.toLowerCase();
    if (c.contains('rain') || c.contains('pluie')) return const Color(0xFF60A5FA);
    if (c.contains('cloud') || c.contains('nuage')) return const Color(0xFFCBD5E1);
    if (c.contains('snow') || c.contains('neige')) return const Color(0xFFBAE6FD);
    return Colors.amber.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final gradientColor = _weatherColor();
    final double windSpeed = widget.meteoData.containsKey('wind')
        ? (widget.meteoData['wind']['speed'] as num).toDouble()
        : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.25),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── En-tête dégradé avec infos météo ─────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
                top: 100, bottom: 30, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0E1A),
                  const Color(0xFF1B2B50),
                  gradientColor.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Column(
              children: [
                // Nom de la ville
                Text(
                  widget.ville.nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: family,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Condition météo
                Text(
                  widget.ville.couverture,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontFamily: family,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),

                // Icône + Température
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_weatherIcon(), color: gradientColor, size: 52),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.ville.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: family,
                        fontWeight: FontWeight.w900,
                        fontSize: 52,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cartes info : humidité + vent
                Row(
                  children: [
                    _infoCard(
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFF60A5FA),
                      label: 'Humidité',
                      value: '${widget.ville.humidite}%',
                    ),
                    const SizedBox(width: 14),
                    _infoCard(
                      icon: Icons.air_rounded,
                      iconColor: const Color(0xFF818CF8),
                      label: 'Vent',
                      value: '${windSpeed.toStringAsFixed(1)} m/s',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Carte OpenStreetMap (toujours OSM, pas de dark tiles) ──────
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 11.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.projet_examen',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _center,
                          width: 60,
                          height: 60,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: gradientColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradientColor.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _weatherIcon(),
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              CustomPaint(
                                size: const Size(12, 8),
                                painter: _TrianglePainter(gradientColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Attribution OSM
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '© OpenStreetMap',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontFamily: family,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: family,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Petit triangle sous le marqueur météo
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = ui.Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
