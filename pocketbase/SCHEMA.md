# Схема PocketBase — BeanHouse

Проект содержит 13 связанных сущностей:

1. `users` — системная auth-коллекция PocketBase;
2. `user_profiles` — профиль посетителя;
3. `categories` — категории меню;
4. `suppliers` — поставщики;
5. `ingredients` — ингредиенты;
6. `menu_items` — позиции меню;
7. `cafe_tables` — столики;
8. `reservations` — бронирования;
9. `promo_codes` — промокоды;
10. `orders` — заказы;
11. `order_items` — позиции заказов;
12. `reviews` — отзывы;
13. `favorites` — избранное.

## Типы связей

**Один к одному**
`users ↔ user_profiles`.
Поле `user_profiles.user` имеет уникальный индекс.

**Один ко многим**
- `categories → menu_items`;
- `suppliers → ingredients`;
- `users → orders`;
- `orders → order_items`;
- `users → reservations`;
- `cafe_tables → reservations`.

**Многие ко многим**
`menu_items ↔ ingredients` через множественное relation-поле `menu_items.ingredients`.

## Основные ограничения

- e-mail пользователя уникален средствами auth-коллекции PocketBase;
- код позиции меню `sku` уникален;
- код столика уникален;
- цена > 0;
- остатки неотрицательные;
- рейтинг поставщика 0–5;
- промокод 0–80%;
- отзыв 1–5;
- количество гостей 1–12;
- длительность брони 30–240 минут.

Полная физическая схема создаётся миграцией:

`pb_migrations/2800000000_beanhouse_schema.js`
