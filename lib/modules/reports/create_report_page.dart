import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'report_service.dart';
import 'report_model.dart';
import '../../core/widgets/custom_input.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/image_helper.dart';
import '../../core/utils/storage_helper.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateReportPage extends StatefulWidget {
  final Report? reportToEdit;
  const CreateReportPage({super.key, this.reportToEdit});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _categoria = AppConstants.categories.first;
  String? _fotoUrl;
  double? _lat;
  double? _lng;
  bool _loading = false;
  String? _error;
  bool get isEdit => widget.reportToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final r = widget.reportToEdit!;
      _tituloController.text = r.titulo;
      _descripcionController.text = r.descripcion;
      _categoria = r.categoria;
      _fotoUrl = r.fotoUrl;
      _lat = r.latitud;
      _lng = r.longitud;
    }
  }

  void _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initial: _lat != null && _lng != null ? LatLng(_lat!, _lng!) : null,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
      });
    }
  }

  void _pickImage() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(ctx);
                final xfile = await ImageHelper.pickImageFromCamera();
                if (xfile != null) {
                  final url = await StorageHelper.uploadImage(xfile, user.id);
                  if (url != null) setState(() => _fotoUrl = url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(ctx);
                final xfile = await ImageHelper.pickImageFromGallery();
                if (xfile != null) {
                  final url = await StorageHelper.uploadImage(xfile, user.id);
                  if (url != null) setState(() => _fotoUrl = url);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _lat == null || _lng == null || _fotoUrl == null) {
      setState(() { _error = 'Completa todos los campos y selecciona ubicación/foto.'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos y selecciona ubicación/foto.'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No autenticado');
      if (isEdit) {
        final report = widget.reportToEdit!.copyWith(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          categoria: _categoria,
          latitud: _lat!,
          longitud: _lng!,
          fotoUrl: _fotoUrl!,
        );
        await ReportService().updateReport(report);
      } else {
        final report = Report(
          id: '',
          usuarioId: user.id,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          categoria: _categoria,
          estado: 'pendiente',
          latitud: _lat!,
          longitud: _lng!,
          fotoUrl: _fotoUrl!,
          createdAt: DateTime.now(),
        );
        await ReportService().createReport(report);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Reporte actualizado' : 'Reporte creado')),
        );
        // Volver a la pantalla anterior indicando que hubo cambios
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() { _error = isEdit ? 'Error al editar reporte' : 'Error al crear reporte'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Error al editar reporte' : 'Error al crear reporte'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Reporte' : 'Nuevo Reporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CustomInput(
                    label: 'Título',
                    controller: _tituloController,
                    validator: (v) => Validators.validateNotEmpty(v, 'título'),
                  ),
                  CustomInput(
                    label: 'Descripción',
                    controller: _descripcionController,
                    validator: (v) => Validators.validateNotEmpty(v, 'descripción'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    items: AppConstants.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _categoria = v!),
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickLocation,
                          child: Text(_lat == null ? 'Seleccionar ubicación' : 'Ubicación seleccionada'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          child: Text(_fotoUrl == null ? 'Seleccionar foto' : 'Foto seleccionada'),
                        ),
                      ),
                    ],
                  ),
                  if (_fotoUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Image.network(_fotoUrl!, height: 180),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: isEdit ? 'Guardar cambios' : 'Crear reporte',
                    onPressed: _submit,
                    loading: _loading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para seleccionar ubicación en el mapa (clase separada al nivel superior)
class LocationPickerPage extends StatefulWidget {
  final LatLng? initial;
  const LocationPickerPage({super.key, this.initial});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona ubicación')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selected ?? const LatLng(19.4326, -99.1332),
          initialZoom: 15,
          onTap: (tapPos, latlng) {
            setState(() => _selected = latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.urbanreport',
          ),
          if (_selected != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selected!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selected == null ? null : () => Navigator.of(context).pop(_selected),
        label: const Text('Usar ubicación'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
