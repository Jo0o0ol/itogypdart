import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/roles.dart';
import '../core/session.dart';
import '../widgets/page_frame.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();

    return PageFrame(
      maxWidth: 1050,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.local_cafe_outlined,
            size: 76,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            'BeanHouse',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Информационная система кофейни',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${session.fullName ?? session.email} · ${session.role.title}',
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/menu'),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Открыть меню'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/drink-calculator'),
                icon: const Icon(Icons.tune),
                label: const Text('Конструктор напитка'),
              ),
              if (Permissions.canReserve(session.role))
                OutlinedButton.icon(
                  onPressed: () => context.go('/reservations'),
                  icon: const Icon(Icons.table_restaurant),
                  label: const Text('Забронировать столик'),
                ),
              if (Permissions.canManageMenu(session.role))
                OutlinedButton.icon(
                  onPressed: () => context.go('/inventory'),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Управление меню'),
                ),
              if (Permissions.canSeeAnalytics(session.role))
                OutlinedButton.icon(
                  onPressed: () => context.go('/admin'),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Аналитика'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
