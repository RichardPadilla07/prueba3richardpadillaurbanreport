import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_input.dart';
import '../../core/widgets/custom_button.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? code;
  const ResetPasswordPage({super.key, this.code});

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
    // Try code provided by router (state) first, then fallback to Uri.base (web)
    final providedCode = widget.code ?? Uri.base.queryParameters['code'] ?? Uri.base.queryParameters['access_token'] ?? Uri.base.queryParameters['token'];
    if (providedCode == null || providedCode.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Enlace inválido o expirado.')),
      );
    }
    return Scaffold(
      // No AppBar for this screen (user requested to remove top title/background)
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
                      const Text('Nueva contraseña', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 24),
                      CustomInput(
                        label: 'Contraseña',
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 16),
                      // Centered primary action with our CustomButton style
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Actualizar contraseña',
                                onPressed: _resetPassword,
                                loading: _loading,
                              ),
                            ),
                          ),
                        ],
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
