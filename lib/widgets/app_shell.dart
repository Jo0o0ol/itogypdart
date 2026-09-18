import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/roles.dart';
import '../core/session.dart';
import '../state/cart_controller.dart';
import 'responsive.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final widthClass = widthClassFor(MediaQuery.sizeOf(context).width);

    final destinations = <_Destination>[
      const _Destination(
        'Меню',
        Icons.local_cafe_outlined,
        '/menu',
      ),
      if (Permissions.canUseFavorites(session.role))
        const _Destination(
          'Избранное',
          Icons.favorite_border,
          '/favorites',
        ),
      if (Permissions.canBuy(session.role))
        const _Destination(
          'Заказы',
          Icons.receipt_long_outlined,
          '/my-orders',
        ),
      if (Permissions.canReserve(session.role))
        const _Destination(
          'Столики',
          Icons.table_restaurant_outlined,
          '/reservations',
        ),
      if (Permissions.canManageMenu(session.role))
        const _Destination(
          'Меню+',
          Icons.restaurant_menu_outlined,
          '/inventory',
        ),
      if (Permissions.canProcessOrders(session.role))
        const _Destination(
          'Бариста',
          Icons.coffee_maker_outlined,
          '/orders-workspace',
        ),
      if (Permissions.canSeeAnalytics(session.role))
        const _Destination(
          'Админ',
          Icons.analytics_outlined,
          '/admin',
        ),
    ];

    final selectedIndex = _selectedIndex(context, destinations);

    if (widthClass == WidthClass.compact) {
      return Scaffold(
        appBar: _TopBar(session: session),
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              context.go(destinations[index].route),
          destinations: [
            for (final item in destinations)
              NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
          ],
        ),
      );
    }

    final extended = widthClass == WidthClass.wide ||
        widthClass == WidthClass.ultraWide;

    return Scaffold(
      appBar: _TopBar(session: session),
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) =>
                context.go(destinations[index].route),
            destinations: [
              for (final item in destinations)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _selectedIndex(
    BuildContext context,
    List<_Destination> destinations,
  ) {
    final path = GoRouterState.of(context).uri.path;
    for (var i = 0; i < destinations.length; i++) {
      if (path.startsWith(destinations[i].route)) return i;
    }
    return 0;
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({required this.session});

  final Session session;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.coffee),
          SizedBox(width: 8),
          Text('BeanHouse'),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Конструктор напитка',
          onPressed: () => context.go('/drink-calculator'),
          icon: const Icon(Icons.tune),
        ),
        if (Permissions.canBuy(session.role))
          Badge(
            isLabelVisible: cart.totalItems > 0,
            label: Text('${cart.totalItems}'),
            child: IconButton(
              tooltip: 'Корзина',
              onPressed: () => context.go('/cart'),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        IconButton(
          tooltip: 'Профиль',
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
