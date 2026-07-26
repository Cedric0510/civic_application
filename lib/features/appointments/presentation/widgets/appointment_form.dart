import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/presentation/controllers/appointment_controller.dart';
import 'package:civic_app/features/appointments/presentation/widgets/service_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AppointmentForm extends ConsumerStatefulWidget {
  const AppointmentForm({super.key});

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedServiceId;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _dateController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(appointmentControllerProvider.notifier)
        .submit(
          Appointment(
            serviceId: _selectedServiceId!,
            date: _selectedDate!,
            message: _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
          ),
        );
  }

  void _reset() {
    _formKey.currentState?.reset();
    _dateController.clear();
    _messageController.clear();
    setState(() {
      _selectedServiceId = null;
      _selectedDate = null;
    });
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ServiceDropdown(
            onChanged: (value) => setState(() => _selectedServiceId = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(
              labelText: 'Date souhaitée',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            validator: (_) => _selectedDate == null
                ? 'Veuillez sélectionner une date.'
                : null,
          ),
          const SizedBox(height: 16),
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
            onPressed: isLoading ? null : _submit,
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
