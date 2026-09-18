# Словарь данных

| Сущность | Основные поля | Назначение |
|---|---|---|
| users | email, full_name, role | Учётные записи и роли |
| user_profiles | user, nickname, favorite_drink | Профиль посетителя; связь 1:1 |
| categories | name, description | Категории меню |
| suppliers | name, phone, rating | Поставщики сырья |
| ingredients | name, unit, stock, supplier | Ингредиенты и остатки |
| menu_items | name, sku, category, ingredients, kind, volume_ml, price, stock | Позиции меню |
| cafe_tables | code, seats, zone, active | Столики кофейни |
| reservations | user, table, reserved_at, duration_min, guests, status | Бронирования |
| promo_codes | code, discount_percent, active | Промокоды |
| orders | user, status, subtotal, discount, service_fee, total | Заказы |
| order_items | order, menu_item, quantity, unit_price | Состав заказа |
| reviews | user, menu_item, rating, text | Отзывы |
| favorites | user, menu_item | Избранное |
