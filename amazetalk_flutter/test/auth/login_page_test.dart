import 'package:amazetalk_flutter/features/auth/data/models/user_model.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:amazetalk_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:amazetalk_flutter/features/auth/presentation/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group('LoginPage', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets('LoginPage shows loading indicator when logging in',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Tap the login button
      final loginButton = find.byType(AuthButton);
      await tester.tap(loginButton);
      await tester.pump();

      // Check if the loading spinner is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoginPage navigates to conversations on success',
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
            child: const LoginPage(),
          ),
        ),
      );

      final loginButton = find.byType(AuthButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle(); // Wait for the navigation to complete

      // Check if the navigation to conversations page happens
      // (you would need to set up the appropriate route in your app)
      expect(find.text('Conversations'),
          findsOneWidget); // This assumes a 'Conversations' page title or widget
    });

    testWidgets('LoginPage shows error message on failure',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthFailure(error: 'Login Failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      final loginButton = find.byType(AuthButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Check if the snack bar with error message is shown
      expect(find.text('Login Failed'), findsOneWidget);
    });
  });
}
