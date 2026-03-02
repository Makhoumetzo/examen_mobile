import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Import direct du fichier interne
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

  // Détermine l'icône météo en fonction de la condition
  IconData _getWeatherIcon() {
    String condition = widget.ville.couverture.toLowerCase();
    if (condition.contains('rain') || condition.contains('pluie')) {
      return Icons.umbrella;
    } else if (condition.contains('cloud') || condition.contains('nuage')) {
      return Icons.cloud;
    } else if (condition.contains('snow') || condition.contains('neige')) {
      return Icons.ac_unit;
    } else {
      return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    if (widget.ville.couverture.toLowerCase().contains('cloud') ||
        widget.ville.couverture.toLowerCase().contains('nuage')) {
      iconColor = Colors.grey;
    } else if (widget.ville.couverture.toLowerCase().contains('rain') ||
        widget.ville.couverture.toLowerCase().contains('pluie')) {
      iconColor = Colors.blue;
    } else {
      iconColor = Colors.amber;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ville.nom),
        backgroundColor: const Color(backScafoldColor),
      ),
      body: Column(
        children: [
          // Informations météo de la ville
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(backScafoldColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getWeatherIcon(),
                      color: iconColor,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.ville.temperature}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontFamily: family,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.ville.couverture,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: family,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.water_drop,
                      color: Colors.lightBlueAccent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Humidité: ${widget.ville.humidite}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: family,
                      ),
                    ),
                  ],
                ),
                if (widget.meteoData.containsKey('wind')) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.air,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Vent: ${widget.meteoData['wind']['speed']} m/s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: family,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Carte OpenStreetMap
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 11.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.projet_examen',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

