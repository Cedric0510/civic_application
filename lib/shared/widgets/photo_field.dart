import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Sélection de photo (caméra ou galerie) avec aperçu. Affiche aussi une
// photo déjà enregistrée (existingImageUrl) tant qu'aucune nouvelle n'a été
// choisie, pour les formulaires d'édition d'une fiche existante.
class PhotoField extends StatelessWidget {
  const PhotoField({
    super.key,
    required this.photo,
    required this.onChanged,
    this.existingImageUrl,
    this.label = 'Photo (facultatif)',
  });

  final XFile? photo;
  final String? existingImageUrl;
  final String label;
  final ValueChanged<XFile?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo != null || existingImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (hasPhoto)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: photo != null
                    ? _PickedPhotoPreview(photo: photo!)
                    : Image.network(
                        existingImageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _PhotoPlaceholder(),
                      ),
              ),
              if (photo != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => onChanged(null),
                    ),
                  ),
                ),
            ],
          )
        else
          InkWell(
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade500),
                  const SizedBox(height: 4),
                  Text(
                    'Ajouter une photo',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        if (hasPhoto)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _pick(context),
              child: const Text('Changer la photo'),
            ),
          ),
      ],
    );
  }
}

class _PickedPhotoPreview extends StatefulWidget {
  const _PickedPhotoPreview({required this.photo});

  final XFile photo;

  @override
  State<_PickedPhotoPreview> createState() => _PickedPhotoPreviewState();
}

class _PickedPhotoPreviewState extends State<_PickedPhotoPreview> {
  late Future<Uint8List> _bytes = widget.photo.readAsBytes();

  @override
  void didUpdateWidget(_PickedPhotoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo.path != widget.photo.path) {
      _bytes = widget.photo.readAsBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _PhotoPlaceholder();
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Image.memory(
          snapshot.data!,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
      ),
    );
  }
}
