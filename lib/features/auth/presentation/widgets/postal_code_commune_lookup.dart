import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/shared/utils/form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Partagé entre l'inscription et le changement de commune : les deux
// rattachent un compte par code postal plutôt qu'une liste déroulante, avec
// le même comportement en cas d'absence de correspondance -- cf.
// UnknownCommuneNotice. mapCommuneLookupError reste propre à chaque page
// pour garder ses messages d'erreur habituels.
mixin PostalCodeCommuneLookup<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool communeNotFound = false;

  String mapCommuneLookupError(Object error);

  void tellCommuneLookup(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<CommuneRef?> resolveCommuneByPostalCode(String rawPostalCode) async {
    final postalCode = rawPostalCode.trim();
    if (validatePostalCode(postalCode) != null) {
      tellCommuneLookup('Saisissez d\'abord votre code postal.');
      return null;
    }
    final List<CommuneRef> communes;
    try {
      communes = await ref.read(publicCommunesProvider.future);
    } catch (error) {
      if (mounted) tellCommuneLookup(mapCommuneLookupError(error));
      return null;
    }
    CommuneRef? match;
    for (final commune in communes) {
      if (commune.postalCode == postalCode) {
        match = commune;
        break;
      }
    }
    if (mounted) setState(() => communeNotFound = match == null);
    return match;
  }
}
