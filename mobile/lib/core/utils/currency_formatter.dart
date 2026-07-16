import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    
    // Remove all non-digits
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(
          text: '',
          selection: const TextSelection.collapsed(offset: 0));
    }

    double value = double.parse(newText);
    
    // Format the number using intl
    final formatter = NumberFormat('#,###', 'en_US');
    String formattedValue = formatter.format(value);

    // If the locale uses '.' as thousand separator, replace it
    // In VN we usually use '.', so we can replace ',' with '.'
    formattedValue = formattedValue.replaceAll(',', '.');

    return newValue.copyWith(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length));
  }
}
