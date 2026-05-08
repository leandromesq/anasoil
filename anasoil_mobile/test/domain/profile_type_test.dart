import 'package:anasoil_mobile/domain/models/profile_type.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile profile types write canonical shared roles', () {
    expect(ProfileType.farmer.firestoreValue, UserRole.farmer.firestoreValue);
    expect(
      ProfileType.consultant.firestoreValue,
      UserRole.consultant.firestoreValue,
    );
  });
}
