import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    // No desloguear aquí, para mantener la sesión de recuperación activa
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _message = null; });
    try {
      final resp = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );
      if (resp.user != null) {
        setState(() { _message = 'Contraseña actualizada. Redirigiendo al inicio de sesión...'; });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // Usar GoRouter para redirigir
          context.go('/login');
        }
      } else {
        setState(() { _message = 'Error al actualizar contraseña.'; });
      }
    } catch (e) {
      setState(() { _message = 'Error al actualizar contraseña.'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Enlace inválido o expirado.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Nueva contraseña', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Contraseña'),
                        validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _resetPassword,
                        child: _loading ? const CircularProgressIndicator() : const Text('Actualizar contraseña'),
                      ),
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(_message!, style: TextStyle(color: _message!.contains('actualizada') ? Colors.green : Colors.red)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
