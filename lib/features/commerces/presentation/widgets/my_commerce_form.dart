import 'dart:io';

import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/presentation/controllers/my_commerce_controller.dart';
import 'package:civic_app/features/commerces/presentation/widgets/commerce_photo_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyCommerceForm extends ConsumerStatefulWidget {
  const MyCommerceForm({super.key, required this.commerce});

  final Commerce commerce;

  @override
  ConsumerState<MyCommerceForm> createState() => _MyCommerceFormState();
}

class _MyCommerceFormState extends ConsumerState<MyCommerceForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.commerce.name);
  late final _categoryController = TextEditingController(
    text: widget.commerce.category ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.commerce.description ?? '',
  );
  late final _emailController = TextEditingController(
    text: widget.commerce.email ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.commerce.phone ?? '',
  );
  late final _addressController = TextEditingController(
    text: widget.commerce.address ?? '',
  );
  late final _hoursController = TextEditingController(
    text: widget.commerce.hours ?? '',
  );
  late final _notesController = TextEditingController(
    text: widget.commerce.notes ?? '',
  );
  File? _photo;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _orNull(String text) => text.trim().isEmpty ? null : text.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(myCommerceControllerProvider.notifier)
        .save(
          Commerce(
            id: widget.commerce.id,
            name: _nameController.text.trim(),
            category: _orNull(_categoryController.text),
            description: _orNull(_descriptionController.text),
            email: _orNull(_emailController.text),
            phone: _orNull(_phoneController.text),
            address: _orNull(_addressController.text),
            hours: _orNull(_hoursController.text),
            imageUrl: widget.commerce.imageUrl,
            notes: _orNull(_notesController.text),
          ),
          photo: _photo,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(myCommerceControllerProvider, (
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
          const SnackBar(content: Text('Fiche mise à jour avec succès !')),
        );
        setState(() => _photo = null);
      }
    });

    final isLoading = ref.watch(myCommerceControllerProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom du commerce',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Le nom est requis.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(),
              hintText: 'ex. Alimentation, Maison, Services, Santé…',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _hoursController,
            decoration: const InputDecoration(
              labelText: 'Horaires',
              border: OutlineInputBorder(),
              hintText: 'ex. Lun-Sam 7h-19h',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (visible publiquement)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              hintText:
                  'ex. Congés annuels du 12 au 25 juillet, promotion du moment…',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            'Affiché sur votre fiche publique — à tenir à jour (congés, '
            'promotions, actualités).',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          CommercePhotoField(
            photo: _photo,
            existingImageUrl: widget.commerce.imageUrl,
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
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
