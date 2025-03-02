import 'package:amazetalk_flutter/features/auth/data/models/user_model.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:amazetalk_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:amazetalk_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:amazetalk_flutter/features/auth/presentation/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group('RegisterPage', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets('RegisterPage shows loading indicator when registering',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const RegisterPage(),
          ),
        ),
      );

      // Tap the register button
      final registerButton = find.byType(AuthButton);
      await tester.tap(registerButton);
      await tester.pump();

      // Check if the loading spinner is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('RegisterPage navigates to login on success',
        (WidgetTester tester) async {
      final user = UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        image: 'avatar.png',
        token: 'access_token',
      );
      when(mockAuthBloc.state).thenReturn(AuthSuccess(user));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const RegisterPage(),
          ),
        ),
      );

      final registerButton = find.byType(AuthButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle(); // Wait for the navigation to complete

      // Check if the navigation to login page happens
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('RegisterPage shows error message on failure',
        (WidgetTester tester) async {
      when(mockAuthBloc.state)
          .thenReturn(AuthFailure(error: 'Registration Failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const RegisterPage(),
          ),
        ),
      );

      final registerButton = find.byType(AuthButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Check if the snack bar with error message is shown
      expect(find.text('Registration Failed'), findsOneWidget);
    });
  });
}
