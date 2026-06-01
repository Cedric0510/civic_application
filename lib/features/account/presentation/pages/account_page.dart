import 'package:civic_app/core/providers/auth_provider.dart';
import 'package:civic_app/features/account/presentation/controllers/account_controller.dart';
import 'package:civic_app/features/account/presentation/controllers/account_providers.dart';
import 'package:civic_app/features/account/presentation/widgets/account_appointment_card.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  static const Color _headerColor = Color(0xFF5E35B1);

  final TextEditingController _cityController = TextEditingController();
  bool _cityInitialized = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(accountControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    final authUser = ref.watch(authStateProvider).valueOrNull;
    final profileAsync = ref.watch(userProfileProvider);
    final appointmentsAsync = ref.watch(userAppointmentsProvider);
    final controllerState = ref.watch(accountControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    profileAsync.whenData((profile) {
      if (!_cityInitialized && profile?.preferredCity != null) {
        _cityController.text = profile!.preferredCity!;
        _cityInitialized = true;
      } else if (!_cityInitialized && profile != null) {
        _cityInitialized = true;
      }
    });

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
                    _UserInfoSection(email: authUser?.email),
                    const SizedBox(height: 24),
                    _CitySection(
                      controller: _cityController,
                      isLoading: isLoading,
                      onSave: () {
                        final city = _cityController.text.trim();
                        if (city.isEmpty) return;
                        ref
                            .read(accountControllerProvider.notifier)
                            .updateCity(city);
                      },
                    ),
                    const SizedBox(height: 24),
                    _AppointmentsSection(appointmentsAsync: appointmentsAsync),
                    const SizedBox(height: 24),
                    _DangerSection(
                      isLoading: isLoading,
                      onSignOut: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                      },
                      onDeleteAccount: () => _confirmDeleteAccount(context),
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

  Future<void> _confirmDeleteAccount(BuildContext context) async {
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
    if (confirmed == true && mounted) {
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

class _CitySection extends StatelessWidget {
  const _CitySection({
    required this.controller,
    required this.isLoading,
    required this.onSave,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ma ville',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nom de votre commune',
                  hintText: 'ex: Lyon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSave(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: isLoading ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5E35B1),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
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
