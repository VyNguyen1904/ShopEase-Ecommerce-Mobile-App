import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopease/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('Kiểm tra hiển thị nút Đăng nhập trên LoginScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that "Đăng nhập" button exists.
    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Đăng nhập');
    expect(loginButtonFinder, findsOneWidget);
    
    // Verify Email and Password fields exist.
    expect(find.text('Email'), findsWidgets);
    expect(find.text('Mật khẩu'), findsWidgets);
  });
}
