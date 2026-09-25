import 'package:civic_app/features/legal/presentation/legal_text_parser.dart';
import 'package:flutter/material.dart';

class LegalTextView extends StatelessWidget {
  const LegalTextView({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocks = parseLegalText(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          switch (block.kind) {
            LegalBlockKind.heading => Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 6),
              child: Semantics(
                header: true,
                child: Text(
                  block.text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            LegalBlockKind.paragraph => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(block.text, style: theme.textTheme.bodyLarge),
            ),
            LegalBlockKind.bullets => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in block.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 8),
                            child: Text('\u2022'),
                          ),
                          Expanded(
                            child: Text(line, style: theme.textTheme.bodyLarge),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          },
      ],
    );
  }
}
