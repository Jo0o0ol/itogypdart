import 'package:coffee_house_final/core/roles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('посетитель может бронировать столик', () {
    expect(
      Permissions.canReserve(AppRole.customer),
      isTrue,
    );
    expect(
      Permissions.canReserve(AppRole.barista),
      isFalse,
    );
  });

  test('бариста может управлять меню', () {
    expect(
      Permissions.canManageMenu(AppRole.barista),
      isTrue,
    );
    expect(
      Permissions.canManageMenu(AppRole.customer),
      isFalse,
    );
  });

  test('только администратор управляет пользователями', () {
    expect(
      Permissions.canManageUsers(AppRole.admin),
      isTrue,
    );
    expect(
      Permissions.canManageUsers(AppRole.barista),
      isFalse,
    );
  });

  test('физическое удаление доступно только администратору', () {
    expect(
      Permissions.canHardDelete(AppRole.admin),
      isTrue,
    );
    expect(
      Permissions.canHardDelete(AppRole.customer),
      isFalse,
    );
  });
}
