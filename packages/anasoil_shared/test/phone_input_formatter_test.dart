import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnaSoilPhoneInputFormatter', () {
    test('formats Brazilian mobile phones', () {
      expect(
        AnaSoilPhoneInputFormatter.format('11987654321'),
        '(11) 98765-4321',
      );
    });

    test('keeps only the first eleven digits', () {
      expect(
        AnaSoilPhoneInputFormatter.digitsOnly('(11) 98765-43210'),
        '11987654321',
      );
    });

    test('formats text editing values with cursor at the end', () {
      const formatter = AnaSoilPhoneInputFormatter();

      final value = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '11987654321'),
      );

      expect(value.text, '(11) 98765-4321');
      expect(value.selection.baseOffset, value.text.length);
    });
  });
}
