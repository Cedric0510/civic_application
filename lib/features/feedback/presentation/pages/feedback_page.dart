import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/feedback/domain/entities/feedback_kind.dart';
import 'package:civic_app/features/feedback/presentation/controllers/feedback_controller.dart';
import 'package:civic_app/features/feedback/presentation/widgets/star_rating_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  int? _rating;
  FeedbackKind _kind = FeedbackKind.idea;
  bool _contactAllowed = false;
  bool _sent = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final sent = await ref
        .read(feedbackControllerProvider.notifier)
        .send(
          rating: _rating!,
          kind: _kind,
          message: _messageController.text.trim(),
          contactAllowed: _contactAllowed,
        );
    if (mounted && sent) setState(() => _sent = true);
  }

  String _mapError(Object error) {
    if (error is AppException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(feedbackControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_mapError(next.error))));
      }
    });
    final isLoading = ref.watch(feedbackControllerProvider) is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre avis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _sent ? _buildThanks(context) : _buildForm(isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThanks(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.favorite_rounded,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Merci pour votre avis !',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Il nous aide à améliorer l\'application pour tous les habitants.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go('/home'),
          child: const Text('Retour à l\'accueil'),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLoading) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Que pensez-vous de City-Co ?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vos remarques sont lues par votre mairie et par l\'équipe '
            'City-Co.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text('Votre note', style: theme.textTheme.titleSmall),
          StarRatingField(onChanged: (value) => _rating = value),
          const SizedBox(height: 16),
          Text('C\'est plutôt…', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in FeedbackKind.values)
                ChoiceChip(
                  label: Text(kind.label),
                  selected: _kind == kind,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Votre message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            minLines: 4,
            maxLines: 8,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return 'Écrivez quelques mots pour nous aider.';
              }
              return null;
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vous pouvez me recontacter par e-mail'),
            subtitle: const Text(
              'Sans cela, votre adresse reste invisible pour la mairie.',
            ),
            value: _contactAllowed,
            onChanged: (value) => setState(() => _contactAllowed = value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Chargement en cours',
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Envoyer mon avis'),
          ),
        ],
      ),
    );
  }
}
