import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/utils/location_helper.dart';
import '../reports/report_service.dart';
import '../reports/report_model.dart';
import 'map_markers.dart';
import '../../core/widgets/loading_indicator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late Future<List<Report>> _futureReports;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _futureReports = ReportService().getUnresolvedReports();
    _getLocation();
  }

  void _getLocation() async {
    final pos = await LocationHelper.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Reportes')),
      body: FutureBuilder<List<Report>>(
        future: _futureReports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar reportes'));
          }
          final reports = snapshot.data ?? [];
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _currentLocation ?? const LatLng(19.4326, -99.1332),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.urbanreport',
                  ),
                  MapMarkers(reports: reports),
                ],
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _getLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
