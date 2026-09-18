# Маршруты и роли

| Маршрут | customer | barista | admin |
|---|---:|---:|---:|
| /menu | ✓ | ✓ | ✓ |
| /menu-items/:id | ✓ | ✓ | ✓ |
| /profile | ✓ | ✓ | ✓ |
| /drink-calculator | ✓ | ✓ | ✓ |
| /favorites | ✓ | — | — |
| /cart | ✓ | — | — |
| /my-orders | ✓ | — | — |
| /reservations | ✓ | — | — |
| /inventory | — | ✓ | ✓ |
| /orders-workspace | — | ✓ | ✓ |
| /admin | — | — | ✓ |
| /admin-data/users | — | — | ✓ |
| /admin-data/cafe_tables | — | — | ✓ |

Попытка открыть недоступный URL вручную перенаправляет пользователя на `/forbidden`.

Роли различаются не только объёмом CRUD:
- customer имеет заказ, избранное и бронирования;
- barista имеет рабочее место приготовления;
- admin имеет пользователей, столики и аналитику.
