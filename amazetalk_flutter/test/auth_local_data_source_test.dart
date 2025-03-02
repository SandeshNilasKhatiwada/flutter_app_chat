import 'package:amazetalk_flutter/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:amazetalk_flutter/features/auth/data/datasource/auth_local_data_source.dart';

// Create a mock class for FlutterSecureStorage
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthLocalDataSource authLocalDataSource;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    // Initialize the mock and the class under test
    mockStorage = MockFlutterSecureStorage();
    authLocalDataSource = AuthLocalDataSource();
  });

  group('AuthLocalDataSource', () {
    final user = UserModel(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      image: 'avatar.png',
      token: 'access_token',
    );

    test('save should store user data in secure storage', () async {
      // Arrange
      when(mockStorage.write(key: 'id', value: user.id))
          .thenAnswer((_) async => {});
      when(mockStorage.write(key: 'name', value: user.name))
          .thenAnswer((_) async => {});
      when(mockStorage.write(key: 'email', value: user.email))
          .thenAnswer((_) async => {});
      when(mockStorage.write(key: 'avatar', value: user.image))
          .thenAnswer((_) async => {});
      when(mockStorage.write(key: 'accessToken', value: user.token))
          .thenAnswer((_) async => {});

      // Act
      await authLocalDataSource.save(user);

      // Assert
      verify(mockStorage.write(key: 'id', value: user.id)).called(1);
      verify(mockStorage.write(key: 'name', value: user.name)).called(1);
      verify(mockStorage.write(key: 'email', value: user.email)).called(1);
      verify(mockStorage.write(key: 'avatar', value: user.image)).called(1);
      verify(mockStorage.write(key: 'accessToken', value: user.token))
          .called(1);
    });

    test('getUser should retrieve user data from secure storage', () async {
      // Arrange
      when(mockStorage.read(key: 'id')).thenAnswer((_) async => user.id);
      when(mockStorage.read(key: 'name')).thenAnswer((_) async => user.name);
      when(mockStorage.read(key: 'email')).thenAnswer((_) async => user.email);
      when(mockStorage.read(key: 'avatar')).thenAnswer((_) async => user.image);
      when(mockStorage.read(key: 'accessToken'))
          .thenAnswer((_) async => user.token);

      // Act
      final result = await authLocalDataSource.getUser();

      // Assert
      expect(result.id, user.id);
      expect(result.name, user.name);
      expect(result.email, user.email);
      expect(result.image, user.image);
      expect(result.token, user.token);
    });

    test('getToken should retrieve token from secure storage', () async {
      // Arrange
      when(mockStorage.read(key: 'accessToken'))
          .thenAnswer((_) async => user.token);

      // Act
      final token = await authLocalDataSource.getToken();

      // Assert
      expect(token, user.token);
    });

    test('clear should delete all keys from secure storage', () async {
      // Act
      await authLocalDataSource.clear();

      // Assert
      verify(mockStorage.delete(key: 'id')).called(1);
      verify(mockStorage.delete(key: 'name')).called(1);
      verify(mockStorage.delete(key: 'email')).called(1);
      verify(mockStorage.delete(key: 'avatar')).called(1);
      verify(mockStorage.delete(key: 'accessToken')).called(1);
    });
  });
}
