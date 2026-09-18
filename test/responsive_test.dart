import 'package:coffee_house_final/widgets/responsive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('360 — compact', () {
    expect(widthClassFor(360), WidthClass.compact);
  });

  test('768 — medium', () {
    expect(widthClassFor(768), WidthClass.medium);
  });

  test('1280 — wide', () {
    expect(widthClassFor(1280), WidthClass.wide);
  });

  test('1920 — ultraWide', () {
    expect(widthClassFor(1920), WidthClass.ultraWide);
  });
}
