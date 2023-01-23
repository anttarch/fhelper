import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .apply(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}
