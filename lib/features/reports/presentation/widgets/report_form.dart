import 'package:cross_file/cross_file.dart';

import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/features/reports/presentation/controllers/my_reports_controller.dart';
import 'package:civic_app/features/reports/presentation/controllers/report_controller.dart';
import 'package:civic_app/features/reports/presentation/widgets/report_category_dropdown.dart';
import 'package:civic_app/shared/widgets/photo_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportForm extends ConsumerStatefulWidget {
  const ReportForm({super.key});

  @override
  ConsumerState<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReportCategory? _selectedCategory;
  XFile? _photo;

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(reportControllerProvider.notifier)
        .submit(
          Report(
            address: _addressController.text.trim(),
            category: _selectedCategory!,
            description: _descriptionController.text.trim(),
          ),
          photo: _photo,
        );
  }

  void _reset() {
    _formKey.currentState?.reset();
    _addressController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _photo = null;
    });
    ref.read(reportControllerProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(reportControllerProvider, (previous, next) {
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
          const SnackBar(content: Text('Signalement envoyé avec succès !')),
        );
        ref.invalidate(myReportsControllerProvider);
        _reset();
      }
    });

    final isLoading = ref.watch(reportControllerProvider).isLoading;

    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ce signalement sera associé à votre compte.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              border: OutlineInputBorder(),
              hintText: 'ex. 12 rue de la Mairie',
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Veuillez indiquer une adresse.'
                : null,
          ),
          const SizedBox(height: 16),
          ReportCategoryDropdown(
            value: _selectedCategory,
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description du problème',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Veuillez décrire le problème.'
                : null,
          ),
          const SizedBox(height: 16),
          PhotoField(
            photo: _photo,
            onChanged: (file) => setState(() => _photo = file),
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
                : const Text('Envoyer le signalement'),
          ),
        ],
      ),
    );
  }
}
