import 'package:cross_file/cross_file.dart';

import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/presentation/controllers/my_commerce_controller.dart';
import 'package:civic_app/shared/widgets/form_card.dart';
import 'package:civic_app/shared/widgets/form_section_label.dart';
import 'package:civic_app/shared/widgets/photo_field.dart';
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
  late final _nameController = TextEditingController(
    text: widget.commerce.name,
  );
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
  XFile? _photo;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FormSectionLabel(
                  icon: Icons.storefront_outlined,
                  label: 'Informations générales',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du commerce',
                    prefixIcon: Icon(Icons.storefront_outlined),
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
                    hintText: 'ex. Alimentation, Maison, Services, Santé…',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.description_outlined),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FormSectionLabel(
                  icon: Icons.contact_phone_outlined,
                  label: 'Coordonnées',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hoursController,
                  decoration: const InputDecoration(
                    labelText: 'Horaires',
                    hintText: 'ex. Lun-Sam 7h-19h',
                    prefixIcon: Icon(Icons.access_time_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FormSectionLabel(
                  icon: Icons.campaign_outlined,
                  label: 'Fiche publique',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (visible publiquement)',
                    alignLabelWithHint: true,
                    hintText:
                        'ex. Congés annuels du 12 au 25 juillet, promotion du moment…',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.edit_note_outlined),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  'Affiché sur votre fiche publique — à tenir à jour (congés, '
                  'promotions, actualités).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                PhotoField(
                  photo: _photo,
                  existingImageUrl: widget.commerce.imageUrl,
                  label: 'Photo',
                  onChanged: (file) => setState(() => _photo = file),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 52)),
            onPressed: isLoading ? null : _submit,
            icon: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Chargement en cours',
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
