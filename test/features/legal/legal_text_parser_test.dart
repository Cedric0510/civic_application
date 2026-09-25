import 'package:civic_app/features/legal/presentation/legal_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads "## " lines as headings and the rest as paragraphs', () {
    final blocks = parseLegalText(
      '## Éditeur\n\nLa commune de Bessan.\n\n## Contact\n\nÉcrivez-nous.',
    );

    expect(blocks.map((b) => b.kind), [
      LegalBlockKind.heading,
      LegalBlockKind.paragraph,
      LegalBlockKind.heading,
      LegalBlockKind.paragraph,
    ]);
    expect(blocks.first.text, 'Éditeur');
    expect(blocks[1].text, 'La commune de Bessan.');
  });

  test('groups consecutive "- " lines into one list', () {
    final blocks = parseLegalText('- un\n- deux\n- trois');

    expect(blocks, hasLength(1));
    expect(blocks.single.kind, LegalBlockKind.bullets);
    expect(blocks.single.lines, ['un', 'deux', 'trois']);
  });

  test('keeps a paragraph written over several lines as one paragraph', () {
    final blocks = parseLegalText('Première ligne\nseconde ligne');

    expect(blocks.single.kind, LegalBlockKind.paragraph);
    expect(blocks.single.text, 'Première ligne seconde ligne');
  });

  test('accepts a heading written right above its text', () {
    final blocks = parseLegalText('## Titre\nUn texte collé.');

    expect(blocks.map((b) => b.kind), [
      LegalBlockKind.heading,
      LegalBlockKind.paragraph,
    ]);
    expect(blocks.last.text, 'Un texte collé.');
  });

  test('ignores blank input and extra empty lines', () {
    expect(parseLegalText(''), isEmpty);
    expect(parseLegalText('\n\n   \n\n'), isEmpty);
    expect(parseLegalText('Un\n\n\n\nDeux'), hasLength(2));
  });
}
