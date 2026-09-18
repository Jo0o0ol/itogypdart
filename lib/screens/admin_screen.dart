import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../repositories/analytics_repository.dart';
import '../widgets/page_frame.dart';
import '../widgets/state_views.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  StoreAnalytics? analytics;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final value =
          await context.read<AnalyticsRepository>().load();

      if (!mounted) return;
      setState(() {
        analytics = value;
        error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (analytics == null && error == null) {
      return const LoadingView();
    }

    if (error != null) {
      return ErrorView(message: error!, onRetry: load);
    }

    final data = analytics!;

    Widget metric(String title, String value) {
      return SizedBox(
        width: 240,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 8),
                Text(
                  value,
                  style:
                      Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PageFrame(
      maxWidth: 1050,
      child: ListView(
        children: [
          Text(
            'Панель администратора',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              metric(
                'Выручка',
                '${data.revenue.toStringAsFixed(2)} ₽',
              ),
              metric(
                'Завершённых заказов',
                '${data.orders}',
              ),
              metric(
                'Средний заказ',
                '${data.averageOrder.toStringAsFixed(2)} ₽',
              ),
              metric(
                'Позиции меню',
                '${data.activeMenuItems}',
              ),
              metric(
                'Основной тип',
                data.topKind,
              ),
              metric(
                'Активные брони',
                '${data.reservations}',
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go('/inventory'),
            icon: const Icon(Icons.dataset_outlined),
            label: const Text('Управление данными'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.go('/admin-data/users'),
            icon: const Icon(Icons.manage_accounts_outlined),
            label: const Text('Пользователи и роли'),
          ),
        ],
      ),
    );
  }
}
