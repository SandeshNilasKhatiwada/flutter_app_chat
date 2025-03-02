import 'package:amazetalk_flutter/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:amazetalk_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:amazetalk_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:amazetalk_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUsecase registerUsecase;
  final LoginUsecase loginUsecase;
  final AuthLocalDataSource _cache;

  AuthBloc(this._cache,
      {required this.registerUsecase, required this.loginUsecase})
      : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);

    on<GetCacheData>((event, emit) async {
      final data = await _cache.getUser();
      emit(CacheDataFetched(data));
    });
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.imageFile == null) {
        return emit(AuthFailure(error: "No image file chosen"));
      }
      final user = await registerUsecase(
          event.username, event.email, event.password, event.imageFile!);

      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(error: "Registration Failed")); // ✅ Fixed Typo
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUsecase(event.email, event.password);

      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(error: "Login Failed")); // ✅ Fixed Typo
    }
  }
}
