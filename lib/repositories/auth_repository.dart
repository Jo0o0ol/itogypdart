import '../core/api_client.dart';
import '../core/session.dart';

class AuthRepository {
  const AuthRepository(this.api, this.session);

  final ApiClient api;
  final Session session;

  Future<void> login({
    required String identity,
    required String password,
  }) async {
    final response = await api.request<Map<String, dynamic>>(
      () => api.dio.post(
        '/api/collections/users/auth-with-password',
        data: {
          'identity': identity,
          'password': password,
        },
      ),
      retryAuth: false,
    );

    final data = response.data ?? const {};

    await session.setAuth(
      '${data['token'] ?? ''}',
      Map<String, dynamic>.from(
        data['record'] as Map? ?? const {},
      ),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await api.request(
      () => api.dio.post(
        '/api/collections/users/records',
        data: {
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'full_name': fullName,
          'role': 'customer',
        },
      ),
      retryAuth: false,
    );
  }

  Future<void> logout() => session.clear();
}
