// preferredCity a disparu : le citoyen est maintenant rattaché à une vraie
// commune dès l'inscription (communeId côté civic_api), plus un nom de ville
// tapé librement — cf. docs/ROADMAP.md.
class UserProfile {
  const UserProfile({required this.id, required this.email});

  final String id;
  final String email;
}
