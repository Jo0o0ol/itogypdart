import '../core/api_client.dart';
import '../models/catalog_query.dart';
import '../models/entities.dart';
import '../models/page_result.dart';

class MenuRepository {
  const MenuRepository(this.api);

  final ApiClient api;

  Future<PageResult<MenuItem>> find(CatalogQuery query) async {
    final response = await api.request<Map<String, dynamic>>(
      () => api.dio.get(
        '/api/collections/menu_items/records',
        queryParameters: {
          'page': query.page,
          'perPage': query.perPage,
          'sort': query.sort,
          'filter': query.toPocketBaseFilter(),
          'expand': 'category,ingredients',
        },
      ),
    );

    return PageResult.fromPocketBase(
      response.data ?? const {},
      MenuItem.fromJson,
    );
  }

  Future<MenuItem> byId(String id) async {
    final response = await api.request<Map<String, dynamic>>(
      () => api.dio.get(
        '/api/collections/menu_items/records/$id',
        queryParameters: {'expand': 'category,ingredients'},
      ),
    );
    return MenuItem.fromJson(response.data ?? const {});
  }
}
