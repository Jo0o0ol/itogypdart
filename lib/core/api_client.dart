import 'package:dio/dio.dart';
import 'api_exception.dart';
import 'config.dart';
import 'session.dart';

class ApiClient {
  ApiClient(this.session) {
    dio = Dio(BaseOptions(
      baseUrl: pocketBaseUrl,
      connectTimeout: const Duration(seconds: requestTimeoutSeconds),
      receiveTimeout: const Duration(seconds: requestTimeoutSeconds),
      sendTimeout: const Duration(seconds: requestTimeoutSeconds),
      contentType: Headers.jsonContentType,
    ));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final token = session.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = token;
      }
      handler.next(options);
    }));
  }

  final Session session;
  late final Dio dio;
  bool _refreshing = false;

  Future<Response<T>> request<T>(
    Future<Response<T>> Function() action, {
    bool retryAuth = true,
  }) async {
    try {
      return await action();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && retryAuth && session.isLoggedIn && !_refreshing) {
        final refreshed = await _refreshToken();
        if (refreshed) return request(action, retryAuth: false);
      }
      throw _mapError(e);
    }
  }

  Future<bool> _refreshToken() async {
    _refreshing = true;
    try {
      final response = await dio.post<Map<String, dynamic>>('/api/collections/users/auth-refresh');
      final data = response.data;
      if (data == null) return false;
      final token = '${data['token'] ?? ''}';
      final record = Map<String, dynamic>.from(data['record'] as Map? ?? const {});
      if (token.isEmpty || record.isEmpty) return false;
      await session.setAuth(token, record);
      return true;
    } on DioException {
      await session.clear();
      return false;
    } finally {
      _refreshing = false;
    }
  }

  ApiException _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException('Сервер недоступен. Проверьте PocketBase и соединение.');
    }
    final status = e.response?.statusCode;
    final body = e.response?.data;
    var message = 'Ошибка запроса.';
    final fields = <String, String>{};
    if (body is Map) {
      if (body['message'] is String && '${body['message']}'.isNotEmpty) {
        message = '${body['message']}';
      }
      final data = body['data'];
      if (data is Map) {
        for (final entry in data.entries) {
          final value = entry.value;
          if (value is Map && value['message'] != null) {
            fields['${entry.key}'] = '${value['message']}';
          }
        }
      }
    }
    if (status == 403) message = 'Доступ к операции запрещён сервером.';
    if (status == 404) message = 'Запись не найдена.';
    if (status == 409) message = 'Операция конфликтует с текущими данными.';
    if (status != null && status >= 500) message = 'Внутренняя ошибка сервера.';
    return ApiException(message, statusCode: status, fieldErrors: fields);
  }
}
