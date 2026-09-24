import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/account/presentation/controllers/account_controller.dart';
import 'package:civic_app/features/account/presentation/controllers/account_providers.dart';
import 'package:civic_app/features/account/presentation/widgets/account_appointment_card.dart';
import 'package:civic_app/features/account/presentation/widgets/change_commune_dialog.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  static const Color _headerColor = Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(accountControllerProvider, (previous, next) {
      if (next is AsyncError) {
        final error = next.error;
        final message = error is AppException
            ? error.message
            : 'Une erreur est survenue. Veuillez réessayer.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    final profileAsync = ref.watch(userProfileProvider);
    final appointmentsEnabled = ref.watch(
      moduleEnabledProvider(AppModule.appointments),
    );
    final commerceEnabled = ref.watch(
      moduleEnabledProvider(AppModule.commerces),
    );
    final appointmentsAsync = appointmentsEnabled
        ? ref.watch(userAppointmentsProvider)
        : null;
    final controllerState = ref.watch(accountControllerProvider);
    final isLoading = controllerState is AsyncLoading;
    final session = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(userAppointmentsProvider);
        },
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
                  'Mon compte',
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UserInfoSection(email: profileAsync.valueOrNull?.email),
                    if (session != null) ...[
                      const SizedBox(height: 24),
                      _CommuneSection(
                        session: session,
                        isLoading: isLoading,
                        onChange: () => _changeCommune(context, ref, session),
                      ),
                    ],
                    if (appointmentsAsync != null) ...[
                      const SizedBox(height: 24),
                      _AppointmentsSection(
                        appointmentsAsync: appointmentsAsync,
                      ),
                    ],
                    if (commerceEnabled &&
                        (session?.isCommercant ?? false)) ...[
                      const SizedBox(height: 24),
                      _CommerceSection(
                        commerceName: session!.managedCommerce!.name,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _DangerSection(
                      isLoading: isLoading,
                      onSignOut: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                      },
                      onDeleteAccount: () =>
                          _confirmDeleteAccount(context, ref),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeCommune(
    BuildContext context,
    WidgetRef ref,
    CitizenSession session,
  ) async {
    final selected = await showChangeCommuneDialog(
      context,
      current: session.commune,
    );
    if (selected == null || !context.mounted) return;

    await ref
        .read(accountControllerProvider.notifier)
        .changeCommune(selected.slug);

    if (!context.mounted || ref.read(accountControllerProvider).hasError) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous êtes maintenant rattaché à ${selected.name}.'),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées. Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(accountControllerProvider.notifier).deleteAccount();
    }
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection({required this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF5E35B1).withValues(alpha: 0.15),
          child: const Icon(
            Icons.person_outline,
            size: 30,
            color: Color(0xFF5E35B1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mon profil',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email ?? '',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommuneSection extends StatelessWidget {
  const _CommuneSection({
    required this.session,
    required this.isLoading,
    required this.onChange,
  });

  final CitizenSession session;
  final bool isLoading;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ma commune',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_city_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                session.commune.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading || session.isCommercant ? null : onChange,
              child: const Text('Changer'),
            ),
          ],
        ),
        if (session.isCommercant)
          Text(
            'Un commerçant ne peut pas changer de commune : contactez votre '
            'mairie pour être détaché de votre commerce.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _AppointmentsSection extends ConsumerWidget {
  const _AppointmentsSection({required this.appointmentsAsync});

  final AsyncValue<dynamic> appointmentsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes rendez-vous',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        appointmentsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => ErrorRetryWidget(
            message: 'Impossible de charger les rendez-vous.',
            onRetry: () => ref.invalidate(userAppointmentsProvider),
          ),
          data: (appointments) {
            if (appointments == null || (appointments as List).isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Aucun rendez-vous',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: appointments
                  .map(
                    (appointment) =>
                        AccountAppointmentCard(appointment: appointment),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CommerceSection extends StatelessWidget {
  const _CommerceSection({required this.commerceName});

  final String commerceName;

  static const Color _accentColor = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mon commerce',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => context.go('/my-commerce'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined, color: _accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commerceName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Gérer les horaires, photos et notes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _accentColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DangerSection extends StatelessWidget {
  const _DangerSection({
    required this.isLoading,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final bool isLoading;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: isLoading ? null : onSignOut,
          icon: const Icon(Icons.logout_outlined),
          label: const Text('Se déconnecter'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isLoading ? null : onDeleteAccount,
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          label: Text(
            'Supprimer mon compte',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }
}
