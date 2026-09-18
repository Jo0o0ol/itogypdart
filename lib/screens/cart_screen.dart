import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/session.dart';
import '../domain/order_pricing.dart';
import '../models/entities.dart';
import '../repositories/order_repository.dart';
import '../repositories/pb_repository.dart';
import '../state/cart_controller.dart';
import '../widgets/page_frame.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final promo = TextEditingController();
  PromoCode? promoRecord;
  String? message;
  bool placing = false;

  @override
  void dispose() {
    promo.dispose();
    super.dispose();
  }

  Future<void> checkPromo() async {
    final code = promo.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        promoRecord = null;
        message = null;
      });
      return;
    }

    try {
      final result = await context.read<PbRepository>().list(
            'promo_codes',
            perPage: 1,
            filter:
                'code="$code" && active=true && deleted=false',
          );

      setState(() {
        promoRecord = result.items.isEmpty
            ? null
            : PromoCode.fromJson(result.items.first);

        message = promoRecord == null
            ? 'Промокод не найден'
            : 'Скидка ${promoRecord!.discountPercent.toStringAsFixed(0)}% применена';
      });
    } on ApiException catch (e) {
      setState(() => message = e.message);
    }
  }

  Future<void> place() async {
    final cart = context.read<CartController>();
    if (cart.lines.isEmpty) return;

    setState(() => placing = true);

    try {
      final id =
          await context.read<OrderRepository>().createOrder(
                userId: context.read<Session>().userId!,
                lines: cart.lines,
                promo: promoRecord,
              );

      cart.clear();

      if (!mounted) return;
      setState(() => message = 'Заказ $id создан.');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => message = e.message);
    } finally {
      if (mounted) setState(() => placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    final pricing = OrderPricing.calculate(
      subtotal: cart.subtotal,
      promoPercent: promoRecord?.discountPercent ?? 0,
    );

    return PageFrame(
      maxWidth: 900,
      child: ListView(
        children: [
          Text(
            'Корзина',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          if (cart.lines.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Корзина пуста.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            for (final line in cart.lines)
              Card(
                child: ListTile(
                  title: Text(line.item.name),
                  subtitle: Text(
                    '${line.item.price.toStringAsFixed(2)} ₽ × ${line.quantity}',
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        onPressed: () =>
                            cart.removeOne(line.item.id),
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton(
                        onPressed: () => cart.add(line.item),
                        icon: const Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () =>
                            cart.remove(line.item.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  controller: promo,
                  decoration: const InputDecoration(
                    labelText: 'Промокод',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: checkPromo,
                child: const Text('Применить'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Позиции: ${pricing.subtotal.toStringAsFixed(2)} ₽',
                  ),
                  Text(
                    'Скидка: −${pricing.discount.toStringAsFixed(2)} ₽',
                  ),
                  Text(
                    'Сервисный сбор 3%: ${pricing.serviceFee.toStringAsFixed(2)} ₽',
                  ),
                  const Divider(),
                  Text(
                    'Итого: ${pricing.total.toStringAsFixed(2)} ₽',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                message!,
                textAlign: TextAlign.center,
              ),
            ),
          FilledButton.icon(
            onPressed:
                cart.lines.isEmpty || placing ? null : place,
            icon: const Icon(Icons.payment),
            label: const Text('Оформить заказ'),
          ),
        ],
      ),
    );
  }
}
