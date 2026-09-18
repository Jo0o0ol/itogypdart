import 'package:go_router/go_router.dart';

import 'core/roles.dart';
import 'core/services.dart';
import 'models/catalog_query.dart';
import 'models/entity_config.dart';
import 'screens/admin_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/drink_calculator_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/forbidden_screen.dart';
import 'screens/generic_crud_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/login_screen.dart';
import 'screens/menu_item_admin_screen.dart';
import 'screens/menu_item_detail_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/orders_workspace_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reservations_screen.dart';
import 'widgets/app_shell.dart';

GoRouter buildRouter(AppServices services) => GoRouter(
      initialLocation: '/menu',
      refreshListenable: services.session,
      redirect: (context, state) {
        final loggedIn = services.session.isLoggedIn;
        final path = state.uri.path;
        final public =
            path == '/login' || path == '/register';

        if (!loggedIn && !public) {
          return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
        }

        if (loggedIn && public) return '/menu';
        if (!loggedIn) return null;

        final role = services.session.role;

        if ((path.startsWith('/favorites') ||
                path.startsWith('/cart') ||
                path.startsWith('/my-orders') ||
                path.startsWith('/reservations')) &&
            role != AppRole.customer) {
          return '/forbidden';
        }

        if ((path.startsWith('/inventory') ||
                path.startsWith('/orders-workspace')) &&
            role == AppRole.customer) {
          return '/forbidden';
        }

        if (path == '/admin' && role != AppRole.admin) {
          return '/forbidden';
        }

        if ((path.startsWith('/admin-data/users') ||
                path.startsWith('/admin-data/user_profiles') ||
                path.startsWith('/admin-data/orders') ||
                path.startsWith('/admin-data/order_items') ||
                path.startsWith('/admin-data/favorites') ||
                path.startsWith('/admin-data/reservations') ||
                path.startsWith('/admin-data/cafe_tables')) &&
            role != AppRole.admin) {
          return '/forbidden';
        }

        if (path.startsWith('/admin-data') &&
            role == AppRole.customer) {
          return '/forbidden';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, state) => LoginScreen(
            from: state.uri.queryParameters['from'],
          ),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forbidden',
          builder: (_, __) => const ForbiddenScreen(),
        ),
        ShellRoute(
          builder: (_, __, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              redirect: (_, __) => '/menu',
            ),
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: '/menu',
              builder: (_, state) => CatalogScreen(
                query: CatalogQuery.fromUri(state.uri),
              ),
            ),
            GoRoute(
              path: '/menu-items/:id',
              builder: (_, state) => MenuItemDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/favorites',
              builder: (_, __) => const FavoritesScreen(),
            ),
            GoRoute(
              path: '/cart',
              builder: (_, __) => const CartScreen(),
            ),
            GoRoute(
              path: '/my-orders',
              builder: (_, __) => const MyOrdersScreen(),
            ),
            GoRoute(
              path: '/reservations',
              builder: (_, __) => const ReservationsScreen(),
            ),
            GoRoute(
              path: '/drink-calculator',
              builder: (_, __) =>
                  const DrinkCalculatorScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/inventory',
              builder: (_, __) => const InventoryScreen(),
            ),
            GoRoute(
              path: '/orders-workspace',
              builder: (_, __) =>
                  const OrdersWorkspaceScreen(),
            ),
            GoRoute(
              path: '/admin',
              builder: (_, __) => const AdminScreen(),
            ),
            GoRoute(
              path: '/admin-data/menu_items',
              builder: (_, __) =>
                  const MenuItemAdminScreen(),
            ),
            GoRoute(
              path: '/admin-data/:collection',
              builder: (_, state) {
                final name =
                    state.pathParameters['collection']!;
                final config = adminEntities.firstWhere(
                  (entity) => entity.collection == name,
                  orElse: () => adminEntities.first,
                );
                return GenericCrudScreen(config: config);
              },
            ),
          ],
        ),
      ],
      errorBuilder: (_, __) => const NotFoundScreen(),
    );
