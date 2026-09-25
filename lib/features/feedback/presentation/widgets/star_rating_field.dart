import 'package:flutter/material.dart';

class StarRatingField extends FormField<int> {
  StarRatingField({
    super.key,
    required ValueChanged<int> onChanged,
    super.initialValue,
  }) : super(
         validator: (value) =>
             value == null ? 'Choisissez une note de 1 à 5 étoiles.' : null,
         builder: (state) {
           final theme = Theme.of(state.context);
           final selected = state.value ?? 0;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Semantics(
                 container: true,
                 label: 'Note',
                 child: Row(
                   children: [
                     for (var star = 1; star <= 5; star++)
                       Semantics(
                         button: true,
                         selected: star == selected,
                         label: star == 1
                             ? '1 étoile sur 5'
                             : '$star étoiles sur 5',
                         excludeSemantics: true,
                         onTap: () {
                           state.didChange(star);
                           onChanged(star);
                         },
                         child: IconButton(
                           iconSize: 40,
                           constraints: const BoxConstraints(
                             minWidth: 48,
                             minHeight: 48,
                           ),
                           onPressed: () {
                             state.didChange(star);
                             onChanged(star);
                           },
                           icon: Icon(
                             star <= selected
                                 ? Icons.star_rounded
                                 : Icons.star_outline_rounded,
                             color: star <= selected
                                 ? const Color(0xFFB26A00)
                                 : theme.colorScheme.outline,
                           ),
                         ),
                       ),
                   ],
                 ),
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Text(
                     state.errorText!,
                     style: theme.textTheme.bodySmall?.copyWith(
                       color: theme.colorScheme.error,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}
