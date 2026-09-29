import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_request.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';
import 'package:civic_app/features/appointments/domain/entities/slots_query.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:civic_app/features/appointments/presentation/controllers/appointment_providers.dart';
import 'package:civic_app/features/appointments/presentation/widgets/appointment_form.dart';
import 'package:civic_app/features/services/domain/entities/service.dart';
import 'package:civic_app/features/services/domain/repositories/service_repository.dart';
import 'package:civic_app/features/services/domain/usecases/get_services_usecase.dart';
import 'package:civic_app/features/services/presentation/controllers/services_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAppointmentRepository implements AppointmentRepository {
  AppointmentRequest? received;

  @override
  Future<void> createAppointment(AppointmentRequest request) async {
    received = request;
  }

  @override
  Future<List<Appointment>> getMyAppointments() async => [];

  @override
  Future<List<AppointmentSlot>> getSlots(SlotsQuery query) async => [];
}

Widget _wrap() {
  return ProviderScope(
    overrides: [
      appointmentRepositoryProvider.overrideWithValue(
        _FakeAppointmentRepository(),
      ),
      getServicesUseCaseProvider.overrideWithValue(
        GetServicesUseCase(_NoServiceRepository()),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: AppointmentForm()),
    ),
  );
}

class _NoServiceRepository implements ServiceRepository {
  @override
  Future<List<Service>> getServices() async => [];
}

void main() {
  testWidgets('rejects an empty visitor name', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    final state = tester.state<FormFieldState<String>>(
      find.byKey(const Key('visitorNameField')),
    );

    expect(state.validate(), isFalse);
    await tester.pump();
    expect(find.text('Le nom est requis.'), findsOneWidget);
  });

  testWidgets('accepts a filled-in visitor name', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('visitorNameField')),
      'Jeanne Dupont',
    );
    final state = tester.state<FormFieldState<String>>(
      find.byKey(const Key('visitorNameField')),
    );

    expect(state.validate(), isTrue);
  });
}
