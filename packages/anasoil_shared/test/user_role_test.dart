import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole', () {
    test('parses canonical and legacy Firestore values', () {
      expect(UserRole.parse('admin'), UserRole.admin);
      expect(UserRole.parse('administrador'), UserRole.admin);
      expect(UserRole.parse('consultant'), UserRole.consultant);
      expect(UserRole.parse('consultor'), UserRole.consultant);
      expect(UserRole.parse('farmer'), UserRole.farmer);
      expect(UserRole.parse('agricultor'), UserRole.farmer);
    });

    test('writes canonical Firestore values', () {
      expect(UserRole.admin.firestoreValue, 'admin');
      expect(UserRole.consultant.firestoreValue, 'consultant');
      expect(UserRole.farmer.firestoreValue, 'farmer');
    });

    test('exposes governance helpers', () {
      expect(UserRole.admin.canManageUsers, isTrue);
      expect(UserRole.admin.canUseMobile, isFalse);
      expect(UserRole.consultant.canUseMobile, isTrue);
      expect(UserRole.farmer.canManageRelations, isTrue);
    });
  });
}
