import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final nameController = TextEditingController(text: user?.userMetadata?['name'] ?? '');
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: user == null
          ? const Center(child: Text('No hay usuario'))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user.email ?? '',
                    decoration: const InputDecoration(labelText: 'Correo'),
                    enabled: false,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService().updateUserName(nameController.text.trim());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
                        // Refrescar el widget localmente
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: const Text('Guardar cambios'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
    );
  }
}
