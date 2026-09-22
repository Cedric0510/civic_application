import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:flutter/material.dart';

class ReportCategoryDropdown extends StatelessWidget {
  const ReportCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ReportCategory? value;
  final ValueChanged<ReportCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ReportCategory>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(),
      ),
      items: ReportCategory.values
          .map(
            (category) => DropdownMenuItem<ReportCategory>(
              value: category,
              child: Text(category.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null ? 'Veuillez sélectionner une catégorie.' : null,
    );
  }
}
