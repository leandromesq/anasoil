import 'package:flutter/services.dart';

/// Text input formatter for Brazilian mobile phone numbers.
///
/// Formats values as `(DDD) 99999-9999` and limits input to 11 digits.
class AnaSoilPhoneInputFormatter extends TextInputFormatter {
  static final RegExp _nonDigits = RegExp(r'\D');
  static const int maxDigits = 11;

  const AnaSoilPhoneInputFormatter();

  static String digitsOnly(String value) {
    final digits = value.replaceAll(_nonDigits, '');
    if (digits.length <= maxDigits) return digits;
    return digits.substring(0, maxDigits);
  }

  static String format(String value) {
    final digits = digitsOnly(value);
    if (digits.isEmpty) return '';

    if (digits.length <= 2) {
      return '($digits';
    }

    final ddd = digits.substring(0, 2);
    final number = digits.substring(2);

    if (number.length <= 5) {
      return '($ddd) $number';
    }

    return '($ddd) ${number.substring(0, 5)}-${number.substring(5)}';
  }

  static bool hasCompleteLength(String value) {
    return digitsOnly(value).length == maxDigits;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = format(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
