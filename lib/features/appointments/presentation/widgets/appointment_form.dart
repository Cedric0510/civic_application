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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedService;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            service: _selectedService!,
            date: _selectedDate!,
            message: _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
          ),
        );
  }

  void _reset() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _dateController.clear();
    _messageController.clear();
    setState(() {
      _selectedService = null;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue. Veuillez réessayer.'),
          ),
        );
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
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Le nom complet est requis.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Adresse e-mail',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
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
          const SizedBox(height: 16),
          ServiceDropdown(
            onChanged: (value) => setState(() => _selectedService = value),
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
