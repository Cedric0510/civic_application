import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_request.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';
import 'package:civic_app/features/appointments/presentation/controllers/appointment_controller.dart';
import 'package:civic_app/features/appointments/presentation/controllers/appointment_providers.dart';
import 'package:civic_app/features/appointments/presentation/widgets/service_dropdown.dart';
import 'package:civic_app/features/appointments/presentation/widgets/slot_picker.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentForm extends ConsumerStatefulWidget {
  const AppointmentForm({super.key});

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String? _selectedServiceId;
  AppointmentSlot? _selectedSlot;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedSlot == null) return;
    await ref
        .read(appointmentControllerProvider.notifier)
        .submit(
          AppointmentRequest(
            serviceId: _selectedServiceId!,
            startsAt: _selectedSlot!.startsAt,
            message: _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
          ),
        );
  }

  void _refreshSlots() {
    if (_selectedServiceId != null) {
      ref.invalidate(appointmentSlotsProvider(_selectedServiceId!));
    }
    setState(() => _selectedSlot = null);
  }

  void _reset() {
    _refreshSlots();
    _formKey.currentState?.reset();
    _messageController.clear();
    setState(() => _selectedServiceId = null);
    ref.read(appointmentControllerProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(appointmentControllerProvider, (
      previous,
      next,
    ) {
      if (next is AsyncError) {
        final error = next.error;
        final message = error is AppException
            ? error.message
            : 'Une erreur est survenue. Veuillez réessayer.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        _refreshSlots();
      } else if (next is AsyncData && previous is AsyncLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande de rendez-vous envoyée avec succès !'),
          ),
        );
        _reset();
      }
    });

    final isLoading = ref.watch(appointmentControllerProvider).isLoading;
    final serviceId = _selectedServiceId;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ServiceDropdown(
            onChanged: (value) => setState(() {
              _selectedServiceId = value;
              _selectedSlot = null;
            }),
          ),
          if (serviceId != null) ...[
            const SizedBox(height: 20),
            ref
                .watch(appointmentSlotsProvider(serviceId))
                .when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) => ErrorRetryWidget(
                    message: 'Impossible de charger les créneaux.',
                    onRetry: () =>
                        ref.invalidate(appointmentSlotsProvider(serviceId)),
                  ),
                  data: (slots) => SlotPicker(
                    slots: slots,
                    selected: _selectedSlot,
                    onSelected: (slot) => setState(() => _selectedSlot = slot),
                  ),
                ),
          ],
          const SizedBox(height: 20),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message (facultatif)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isLoading || _selectedSlot == null ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Prendre rendez-vous'),
          ),
        ],
      ),
    );
  }
}
