// Validators for forms
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese un correo';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese una contraseña';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? validateNotEmpty(String? value, String field) {
    if (value == null || value.isEmpty) return 'Ingrese $field';
    return null;
  }
}
