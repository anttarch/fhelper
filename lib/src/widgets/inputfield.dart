import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.label,
    this.onTap,
    this.placeholder,
    this.readOnly = false,
    this.textColor,
  });
  final String label;
  final VoidCallback? onTap;
  final String? placeholder;
  final bool readOnly;
  final Color? textColor;

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
          TextField(
            controller: TextEditingController(text: placeholder),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.sentences,
            onTap: onTap,
            readOnly: readOnly,
            style: TextStyle(
              color: textColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
