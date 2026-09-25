enum FeedbackKind {
  problem('PROBLEME', 'Un problème'),
  idea('IDEE', 'Une idée'),
  other('AUTRE', 'Autre chose');

  const FeedbackKind(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
