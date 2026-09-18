import 'package:coffee_house_final/domain/drink_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('размер M добавляет 40 рублей', () {
    final result = DrinkBuilder.calculate(
      basePrice: 250,
      size: DrinkSize.medium,
    );

    expect(result.volumeMl, 350);
    expect(result.total, 290);
  });

  test('альтернативное молоко добавляет 60 рублей', () {
    final result = DrinkBuilder.calculate(
      basePrice: 250,
      size: DrinkSize.small,
      alternativeMilk: true,
    );

    expect(result.total, 310);
  });

  test('сироп рассчитывается по 25 рублей', () {
    final result = DrinkBuilder.calculate(
      basePrice: 250,
      size: DrinkSize.small,
      syrupShots: 2,
    );

    expect(result.extrasPrice, 50);
  });

  test('дополнительный эспрессо увеличивает цену и шоты', () {
    final result = DrinkBuilder.calculate(
      basePrice: 250,
      size: DrinkSize.small,
      extraEspresso: true,
    );

    expect(result.espressoShots, 2);
    expect(result.total, 320);
  });
}
