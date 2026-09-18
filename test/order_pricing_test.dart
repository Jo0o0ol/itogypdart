import 'package:coffee_house_final/domain/order_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('сервисный сбор составляет 3 процента', () {
    final result = OrderPricing.calculate(subtotal: 1000);
    expect(result.serviceFee, 30);
    expect(result.total, 1030);
  });

  test('промокод уменьшает базу для сервисного сбора', () {
    final result = OrderPricing.calculate(
      subtotal: 1000,
      promoPercent: 10,
    );
    expect(result.discount, 100);
    expect(result.serviceFee, 27);
    expect(result.total, 927);
  });

  test('скидка ограничена 80 процентами', () {
    final result = OrderPricing.calculate(
      subtotal: 1000,
      promoPercent: 100,
    );
    expect(result.discount, 800);
  });

  test('отрицательный подытог превращается в ноль', () {
    final result = OrderPricing.calculate(subtotal: -200);
    expect(result.total, 0);
  });
}
