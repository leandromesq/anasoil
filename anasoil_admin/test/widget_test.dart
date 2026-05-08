import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AnaSoil admin theme renders a Material app', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Text('AnaSoil Admin')),
      ),
    );

    expect(find.text('AnaSoil Admin'), findsOneWidget);
  });
}
