import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:civic_app/features/legal/presentation/controllers/legal_providers.dart';
import 'package:civic_app/features/legal/presentation/widgets/legal_text_view.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LegalPage extends ConsumerWidget {
  const LegalPage({super.key, required this.document, this.communeSlug});

  final LegalDocument document;
  final String? communeSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slug =
        communeSlug ?? ref.watch(authStateProvider).valueOrNull?.commune.slug;

    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: slug == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Choisissez d\'abord une commune.'),
                ),
              )
            : ref
                  .watch(legalTextsProvider(slug))
                  .when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Chargement en cours',
                      ),
                    ),
                    error: (error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: ErrorRetryWidget(
                        message: 'Impossible de charger ce document.',
                        onRetry: () => ref.invalidate(legalTextsProvider(slug)),
                      ),
                    ),
                    data: (texts) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                texts.communeName,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              LegalTextView(text: texts.textOf(document)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
