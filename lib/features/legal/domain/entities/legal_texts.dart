import 'package:equatable/equatable.dart';

enum LegalDocument {
  notice('notice', 'Mentions légales'),
  privacy('privacy', 'Politique de confidentialité');

  const LegalDocument(this.routeSegment, this.title);

  final String routeSegment;
  final String title;

  static LegalDocument? fromRouteSegment(String segment) {
    for (final document in values) {
      if (document.routeSegment == segment) return document;
    }
    return null;
  }
}

class LegalTexts extends Equatable {
  const LegalTexts({
    required this.communeName,
    required this.legalNotice,
    required this.privacyPolicy,
  });

  final String communeName;
  final String legalNotice;
  final String privacyPolicy;

  String textOf(LegalDocument document) => switch (document) {
    LegalDocument.notice => legalNotice,
    LegalDocument.privacy => privacyPolicy,
  };

  @override
  List<Object?> get props => [communeName, legalNotice, privacyPolicy];
}
