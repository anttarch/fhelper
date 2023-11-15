import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InputField extends StatelessWidget {
  const InputField({
    required this.label,
    super.key,
    this.controller,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.onTap,
    this.placeholder,
    this.readOnly = false,
    this.suffix,
    this.suffixStyle,
    this.textColor,
    this.validator,
  }) : assert(
          !(controller != null && placeholder != null),
          'Cannot handle a controller and a placeholder at the same time',
        );
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final String? placeholder;
  final bool readOnly;
  final String? suffix;
  final TextStyle? suffixStyle;
  final Color? textColor;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller ?? TextEditingController(text: placeholder),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(16),
        errorMaxLines: 1,
        errorStyle: const TextStyle(height: 1),
        suffixText: suffix,
        suffixStyle: suffixStyle,
        labelText: label,
      ),
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      onTap: onTap,
      enabled: enabled,
      readOnly: readOnly,
      style: TextStyle(
        color: textColor ?? Theme.of(context).colorScheme.onSurface,
      ),
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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

    final parsedValue = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    final value = double.parse(parsedValue);

    final formatter = NumberFormat.simpleCurrency(locale: locale);
    final newText = formatter.format(value / 100);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
