class OrderPricing {
  const OrderPricing._();

  static const serviceFeePercent = 3.0;

  static PriceResult calculate({
    required double subtotal,
    double promoPercent = 0,
  }) {
    final safeSubtotal = subtotal < 0 ? 0.0 : subtotal;
    final safePromo = promoPercent.clamp(0, 80).toDouble();

    final discount = safeSubtotal * safePromo / 100;
    final afterDiscount = safeSubtotal - discount;
    final fee = afterDiscount * serviceFeePercent / 100;

    double money(double value) =>
        (value * 100).roundToDouble() / 100;

    return PriceResult(
      subtotal: money(safeSubtotal),
      discount: money(discount),
      serviceFee: money(fee),
      total: money(afterDiscount + fee),
    );
  }
}

class PriceResult {
  const PriceResult({
    required this.subtotal,
    required this.discount,
    required this.serviceFee,
    required this.total,
  });

  final double subtotal;
  final double discount;
  final double serviceFee;
  final double total;
}
