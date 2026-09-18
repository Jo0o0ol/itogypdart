import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/entities.dart';
import '../models/page_result.dart';
import '../repositories/order_repository.dart';
import '../widgets/page_frame.dart';
import '../widgets/state_views.dart';

class OrdersWorkspaceScreen extends StatefulWidget {
  const OrdersWorkspaceScreen({super.key});

  @override
  State<OrdersWorkspaceScreen> createState() =>
      _OrdersWorkspaceScreenState();
}

class _OrdersWorkspaceScreenState
    extends State<OrdersWorkspaceScreen> {
  PageResult<StoreOrder>? page;
  String status = '';
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result =
          await context.read<OrderRepository>().listAll(
                status: status,
              );

      if (!mounted) return;
      setState(() {
        page = result;
        error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    }
  }

  Future<void> change(String id, String value) async {
    try {
      await context.read<OrderRepository>().setStatus(id, value);
      await load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (page == null && error == null) {
      return const LoadingView();
    }

    if (error != null) {
      return ErrorView(message: error!, onRetry: load);
    }

    return PageFrame(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Рабочее место бариста',
                  style:
                      Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Статус заказа',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('Все'),
                    ),
                    DropdownMenuItem(
                      value: 'new',
                      child: Text('Новые'),
                    ),
                    DropdownMenuItem(
                      value: 'paid',
                      child: Text('Оплачены'),
                    ),
                    DropdownMenuItem(
                      value: 'preparing',
                      child: Text('Готовятся'),
                    ),
                    DropdownMenuItem(
                      value: 'ready',
                      child: Text('Готовы'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Выданы'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Отменены'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => status = value ?? '');
                    load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                for (final order in page!.items)
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.coffee_maker_outlined),
                      title: Text('Заказ ${order.id}'),
                      subtitle: Text(
                        '${order.total.toStringAsFixed(2)} ₽ · ${order.status}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) =>
                            change(order.id, value),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'new',
                            child: Text('Новый'),
                          ),
                          PopupMenuItem(
                            value: 'paid',
                            child: Text('Оплачен'),
                          ),
                          PopupMenuItem(
                            value: 'preparing',
                            child: Text('Готовится'),
                          ),
                          PopupMenuItem(
                            value: 'ready',
                            child: Text('Готов'),
                          ),
                          PopupMenuItem(
                            value: 'completed',
                            child: Text('Выдан'),
                          ),
                          PopupMenuItem(
                            value: 'cancelled',
                            child: Text('Отменён'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
