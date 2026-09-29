class PasswordValidator {
  static String? validate(String password) {
    if (password.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(password))
      return 'Password harus ada huruf besar';
    if (!RegExp(r'[a-z]').hasMatch(password))
      return 'Password harus ada huruf kecil';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Password harus ada angka';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\];/\\]').hasMatch(password)) {
      return 'Password harus ada simbol (!@#\$% dst)';
    }
    return null;
  }
}
