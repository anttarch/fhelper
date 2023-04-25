import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    this.controller,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    required this.label,
    this.locked = false,
    this.onTap,
    this.placeholder,
    this.readOnly = false,
    this.suffix,
    this.suffixStyle,
    this.textColor,
    this.validator,
  }) : assert(!(controller != null && placeholder != null));
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final String label;
  final bool locked;
  final VoidCallback? onTap;
  final String? placeholder;
  final bool readOnly;
  final String? suffix;
  final TextStyle? suffixStyle;
  final Color? textColor;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: true,
      textField: true,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall!.apply(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            ExcludeSemantics(
              child: TextFormField(
                controller: controller ?? TextEditingController(text: placeholder),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(16),
                  errorMaxLines: 1,
                  errorStyle: const TextStyle(height: 1),
                  suffixIcon: locked ? const Icon(Icons.lock) : null,
                  suffixText: suffix,
                  suffixStyle: suffixStyle,
                ),
                keyboardType: keyboardType,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onTap: locked ? () {} : onTap,
                readOnly: readOnly,
                style: TextStyle(
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
                inputFormatters: inputFormatters,
                validator: validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter({required this.locale});

  final String locale;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final String parsedValue = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    final double value = double.parse(parsedValue);

    final formatter = NumberFormat.simpleCurrency(locale: locale);
    final String newText = formatter.format(value / 100);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
