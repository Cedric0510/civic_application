final _emailPattern = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'L\'adresse e-mail est requise.';
  }
  if (!_emailPattern.hasMatch(value.trim())) {
    return 'Entrez une adresse e-mail valide.';
  }
  return null;
}

String? validateEmailConfirmation(String? value, String email) {
  if (value == null || value.trim().isEmpty) {
    return 'Confirmez l\'adresse e-mail.';
  }
  if (value.trim().toLowerCase() != email.trim().toLowerCase()) {
    return 'Les deux adresses e-mail ne sont pas identiques.';
  }
  return null;
}

String? validatePasswordConfirmation(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Confirmez le mot de passe.';
  }
  if (value != password) {
    return 'Les deux mots de passe ne sont pas identiques.';
  }
  return null;
}
