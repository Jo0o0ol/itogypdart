# Логическая схема данных

```text
users 1 ───── 1 user_profiles

users 1 ───── M orders
orders 1 ───── M order_items
menu_items 1 ─ M order_items

categories 1 ─ M menu_items

suppliers 1 ── M ingredients

menu_items M ─ M ingredients

users 1 ───── M reservations
cafe_tables 1 ─ M reservations

users 1 ───── M reviews
menu_items 1 ─ M reviews

users 1 ───── M favorites
menu_items 1 ─ M favorites

promo_codes 1 ─ M orders
```

Физическая схема задаётся миграцией PocketBase в `pocketbase/pb_migrations`.
