import '../repositories/analytics_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/menu_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/pb_repository.dart';
import 'api_client.dart';
import 'session.dart';

class AppServices {
  AppServices._({
    required this.session,
    required this.api,
    required this.auth,
    required this.pb,
    required this.menu,
    required this.orders,
    required this.analytics,
  });

  final Session session;
  final ApiClient api;
  final AuthRepository auth;
  final PbRepository pb;
  final MenuRepository menu;
  final OrderRepository orders;
  final AnalyticsRepository analytics;

  static Future<AppServices> create() async {
    final session = Session();
    await session.restore();

    final api = ApiClient(session);

    return AppServices._(
      session: session,
      api: api,
      auth: AuthRepository(api, session),
      pb: PbRepository(api),
      menu: MenuRepository(api),
      orders: OrderRepository(api),
      analytics: AnalyticsRepository(api),
    );
  }
}
