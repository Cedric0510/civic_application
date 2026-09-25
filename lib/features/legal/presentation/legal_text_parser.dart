enum LegalBlockKind { heading, paragraph, bullets }

class LegalBlock {
  const LegalBlock(this.kind, this.lines);

  final LegalBlockKind kind;
  final List<String> lines;

  String get text => lines.join('\n');
}

List<LegalBlock> parseLegalText(String text) {
  final blocks = <LegalBlock>[];
  for (final raw in text.split(RegExp(r'\n\s*\n'))) {
    final block = raw.trim();
    if (block.isEmpty) continue;
    if (block.startsWith('## ')) {
      final lines = block.split('\n');
      blocks.add(
        LegalBlock(LegalBlockKind.heading, [lines.first.substring(3).trim()]),
      );
      final rest = lines.skip(1).join('\n').trim();
      if (rest.isNotEmpty) blocks.addAll(parseLegalText(rest));
      continue;
    }
    final lines = block.split('\n').map((line) => line.trim()).toList();
    if (lines.every((line) => line.startsWith('- '))) {
      blocks.add(
        LegalBlock(
          LegalBlockKind.bullets,
          lines.map((line) => line.substring(2).trim()).toList(),
        ),
      );
    } else {
      blocks.add(LegalBlock(LegalBlockKind.paragraph, [lines.join(' ')]));
    }
  }
  return blocks;
}
