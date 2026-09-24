import 'package:civic_app/features/appointments/domain/entities/appointment_request.dart';
import 'package:civic_app/features/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:civic_app/features/appointments/presentation/controllers/appointment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentController extends StateNotifier<AsyncValue<void>> {
  AppointmentController(this._useCase) : super(const AsyncData(null));

  final CreateAppointmentUseCase _useCase;

  Future<void> submit(AppointmentRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _useCase(request));
  }

  void reset() => state = const AsyncData(null);
}

final appointmentControllerProvider =
    StateNotifierProvider.autoDispose<AppointmentController, AsyncValue<void>>(
      (ref) =>
          AppointmentController(ref.read(createAppointmentUseCaseProvider)),
    );
