import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FarmerMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;

  const FarmerMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final location = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: location,
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ayurtrace.ui_playground',
            ),

            MarkerLayer(
              markers: [
                Marker(
                  point: location,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.location_pin,
                    size: 50,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}