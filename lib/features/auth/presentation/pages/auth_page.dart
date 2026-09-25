import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/accessibility/presentation/widgets/comfort_mode_tile.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:civic_app/features/auth/presentation/widgets/commune_picker_field.dart';
import 'package:civic_app/features/auth/presentation/widgets/terms_consent_field.dart';
import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:civic_app/shared/utils/form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailConfirmationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _invitationCodeController = TextEditingController();
  bool _isSignUp = false;
  bool _hasInvitationCode = false;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  CommuneRef? _selectedCommune;

  @override
  void dispose() {
    _emailController.dispose();
    _emailConfirmationController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _invitationCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (_isSignUp) {
      await ref
          .read(authControllerProvider.notifier)
          .signUp(
            email: email,
            password: password,
            communeSlug: _selectedCommune!.slug,
            acceptedTerms: _acceptedTerms,
            invitationCode: _hasInvitationCode
                ? _invitationCodeController.text
                : null,
          );
    } else {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(email: email, password: password);
    }
  }

  void _openLegalDocument(LegalDocument document) {
    final commune = _selectedCommune;
    if (commune == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choisissez d\'abord votre commune pour lire ce texte.',
          ),
        ),
      );
      return;
    }
    context.push(
      Uri(
        path: '/legal/${document.routeSegment}',
        queryParameters: {'commune': commune.slug},
      ).toString(),
    );
  }

  void _openForgotPassword() {
    final email = _emailController.text.trim();
    context.go(
      Uri(
        path: '/forgot-password',
        queryParameters: email.isEmpty ? null : {'email': email},
      ).toString(),
    );
  }

  // civic_api renvoie déjà des messages exploitables en français.
  String _mapError(Object error) {
    if (error is AppException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AuthBrand(),
                  const SizedBox(height: 16),
                  const ComfortModeTile(),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isSignUp ? 'Créer un compte' : 'Connexion',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isSignUp
                                  ? 'Créez votre accès citoyen sécurisé.'
                                  : 'Accédez à vos services municipaux.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Adresse e-mail',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              validator: validateEmail,
                            ),
                            if (_isSignUp) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailConfirmationController,
                                decoration: const InputDecoration(
                                  labelText: 'Confirmer l\'adresse e-mail',
                                  prefixIcon: Icon(
                                    Icons.mark_email_read_outlined,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                validator: (value) => validateEmailConfirmation(
                                  value,
                                  _emailController.text,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
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
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Le mot de passe est requis.';
                                }
                                if (_isSignUp && value.length < 8) {
                                  return 'Le mot de passe doit contenir au moins 8 caractères.';
                                }
                                return null;
                              },
                            ),
                            if (_isSignUp) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordConfirmationController,
                                decoration: const InputDecoration(
                                  labelText: 'Confirmer le mot de passe',
                                  prefixIcon: Icon(Icons.lock_reset_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) =>
                                    validatePasswordConfirmation(
                                      value,
                                      _passwordController.text,
                                    ),
                              ),
                            ],
                            if (!_isSignUp)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : _openForgotPassword,
                                  child: const Text('Mot de passe oublié ?'),
                                ),
                              ),
                            if (_isSignUp) ...[
                              const SizedBox(height: 16),
                              CommunePickerField(
                                value: _selectedCommune,
                                onChanged: (commune) =>
                                    setState(() => _selectedCommune = commune),
                              ),
                              const SizedBox(height: 4),
                              if (_hasInvitationCode) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _invitationCodeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Code d\'invitation',
                                    helperText:
                                        'Reçu par e-mail de votre mairie pour gérer un commerce.',
                                    helperMaxLines: 2,
                                    prefixIcon: Icon(Icons.storefront_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  autocorrect: false,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Saisissez le code reçu par e-mail.';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => setState(() {
                                          _hasInvitationCode =
                                              !_hasInvitationCode;
                                          _invitationCodeController.clear();
                                        }),
                                  child: Text(
                                    _hasInvitationCode
                                        ? 'Je n\'ai pas de code d\'invitation'
                                        : 'J\'ai un code d\'invitation commerçant',
                                  ),
                                ),
                              ),
                            ],
                            if (_isSignUp) ...[
                              const SizedBox(height: 8),
                              TermsConsentField(
                                accepted: _acceptedTerms,
                                onChanged: (value) =>
                                    setState(() => _acceptedTerms = value),
                                onOpenDocument: _openLegalDocument,
                              ),
                            ],
                            const SizedBox(height: 28),
                            FilledButton(
                              onPressed: isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                  : Text(
                                      _isSignUp
                                          ? 'Créer un compte'
                                          : 'Se connecter',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => setState(() {
                                      _isSignUp = !_isSignUp;
                                      _emailConfirmationController.clear();
                                      _passwordConfirmationController.clear();
                                    }),
                              child: Text(
                                _isSignUp
                                    ? 'Déjà un compte ? Se connecter'
                                    : 'Pas encore de compte ? S\'inscrire',
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Vos données sont utilisées uniquement pour '
                              'l\'authentification et ne sont pas partagées '
                              'avec des tiers, conformément au RGPD.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  semanticLabel: 'City-Co',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Votre commune, simplement',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Actualités, démarches et services municipaux au même endroit.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
