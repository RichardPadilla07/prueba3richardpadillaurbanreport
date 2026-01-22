import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';
import '../../core/widgets/custom_input.dart';
import '../../core/widgets/custom_button.dart';
import '../../modules/reports/report_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  int _reportCount = 0;
  bool _loading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _nameController.text = user?.userMetadata?['name'] ?? '';
    _loadReportCount();
    // Start periodic refresh of the report count (every 30 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadReportCount();
    });
  }

  Future<void> _loadReportCount() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final reports = await ReportService().getUserReports(user.id);
      if (mounted) setState(() => _reportCount = reports.length);
    } catch (_) {
      // ignore errors for now
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    await AuthService().updateUserName(name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
    setState(() {});
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: user == null
          ? const Center(child: Text('No hay usuario'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (user.userMetadata?['name'] ?? user.email ?? 'U').toString().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nombre', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                            const SizedBox(height: 6),
                            CustomInput(label: 'Nombre', controller: _nameController),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Correo', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                  const SizedBox(height: 6),
                  Text(user.email ?? '', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(text: 'Guardar cambios', onPressed: _saveName, loading: false, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(text: 'Cerrar sesión', onPressed: _signOut, loading: false, color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reportes creados', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                      _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : Text('$_reportCount', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('El contador refleja los reportes que has creado. Usa actualizar para sincronizar.', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  CustomButton(text: 'Actualizar', onPressed: _loadReportCount, loading: false),
                ],
              ),
            ),
    );
  }
}
