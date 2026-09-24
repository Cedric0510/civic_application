import 'package:civic_app/core/routing/app_redirect.dart';
import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('moduleForLocation', () {
    test('maps each module root to its module', () {
      expect(moduleForLocation('/articles'), AppModule.articles);
      expect(moduleForLocation('/polls'), AppModule.polls);
      expect(moduleForLocation('/services'), AppModule.services);
      expect(moduleForLocation('/appointments'), AppModule.appointments);
      expect(moduleForLocation('/commerces'), AppModule.commerces);
      expect(moduleForLocation('/reports'), AppModule.reports);
      expect(moduleForLocation('/weather'), AppModule.weather);
    });

    test('a commerce owner space belongs to the commerces module', () {
      expect(moduleForLocation('/my-commerce'), AppModule.commerces);
    });

    test('nested routes belong to the module of their root', () {
      expect(moduleForLocation('/articles/42'), AppModule.articles);
    });

    test('home, account and auth belong to no module', () {
      expect(moduleForLocation('/home'), isNull);
      expect(moduleForLocation('/account'), isNull);
      expect(moduleForLocation('/auth'), isNull);
      expect(moduleForLocation('/'), isNull);
    });
  });

  group('resolveRedirect', () {
    String? redirect(
      String location, {
      bool isAuthenticated = true,
      Set<AppModule> disabled = const {},
    }) => resolveRedirect(
      isAuthenticated: isAuthenticated,
      location: location,
      disabledModules: disabled,
    );

    test('lets an authenticated citizen reach an enabled module', () {
      expect(redirect('/polls'), isNull);
      expect(redirect('/articles/42', disabled: {AppModule.polls}), isNull);
    });

    test('sends a citizen away from a disabled module to the home page', () {
      expect(redirect('/polls', disabled: {AppModule.polls}), '/home');
      expect(redirect('/articles/42', disabled: {AppModule.articles}), '/home');
      expect(
        redirect('/my-commerce', disabled: {AppModule.commerces}),
        '/home',
      );
    });

    test('never blocks home or account, whatever is disabled', () {
      final everything = AppModule.values.toSet();
      expect(redirect('/home', disabled: everything), isNull);
      expect(redirect('/account', disabled: everything), isNull);
    });

    test('keeps requiring an account everywhere but on /auth', () {
      expect(redirect('/polls', isAuthenticated: false), '/auth');
      expect(redirect('/home', isAuthenticated: false), '/auth');
      expect(redirect('/auth', isAuthenticated: false), isNull);
    });

    test('sends a signed-in citizen away from /auth', () {
      expect(redirect('/auth'), '/home');
    });
  });
}
