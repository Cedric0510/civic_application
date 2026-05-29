import 'package:civic_app/features/polls/presentation/controllers/polls_controller.dart';
import 'package:civic_app/features/polls/presentation/widgets/poll_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PollsPage extends ConsumerWidget {
  const PollsPage({super.key});

  static const Color _headerColor = Color(0xFF43A047);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pollsControllerProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: _headerColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Sondages',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 56, bottom: 12),
              background: ColoredBox(color: _headerColor),
            ),
          ),
          state.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => const SliverFillRemaining(
              child: Center(child: Text('Impossible de charger les sondages.')),
            ),
            data: (polls) => polls.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: Text('Aucun sondage disponible.')),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.builder(
                      itemCount: polls.length,
                      itemBuilder: (context, index) =>
                          PollCard(poll: polls[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
