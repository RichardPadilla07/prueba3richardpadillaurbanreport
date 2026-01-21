import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../reports/report_model.dart';

class MapMarkers extends StatelessWidget {
  final List<Report> reports;
  const MapMarkers({super.key, required this.reports});

  Color _getColor(String categoria) {
    switch (categoria) {
      case 'bache': return Colors.orange;
      case 'luminaria': return Colors.yellow;
      case 'basura': return Colors.green;
      case 'alcantarilla': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: reports.map((r) => Marker(
        point: LatLng(r.latitud, r.longitud),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            context.push('/detail', extra: r);
          },
          child: Icon(Icons.location_on, color: _getColor(r.categoria), size: 36),
        ),
      )).toList(),
    );
  }
}
