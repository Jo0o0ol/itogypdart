import '../core/api_client.dart';
import '../domain/order_pricing.dart';
import '../models/entities.dart';
import '../models/page_result.dart';

class CartLine {
  const CartLine({
    required this.item,
    required this.quantity,
  });

  final MenuItem item;
  final int quantity;

  double get subtotal => item.price * quantity;
}

class OrderRepository {
  const OrderRepository(this.api);

  final ApiClient api;

  Future<PageResult<StoreOrder>> listForUser(String userId) async {
    final response = await api.request<Map<String, dynamic>>(
      () => api.dio.get(
        '/api/collections/orders/records',
        queryParameters: {
          'page': 1,
          'perPage': 50,
          'sort': '-created',
          'filter': 'user="$userId" && deleted=false',
        },
      ),
    );

    return PageResult.fromPocketBase(
      response.data ?? const {},
      StoreOrder.fromJson,
    );
  }

  Future<PageResult<StoreOrder>> listAll({String status = ''}) async {
    final filter = [
      'deleted=false',
      if (status.isNotEmpty) 'status="$status"',
    ].join(' && ');

    final response = await api.request<Map<String, dynamic>>(
      () => api.dio.get(
        '/api/collections/orders/records',
        queryParameters: {
          'page': 1,
          'perPage': 100,
          'sort': '-created',
          'filter': filter,
        },
      ),
    );

    return PageResult.fromPocketBase(
      response.data ?? const {},
      StoreOrder.fromJson,
    );
  }

  Future<String> createOrder({
    required String userId,
    required List<CartLine> lines,
    PromoCode? promo,
  }) async {
    final subtotal =
        lines.fold<double>(0, (sum, line) => sum + line.subtotal);

    final pricing = OrderPricing.calculate(
      subtotal: subtotal,
      promoPercent: promo?.discountPercent ?? 0,
    );

    final response = await api.request<Map<String, dynamic>>(
      () => api.dio.post(
        '/api/collections/orders/records',
        data: {
          'user': userId,
          'status': 'new',
          'subtotal': pricing.subtotal,
          'discount': pricing.discount,
          'service_fee': pricing.serviceFee,
          'total': pricing.total,
          if (promo != null) 'promo_code': promo.id,
          'deleted': false,
        },
      ),
    );

    final orderId = '${response.data?['id'] ?? ''}';

    for (final line in lines) {
      await api.request(
        () => api.dio.post(
          '/api/collections/order_items/records',
          data: {
            'order': orderId,
            'menu_item': line.item.id,
            'quantity': line.quantity,
            'unit_price': line.item.price,
            'deleted': false,
          },
        ),
      );
    }

    return orderId;
  }

  Future<void> setStatus(String id, String status) async {
    await api.request(
      () => api.dio.patch(
        '/api/collections/orders/records/$id',
        data: {'status': status},
      ),
    );
  }
}
