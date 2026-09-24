import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTappable = onTap != null;

    final content = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isTappable ? colorScheme.primary : Colors.grey.shade500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isTappable ? colorScheme.primary : null,
                decoration: isTappable ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );

    if (!isTappable) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
