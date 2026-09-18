import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/roles.dart';
import '../core/session.dart';
import '../models/entity_config.dart';
import '../widgets/page_frame.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<Session>().role;

    final visible = adminEntities.where((config) {
      if (role == AppRole.admin) return true;

      return !{
        'users',
        'user_profiles',
        'orders',
        'order_items',
        'favorites',
        'reservations',
        'cafe_tables',
      }.contains(config.collection);
    });

    return PageFrame(
      maxWidth: 1000,
      child: ListView(
        children: [
          Text(
            'Управление кофейней',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_cafe_outlined),
              title: const Text('Позиции меню'),
              subtitle: const Text(
                'Напитки, десерты, еда и зерно',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/admin-data/menu_items'),
            ),
          ),
          for (final config in visible)
            Card(
              child: ListTile(
                leading: const Icon(Icons.dataset_outlined),
                title: Text(config.title),
                subtitle: Text(config.collection),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.go('/admin-data/${config.collection}'),
              ),
            ),
        ],
      ),
    );
  }
}
