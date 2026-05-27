import 'package:civic_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class ServiceDropdown extends StatelessWidget {
  const ServiceDropdown({super.key, required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: null,
      decoration: const InputDecoration(
        labelText: 'Service',
        border: OutlineInputBorder(),
      ),
      items: AppConstants.municipalServices
          .map(
            (service) =>
                DropdownMenuItem<String>(value: service, child: Text(service)),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null ? 'Veuillez sélectionner un service.' : null,
    );
  }
}
