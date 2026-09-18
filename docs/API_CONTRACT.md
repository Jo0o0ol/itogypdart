# Контракт API BeanHouse

Базовый адрес PocketBase передаётся при запуске/сборке:

```text
--dart-define=PB_URL=http://127.0.0.1:8090
```

## Авторизация

### POST /api/collections/users/records
Регистрация посетителя.

### POST /api/collections/users/auth-with-password
Вход.

### POST /api/collections/users/auth-refresh
Обновление токена.

## Меню

### GET /api/collections/menu_items/records

Используются параметры:
- `page`;
- `perPage`;
- `sort`;
- `filter`;
- `expand=category,ingredients`.

Пример серверного фильтра:

```text
deleted=false && name~"капучино" && category="ID" && kind="coffee" && price>=200 && price<=500
```

## Универсальный CRUD PocketBase

```text
GET    /api/collections/{collection}/records
GET    /api/collections/{collection}/records/{id}
POST   /api/collections/{collection}/records
PATCH  /api/collections/{collection}/records/{id}
DELETE /api/collections/{collection}/records/{id}
```

Коллекции:
`users`, `user_profiles`, `categories`, `suppliers`, `ingredients`, `menu_items`, `cafe_tables`, `reservations`, `promo_codes`, `orders`, `order_items`, `reviews`, `favorites`.

## Бронирования

Перед созданием брони клиент выполняет серверный запрос к `reservations` с фильтром по выбранному столику и временному окну. Затем проверяет пересечение интервалов и только после этого создаёт запись.

## Ошибки

Клиент обрабатывает:
- `400/422` — ошибки валидации полей;
- `401` — обновление токена;
- `403` — отсутствие прав;
- `404` — запись не найдена;
- конфликт и сетевые ошибки;
- timeout и недоступность PocketBase.
