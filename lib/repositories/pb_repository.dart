import '../core/api_client.dart';
import '../models/page_result.dart';

class PbRepository {
  const PbRepository(this.api);
  final ApiClient api;

  Future<PageResult<Map<String, dynamic>>> list(String collection, {int page = 1, int perPage = 20, String sort = '-created', String? filter, String? expand}) async {
    final response = await api.request<Map<String, dynamic>>(
      () => api.dio.get('/api/collections/$collection/records', queryParameters: {
        'page': page, 'perPage': perPage, if (sort.isNotEmpty) 'sort': sort,
        if (filter != null && filter.isNotEmpty) 'filter': filter,
        if (expand != null && expand.isNotEmpty) 'expand': expand,
      }),
    );
    return PageResult.fromPocketBase(response.data ?? const {}, (json) => json);
  }

  Future<Map<String, dynamic>> create(String collection, Map<String, dynamic> data) async {
    final r = await api.request<Map<String, dynamic>>(() => api.dio.post('/api/collections/$collection/records', data: data));
    return r.data ?? const {};
  }

  Future<Map<String, dynamic>> update(String collection, String id, Map<String, dynamic> data) async {
    final r = await api.request<Map<String, dynamic>>(() => api.dio.patch('/api/collections/$collection/records/$id', data: data));
    return r.data ?? const {};
  }

  Future<void> delete(String collection, String id) async {
    await api.request(() => api.dio.delete('/api/collections/$collection/records/$id'));
  }

  Future<void> softDelete(String collection, String id) async => update(collection, id, const {'deleted': true});
  Future<void> restore(String collection, String id) async => update(collection, id, const {'deleted': false});
  Future<void> bulkSoftDelete(String collection, List<String> ids) async {
    for (final id in ids) { await softDelete(collection, id); }
  }
}
