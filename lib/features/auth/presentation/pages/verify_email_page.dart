import 'dart:async';

import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({
    super.key,
    required this.email,
    this.resendAvailableAt,
  });

  final String email;
  final DateTime? resendAvailableAt;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Timer? _ticker;
  late DateTime? _resendAvailableAt = widget.resendAvailableAt;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _secondsBeforeResend > 0) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  int get _secondsBeforeResend {
    final available = _resendAvailableAt;
    if (available == null) return 0;
    final remaining = available.difference(DateTime.now()).inSeconds + 1;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .verifySignUp(email: widget.email, code: _codeController.text.trim());
  }

  Future<void> _resend() async {
    final sent = await ref
        .read(authControllerProvider.notifier)
        .resendSignUpCode(email: widget.email);
    if (!mounted || sent == null) return;
    setState(() => _resendAvailableAt = sent.resendAvailableAt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Un nouveau code vient d\'être envoyé à ${widget.email}.',
        ),
      ),
    );
  }

  String _mapError(Object error) {
    if (error is AppException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  String? _validateCode(String? value) {
    final code = (value ?? '').replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (code.isEmpty) return 'Saisissez le code reçu par e-mail.';
    if (code.length < 8) return 'Le code contient 8 caractères.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_mapError(next.error))));
      }
    });

    final isLoading = ref.watch(authControllerProvider) is AsyncLoading;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final wait = _secondsBeforeResend;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification de l\'adresse'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Modifier mon inscription',
          onPressed: () => context.go('/auth'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      size: 56,
                      color: colorScheme.primary,
                      semanticLabel: 'E-mail envoyé',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nous avons envoyé un code à',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saisissez-le pour créer votre compte. Il est valable '
                      '30 minutes. Pensez à regarder vos courriers '
                      'indésirables.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Code de vérification',
                        hintText: 'XXXX-XXXX',
                        prefixIcon: Icon(Icons.pin_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      validator: _validateCode,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _verify,
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
                          : const Text('Valider mon adresse'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: isLoading || wait > 0 ? null : _resend,
                      child: Text(
                        wait > 0
                            ? 'Renvoyer le code (dans $wait s)'
                            : 'Renvoyer le code',
                      ),
                    ),
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
