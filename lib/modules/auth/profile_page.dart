import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: user == null
          ? const Center(child: Text('No hay usuario'))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${user.userMetadata?['name'] ?? ''}'),
                  Text('Correo: ${user.email ?? ''}'),
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
