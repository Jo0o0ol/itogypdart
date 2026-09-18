import 'package:flutter/foundation.dart';

import '../models/entities.dart';
import '../repositories/order_repository.dart';

class CartController extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList(growable: false);

  int get totalItems =>
      _lines.values.fold(0, (sum, line) => sum + line.quantity);

  double get subtotal =>
      _lines.values.fold(0, (sum, line) => sum + line.subtotal);

  void add(MenuItem item) {
    final current = _lines[item.id];
    final quantity = (current?.quantity ?? 0) + 1;
    if (quantity > item.stock) return;

    _lines[item.id] = CartLine(
      item: item,
      quantity: quantity,
    );
    notifyListeners();
  }

  void removeOne(String id) {
    final current = _lines[id];
    if (current == null) return;

    if (current.quantity <= 1) {
      _lines.remove(id);
    } else {
      _lines[id] = CartLine(
        item: current.item,
        quantity: current.quantity - 1,
      );
    }

    notifyListeners();
  }

  void remove(String id) {
    _lines.remove(id);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
