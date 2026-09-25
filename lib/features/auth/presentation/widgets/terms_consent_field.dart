import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:flutter/material.dart';

class TermsConsentField extends FormField<bool> {
  TermsConsentField({
    super.key,
    required bool accepted,
    required ValueChanged<bool> onChanged,
    required ValueChanged<LegalDocument> onOpenDocument,
  }) : super(
         initialValue: accepted,
         validator: (value) =>
             value == true ? null : 'Vous devez accepter pour créer un compte.',
         builder: (state) {
           final theme = Theme.of(state.context);
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Material(
                 type: MaterialType.transparency,
                 child: CheckboxListTile(
                   contentPadding: EdgeInsets.zero,
                   controlAffinity: ListTileControlAffinity.leading,
                   value: state.value ?? false,
                   onChanged: (value) {
                     state.didChange(value ?? false);
                     onChanged(value ?? false);
                   },
                   title: const Text(
                     'J\'ai lu et j\'accepte les mentions légales et la '
                     'politique de confidentialité.',
                   ),
                 ),
               ),
               Wrap(
                 spacing: 4,
                 children: [
                   for (final document in LegalDocument.values)
                     TextButton(
                       onPressed: () => onOpenDocument(document),
                       child: Text('Lire : ${document.title}'),
                     ),
                 ],
               ),
               if (state.hasError)
                 Text(
                   state.errorText!,
                   style: theme.textTheme.bodySmall?.copyWith(
                     color: theme.colorScheme.error,
                   ),
                 ),
             ],
           );
         },
       );
}
