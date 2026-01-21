import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';
import '../../core/widgets/custom_input.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso, revisa tu correo para verificar tu cuenta.')),
        );
        context.go('/login');
      }
    } catch (e) {
      setState(() { _error = 'Error al registrar'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const Text('Crear cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      CustomInput(
                        label: 'Nombre',
                        controller: _nameController,
                        validator: (v) => Validators.validateNotEmpty(v, 'nombre'),
                      ),
                      CustomInput(
                        label: 'Correo',
                        controller: _emailController,
                        validator: Validators.validateEmail,
                      ),
                      CustomInput(
                        label: 'Contraseña',
                        controller: _passwordController,
                        validator: Validators.validatePassword,
                        obscureText: true,
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(_error!, style: const TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Registrarse',
                        onPressed: _register,
                        loading: _loading,
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
