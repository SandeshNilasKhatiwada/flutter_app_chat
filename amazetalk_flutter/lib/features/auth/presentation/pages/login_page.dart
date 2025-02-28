import 'package:amazetalk_flutter/app_routes.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:amazetalk_flutter/features/auth/presentation/widgets/auth_button.dart';
import 'package:amazetalk_flutter/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:amazetalk_flutter/features/auth/presentation/widgets/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    BlocProvider.of<AuthBloc>(context).add(
      LoginEvent(
          email: _emailController.text, password: _passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthInputField(
                    hint: "Email",
                    icon: Icons.email,
                    controller: _emailController),
                SizedBox(height: 20),
                AuthInputField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: _passwordController),
                SizedBox(height: 60),
                BlocConsumer<AuthBloc, AuthState>(builder: (context, state) {
                  if (state is AuthLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return AuthButton(text: "Login", onPressed: _onLogin);
                }, listener: (context, state) {
                  if (state is AuthSuccess) {
                    // AppRoutes.go(AppRoutes.conversations);
                    Navigator.pushNamed(context, AppRoutes.conversations);
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(state.error)));
                  }
                }),
                SizedBox(height: 20),
                LoginPrompt(
                    title: "Donthave an account?",
                    subtitle: "Register",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                      // AppRoutes.go(AppRoutes.register);
                    })
              ],
            )),
      ),
    );
  }
}
