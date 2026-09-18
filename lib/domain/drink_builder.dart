enum DrinkSize { small, medium, large }

class DrinkBuildResult {
  const DrinkBuildResult({
    required this.basePrice,
    required this.extrasPrice,
    required this.total,
    required this.volumeMl,
    required this.espressoShots,
  });

  final double basePrice;
  final double extrasPrice;
  final double total;
  final int volumeMl;
  final int espressoShots;
}

class DrinkBuilder {
  const DrinkBuilder._();

  static DrinkBuildResult calculate({
    required double basePrice,
    required DrinkSize size,
    bool alternativeMilk = false,
    int syrupShots = 0,
    bool extraEspresso = false,
  }) {
    final sizeExtra = switch (size) {
      DrinkSize.small => 0.0,
      DrinkSize.medium => 40.0,
      DrinkSize.large => 80.0,
    };

    final volume = switch (size) {
      DrinkSize.small => 250,
      DrinkSize.medium => 350,
      DrinkSize.large => 450,
    };

    final baseShots = switch (size) {
      DrinkSize.small => 1,
      DrinkSize.medium => 2,
      DrinkSize.large => 2,
    };

    final extras = sizeExtra +
        (alternativeMilk ? 60 : 0) +
        syrupShots.clamp(0, 5) * 25 +
        (extraEspresso ? 70 : 0);

    final safeBase = basePrice < 0 ? 0.0 : basePrice;
    final total = safeBase + extras;

    return DrinkBuildResult(
      basePrice: safeBase,
      extrasPrice: extras,
      total: (total * 100).roundToDouble() / 100,
      volumeMl: volume,
      espressoShots: baseShots + (extraEspresso ? 1 : 0),
    );
  }
}
