import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/auth/presentation/controllers/password_reset_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  static const int _minPasswordLength = 8;

  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _codeRequested = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  Future<void> _requestCode({bool resend = false}) async {
    if (!resend && !_emailFormKey.currentState!.validate()) return;
    final sent = await ref
        .read(passwordResetControllerProvider.notifier)
        .requestCode(email: _email);
    if (!mounted || !sent) return;
    setState(() => _codeRequested = true);
    if (resend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Code renvoyé si un compte existe. Pensez à vérifier vos courriers indésirables.',
          ),
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    final done = await ref
        .read(passwordResetControllerProvider.notifier)
        .resetPassword(
          email: _email,
          code: _codeController.text.trim(),
          newPassword: _passwordController.text,
        );
    if (!mounted || !done) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mot de passe modifié. Connectez-vous avec le nouveau.'),
      ),
    );
    context.go('/auth');
  }

  String _mapError(Object error) {
    if (error is AppException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(passwordResetControllerProvider, (
      previous,
      next,
    ) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_mapError(next.error))));
      }
    });

    final isLoading =
        ref.watch(passwordResetControllerProvider) is AsyncLoading;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour à la connexion',
          onPressed: () => context.go('/auth'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _codeRequested
                  ? _buildResetStep(textTheme, colorScheme, isLoading)
                  : _buildEmailStep(textTheme, colorScheme, isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isLoading,
  ) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Saisissez l\'adresse e-mail de votre compte. Nous vous enverrons '
            'un code valable 30 minutes pour choisir un nouveau mot de passe.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Adresse e-mail',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'adresse e-mail est requise.';
              }
              final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Entrez une adresse e-mail valide.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isLoading ? null : _requestCode,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoading
                ? const _ButtonSpinner()
                : const Text('Envoyer le code'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep(
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isLoading,
  ) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Si un compte existe pour $_email, un code vient de lui être '
            'envoyé. Il est valable 30 minutes.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Code reçu par e-mail',
              prefixIcon: Icon(Icons.pin_outlined),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Saisissez le code reçu par e-mail.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Nouveau mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'Afficher le mot de passe'
                    : 'Masquer le mot de passe',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.length < _minPasswordLength) {
                return 'Le mot de passe doit contenir au moins '
                    '$_minPasswordLength caractères.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmController,
            decoration: const InputDecoration(
              labelText: 'Confirmer le mot de passe',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Les deux mots de passe ne correspondent pas.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isLoading ? null : _resetPassword,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoading
                ? const _ButtonSpinner()
                : const Text('Changer le mot de passe'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: isLoading ? null : () => _requestCode(resend: true),
            child: const Text('Renvoyer un code'),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () => setState(() => _codeRequested = false),
            child: const Text('Changer d\'adresse e-mail'),
          ),
        ],
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        semanticsLabel: 'Chargement en cours',
        strokeWidth: 2,
      ),
    );
  }
}
