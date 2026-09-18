class CafeCategory {
  const CafeCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.deleted,
  });

  final String id;
  final String name;
  final String description;
  final bool deleted;

  factory CafeCategory.fromJson(Map<String, dynamic> json) => CafeCategory(
        id: '${json['id']}',
        name: '${json['name'] ?? ''}',
        description: '${json['description'] ?? ''}',
        deleted: json['deleted'] == true,
      );
}

class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.deleted,
  });

  final String id;
  final String name;
  final String phone;
  final double rating;
  final bool deleted;

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: '${json['id']}',
        name: '${json['name'] ?? ''}',
        phone: '${json['phone'] ?? ''}',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        deleted: json['deleted'] == true,
      );
}

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.supplierId,
    required this.deleted,
  });

  final String id;
  final String name;
  final String unit;
  final double stock;
  final String supplierId;
  final bool deleted;

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: '${json['id']}',
        name: '${json['name'] ?? ''}',
        unit: '${json['unit'] ?? ''}',
        stock: (json['stock'] as num?)?.toDouble() ?? 0,
        supplierId: '${json['supplier'] ?? ''}',
        deleted: json['deleted'] == true,
      );
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.ingredientIds,
    required this.kind,
    required this.volumeMl,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.deleted,
    this.categoryName = '',
  });

  final String id;
  final String name;
  final String sku;
  final String categoryId;
  final List<String> ingredientIds;
  final String kind;
  final int volumeMl;
  final double price;
  final int stock;
  final String imageUrl;
  final bool deleted;
  final String categoryName;

  bool get available => stock > 0 && !deleted;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final expand =
        Map<String, dynamic>.from(json['expand'] as Map? ?? const {});
    final category = expand['category'];
    return MenuItem(
      id: '${json['id']}',
      name: '${json['name'] ?? ''}',
      sku: '${json['sku'] ?? ''}',
      categoryId: '${json['category'] ?? ''}',
      ingredientIds: (json['ingredients'] as List? ?? const [])
          .map((e) => '$e')
          .toList(),
      kind: '${json['kind'] ?? ''}',
      volumeMl: (json['volume_ml'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: '${json['image_url'] ?? ''}',
      deleted: json['deleted'] == true,
      categoryName: category is Map ? '${category['name'] ?? ''}' : '',
    );
  }
}

class CafeTable {
  const CafeTable({
    required this.id,
    required this.code,
    required this.seats,
    required this.zone,
    required this.active,
    required this.deleted,
  });

  final String id;
  final String code;
  final int seats;
  final String zone;
  final bool active;
  final bool deleted;

  factory CafeTable.fromJson(Map<String, dynamic> json) => CafeTable(
        id: '${json['id']}',
        code: '${json['code'] ?? ''}',
        seats: (json['seats'] as num?)?.toInt() ?? 0,
        zone: '${json['zone'] ?? ''}',
        active: json['active'] == true,
        deleted: json['deleted'] == true,
      );
}

class PromoCode {
  const PromoCode({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.active,
    required this.deleted,
  });

  final String id;
  final String code;
  final double discountPercent;
  final bool active;
  final bool deleted;

  factory PromoCode.fromJson(Map<String, dynamic> json) => PromoCode(
        id: '${json['id']}',
        code: '${json['code'] ?? ''}',
        discountPercent:
            (json['discount_percent'] as num?)?.toDouble() ?? 0,
        active: json['active'] == true,
        deleted: json['deleted'] == true,
      );
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.userId,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.serviceFee,
    required this.total,
    required this.deleted,
    this.created = '',
  });

  final String id;
  final String userId;
  final String status;
  final double subtotal;
  final double discount;
  final double serviceFee;
  final double total;
  final bool deleted;
  final String created;

  factory StoreOrder.fromJson(Map<String, dynamic> json) => StoreOrder(
        id: '${json['id']}',
        userId: '${json['user'] ?? ''}',
        status: '${json['status'] ?? ''}',
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        deleted: json['deleted'] == true,
        created: '${json['created'] ?? ''}',
      );
}

class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.menuItemId,
    required this.rating,
    required this.text,
    required this.deleted,
  });

  final String id;
  final String userId;
  final String menuItemId;
  final int rating;
  final String text;
  final bool deleted;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: '${json['id']}',
        userId: '${json['user'] ?? ''}',
        menuItemId: '${json['menu_item'] ?? ''}',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        text: '${json['text'] ?? ''}',
        deleted: json['deleted'] == true,
      );
}
