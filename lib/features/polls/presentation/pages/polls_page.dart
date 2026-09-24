import 'package:civic_app/features/polls/presentation/controllers/polls_controller.dart';
import 'package:civic_app/features/polls/presentation/controllers/polls_providers.dart';
import 'package:civic_app/features/polls/presentation/widgets/poll_card.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PollsPage extends ConsumerWidget {
  const PollsPage({super.key});

  static const Color _headerColor = Color(0xFF43A047);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pollsControllerProvider);
    final waitingUntil = ref.watch(voteWaitingUntilProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(pollsControllerProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            if (waitingUntil != null)
              SliverToBoxAdapter(
                child: _VoteWaitingBanner(until: waitingUntil),
              ),
            state.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: ErrorRetryWidget(
                  message: 'Impossible de charger les sondages.',
                  onRetry: () => ref.invalidate(pollsControllerProvider),
                ),
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
      ),
    );
  }
}

class _VoteWaitingBanner extends StatelessWidget {
  const _VoteWaitingBanner({required this.until});

  final DateTime until;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_top_outlined,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pour éviter les votes frauduleux, vous pourrez voter à partir du '
              '${DateFormat('dd/MM/yyyy').format(until)} '
              '(une semaine après votre arrivée dans la commune).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
