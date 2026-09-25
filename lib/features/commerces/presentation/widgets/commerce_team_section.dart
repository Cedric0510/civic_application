import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';
import 'package:civic_app/features/commerces/presentation/controllers/commerce_team_controller.dart';
import 'package:civic_app/features/commerces/presentation/controllers/commerce_team_providers.dart';
import 'package:civic_app/shared/utils/form_validators.dart';
import 'package:civic_app/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommerceTeamSection extends ConsumerStatefulWidget {
  const CommerceTeamSection({super.key, required this.commerceId});

  final String commerceId;

  @override
  ConsumerState<CommerceTeamSection> createState() =>
      _CommerceTeamSectionState();
}

class _CommerceTeamSectionState extends ConsumerState<CommerceTeamSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  CommerceTeamController get _controller =>
      ref.read(commerceTeamControllerProvider(widget.commerceId).notifier);

  void _tell(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _mapError(Object error) {
    if (error is AppException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final outcome = await _controller.add(email);
    if (!mounted || outcome == null) return;
    _emailController.clear();
    _tell(
      outcome == TeamAddOutcome.linked
          ? '$email a maintenant accès à votre commerce.'
          : 'Invitation envoyée à $email. La personne créera son compte '
                'avec le code reçu par e-mail.',
    );
  }

  Future<void> _confirmRemoval(CommerceTeamMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer ce collaborateur ?'),
        content: Text(
          '${member.email} n\'aura plus accès à la gestion de votre commerce.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (await _controller.remove(member.id) && mounted) {
      _tell('${member.email} a été retiré de votre équipe.');
    }
  }

  Future<void> _cancelInvitation(CommerceInvitation invitation) async {
    if (await _controller.cancelInvitation(invitation.id) && mounted) {
      _tell('Invitation à ${invitation.email} annulée.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      commerceTeamControllerProvider(widget.commerceId),
      (previous, next) {
        if (next is AsyncError) _tell(_mapError(next.error));
      },
    );
    final busy =
        ref.watch(commerceTeamControllerProvider(widget.commerceId))
            is AsyncLoading;
    final team = ref.watch(commerceTeamProvider(widget.commerceId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Mon équipe'),
        const SizedBox(height: 4),
        Text(
          'Vous êtes le chef de ce commerce. Vos collaborateurs peuvent '
          'modifier la fiche, mais seul vous gérez l\'équipe.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        team.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Chargement de l\'équipe',
              ),
            ),
          ),
          error: (error, stackTrace) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Impossible de charger votre équipe.'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(commerceTeamProvider(widget.commerceId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
          data: (data) => _buildTeam(context, data, busy),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Adresse e-mail du collaborateur',
                  helperText:
                      'S\'il a déjà un compte City-Co, il est ajouté tout de '
                      'suite ; sinon il reçoit un code par e-mail.',
                  helperMaxLines: 3,
                  prefixIcon: Icon(Icons.person_add_alt_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: busy ? null : _add,
                child: const Text('Ajouter à l\'équipe'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeam(BuildContext context, CommerceTeam team, bool busy) {
    final localizations = MaterialLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (final member in team.members)
            ListTile(
              leading: Icon(
                member.isChief ? Icons.verified_user_outlined : Icons.person,
              ),
              title: Text(member.email),
              subtitle: member.isChief ? const Text('Chef du commerce') : null,
              trailing: member.isChief
                  ? null
                  : IconButton(
                      tooltip: 'Retirer ${member.email}',
                      icon: const Icon(Icons.person_remove_outlined),
                      onPressed: busy ? null : () => _confirmRemoval(member),
                    ),
            ),
          for (final invitation in team.invitations)
            ListTile(
              leading: const Icon(Icons.mark_email_unread_outlined),
              title: Text(invitation.email),
              subtitle: Text(
                'Invitation en attente, valable jusqu\'au '
                '${localizations.formatShortDate(invitation.expiresAt)}',
              ),
              trailing: IconButton(
                tooltip: 'Annuler l\'invitation à ${invitation.email}',
                icon: const Icon(Icons.close),
                onPressed: busy ? null : () => _cancelInvitation(invitation),
              ),
            ),
        ],
      ),
    );
  }
}
