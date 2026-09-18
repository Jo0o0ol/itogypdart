import '../core/api_client.dart';

class StoreAnalytics {
  const StoreAnalytics({
    required this.revenue,
    required this.orders,
    required this.averageOrder,
    required this.activeMenuItems,
    required this.topKind,
    required this.reservations,
  });

  final double revenue;
  final int orders;
  final double averageOrder;
  final int activeMenuItems;
  final String topKind;
  final int reservations;
}

class AnalyticsRepository {
  const AnalyticsRepository(this.api);

  final ApiClient api;

  Future<StoreAnalytics> load() async {
    final ordersResponse = await api.request<Map<String, dynamic>>(
      () => api.dio.get(
        '/api/collections/orders/records',
        queryParameters: {
          'page': 1,
          'perPage': 200,
          'filter': 'deleted=false && status="completed"',
        },
      ),
    );

    final menuResponse = await api.request<Map<String, dynamic>>(
      () => api.dio.get(
        '/api/collections/menu_items/records',
        queryParameters: {
          'page': 1,
          'perPage': 200,
          'filter': 'deleted=false',
        },
      ),
    );

    final reservationsResponse =
        await api.request<Map<String, dynamic>>(
      () => api.dio.get(
        '/api/collections/reservations/records',
        queryParameters: {
          'page': 1,
          'perPage': 200,
          'filter': 'deleted=false && status!="cancelled"',
        },
      ),
    );

    final orders =
        ordersResponse.data?['items'] as List? ?? const [];
    final menu =
        menuResponse.data?['items'] as List? ?? const [];
    final reservations =
        reservationsResponse.data?['items'] as List? ?? const [];

    final revenue = orders.whereType<Map>().fold<double>(
          0,
          (sum, item) =>
              sum +
              ((item['total'] as num?)?.toDouble() ?? 0),
        );

    final kinds = <String, int>{};
    for (final item in menu.whereType<Map>()) {
      final kind = '${item['kind'] ?? 'unknown'}';
      kinds[kind] = (kinds[kind] ?? 0) + 1;
    }

    var topKind = '—';
    var maxCount = -1;

    for (final entry in kinds.entries) {
      if (entry.value > maxCount) {
        topKind = entry.key;
        maxCount = entry.value;
      }
    }

    return StoreAnalytics(
      revenue: revenue,
      orders: orders.length,
      averageOrder:
          orders.isEmpty ? 0 : revenue / orders.length,
      activeMenuItems: menu.length,
      topKind: topKind,
      reservations: reservations.length,
    );
  }
}
