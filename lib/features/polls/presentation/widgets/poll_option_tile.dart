import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:flutter/material.dart';

class PollOptionTile extends StatelessWidget {
  const PollOptionTile({super.key, required this.option, required this.onTap});

  final PollOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
        child: Text(option.optionText),
      ),
    );
  }
}
