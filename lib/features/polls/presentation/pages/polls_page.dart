import 'package:civic_app/features/polls/presentation/controllers/polls_controller.dart';
import 'package:civic_app/features/polls/presentation/widgets/poll_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PollsPage extends ConsumerWidget {
  const PollsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pollsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sondages')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Impossible de charger les sondages.')),
        data: (polls) => polls.isEmpty
            ? const Center(child: Text('Aucun sondage disponible.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: polls.length,
                itemBuilder: (context, index) => PollCard(poll: polls[index]),
              ),
      ),
    );
  }
}
