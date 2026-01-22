import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  
  StreamSubscription? _reportsSub;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _nameController.text = user?.userMetadata?['name'] ?? '';
    _loadReportCount();
    // Subscribe to realtime changes for this user's reports
    if (user != null) {
      _reportsSub = Supabase.instance.client
          .from('reports')
          .stream(primaryKey: ['id'])
          .eq('usuario_id', user.id)
          .listen((data) {
        if (!mounted) return;
        // data is a List of maps representing current rows for this filter
        try {
          setState(() => _reportCount = (data as List).length);
        } catch (_) {}
      });
    }
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
    _reportsSub?.cancel();
    
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
                  LayoutBuilder(builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 500;
                    final avatar = CircleAvatar(
                      radius: 36,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        (user.userMetadata?['name'] ?? user.email ?? 'U').toString().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );

                    final reportCard = Column(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                            child: Column(
                              children: [
                                Text('Reportes', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                                const SizedBox(height: 6),
                                _loading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                                    : Text('$_reportCount', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            text: 'Actualizar',
                            onPressed: _loadReportCount,
                            loading: _loading,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    );

                    if (isSmall) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              avatar,
                              const SizedBox(width: 12),
                              reportCard,
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Nombre', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                          ),
                          const SizedBox(height: 6),
                          CustomInput(label: 'Nombre', controller: _nameController),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(text: 'Guardar cambios', onPressed: _saveName, loading: false, color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      );
                    }

                    // Large layout (desktop/tablet)
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        avatar,
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nombre', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                              const SizedBox(height: 6),
                              CustomInput(label: 'Nombre', controller: _nameController),
                              const SizedBox(height: 8),
                              // Save button placed near the top for quick access
                              SizedBox(
                                width: double.infinity,
                                child: CustomButton(text: 'Guardar cambios', onPressed: _saveName, loading: false, color: Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        reportCard,
                      ],
                    );
                  }),
                  const SizedBox(height: 18),
                  Text('Correo', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                  const SizedBox(height: 6),
                  Text(user.email ?? '', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 28),
                  // Logout button at the bottom for clear separation
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(text: 'Cerrar sesión', onPressed: _signOut, loading: false, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}
