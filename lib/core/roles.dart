enum AppRole { customer, barista, admin }

extension AppRoleX on AppRole {
  String get title => switch (this) {
        AppRole.customer => 'Посетитель',
        AppRole.barista => 'Бариста',
        AppRole.admin => 'Администратор',
      };

  static AppRole fromApi(String? value) => AppRole.values.firstWhere(
        (role) => role.name == value,
        orElse: () => AppRole.customer,
      );
}

class Permissions {
  const Permissions._();

  static bool canBuy(AppRole role) => role == AppRole.customer;
  static bool canUseFavorites(AppRole role) => role == AppRole.customer;
  static bool canReserve(AppRole role) => role == AppRole.customer;
  static bool canManageMenu(AppRole role) =>
      role == AppRole.barista || role == AppRole.admin;
  static bool canProcessOrders(AppRole role) =>
      role == AppRole.barista || role == AppRole.admin;
  static bool canManageUsers(AppRole role) => role == AppRole.admin;
  static bool canHardDelete(AppRole role) => role == AppRole.admin;
  static bool canSeeAnalytics(AppRole role) => role == AppRole.admin;
}
