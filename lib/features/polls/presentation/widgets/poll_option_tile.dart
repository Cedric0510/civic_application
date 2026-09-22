import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:flutter/material.dart';

class PollOptionTile extends StatelessWidget {
  const PollOptionTile({
    super.key,
    required this.option,
    required this.onTap,
    this.enabled = true,
  });

  final PollOption option;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
        child: Text(option.optionText),
      ),
    );
  }
}
