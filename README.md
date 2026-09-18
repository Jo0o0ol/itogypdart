# BeanHouse — итоговый индивидуальный проект «Кофейня»

Готовый типовой Flutter Web-проект по требованиям итоговой индивидуальной работы.

## Что реализовано

Предметная область: **кофейня BeanHouse**.

Система включает:
- Flutter Web;
- `go_router`;
- Provider;
- Dio;
- PocketBase;
- REST API;
- регистрацию и вход;
- сохранение сессии;
- три роли;
- защищённые маршруты;
- серверный поиск, фильтры, сортировку и пагинацию;
- CRUD;
- логическое удаление, восстановление и физическое удаление;
- адаптивную вёрстку 360–1920 px;
- состояния loading / data / empty / error;
- unit- и widget-тесты;
- конструктор напитка;
- бронирование столика с проверкой пересечения времени.

## Сущности

В проекте 13 связанных сущностей:

```text
users
user_profiles
categories
suppliers
ingredients
menu_items
cafe_tables
reservations
promo_codes
orders
order_items
reviews
favorites
```

Связи:

```text
1:1
users ↔ user_profiles

1:M
categories → menu_items
suppliers → ingredients
users → orders
orders → order_items
users → reservations
cafe_tables → reservations

M:M
menu_items ↔ ingredients
```

## Роли

### customer — Посетитель
- меню;
- карточки позиций;
- избранное;
- корзина;
- личные заказы;
- бронирование столиков;
- профиль;
- конструктор напитка.

### barista — Бариста
- управление меню;
- категории;
- ингредиенты;
- поставщики;
- рабочее место бариста;
- изменение статусов заказов;
- модерация отзывов.

### admin — Администратор
- пользователи и роли;
- столики;
- бронирования;
- аналитика;
- все административные данные;
- восстановление;
- физическое удаление.

---

# ПОЛНАЯ ИНСТРУКЦИЯ ПО ЗАПУСКУ

## 1. Распаковать проект

Рекомендуется короткий путь, например:

```text
C:\BeanHouse
```

Внутри должны быть:

```text
C:\BeanHouse\lib
C:\BeanHouse\test
C:\BeanHouse\web
C:\BeanHouse\docs
C:\BeanHouse\pocketbase
C:\BeanHouse\pubspec.yaml
```

## 2. Скачать PocketBase

Скачайте Windows-сборку PocketBase и положите:

```text
pocketbase.exe
```

в:

```text
C:\BeanHouse\pocketbase\
```

Получится:

```text
C:\BeanHouse\pocketbase\pocketbase.exe
C:\BeanHouse\pocketbase\pb_migrations\2800000000_beanhouse_schema.js
```

## 3. Первый запуск PocketBase

Откройте CMD:

```bat
cd /d C:\BeanHouse\pocketbase
pocketbase.exe migrate up
```

Миграция автоматически создаст:
- поля и коллекции;
- связи;
- индексы;
- API Rules;
- тестовых пользователей;
- тестовые позиции меню;
- ингредиенты;
- поставщиков;
- столики;
- промокод;
- пример заказа;
- пример бронирования.

После успешной миграции:

```bat
pocketbase.exe serve
```

Не закрывайте это окно.

Админ-панель:

```text
http://127.0.0.1:8090/_/
```

REST API:

```text
http://127.0.0.1:8090/api/
```

При первом запуске PocketBase может предложить создать superuser для своей админ-панели. Это отдельная служебная учётная запись.

### Если PocketBase уже использовался с другим проектом

Для BeanHouse рекомендуется отдельная папка PocketBase.

Если это тестовая база и данные не нужны, можно удалить:

```bat
rmdir /s /q pb_data
```

и снова:

```bat
pocketbase.exe migrate up
pocketbase.exe serve
```

---

# 4. Тестовые аккаунты

## Посетитель

```text
customer@coffee.local
Customer123!
```

## Бариста

```text
barista@coffee.local
Barista123!
```

## Администратор

```text
admin@coffee.local
Admin123!
```

---

# 5. Проверить Flutter

Откройте второе окно CMD:

```bat
cd /d C:\BeanHouse
flutter pub get
```

Проверка кода:

```bat
flutter analyze
```

Тесты:

```bat
flutter test
```

Форматирование:

```bat
dart format lib test
```

---

# 6. Запустить приложение

Обычный запуск:

```bat
flutter run -d chrome --web-port=5555 --no-web-resources-cdn --dart-define=PB_URL=http://127.0.0.1:8090
```

Если Chrome не запускается:

```bat
flutter run -d web-server --web-port=5555 --dart-define=PB_URL=http://127.0.0.1:8090
```

После этого вручную открыть:

```text
http://localhost:5555
```

PocketBase в этот момент должен продолжать работать на `8090`.

---

# 7. Что проверить в приложении

## Под customer

Войти:

```text
customer@coffee.local
Customer123!
```

Проверить:
1. меню;
2. поиск;
3. фильтр по категории;
4. фильтр по типу;
5. диапазон цены;
6. сортировку;
7. карточку позиции;
8. избранное;
9. корзину;
10. промокод `COFFEE10`;
11. оформление заказа;
12. мои заказы;
13. бронирование столика;
14. конструктор напитка;
15. профиль.

## Под barista

```text
barista@coffee.local
Barista123!
```

Проверить:
1. управление меню;
2. категории;
3. ингредиенты;
4. поставщиков;
5. редактирование позиции меню;
6. рабочее место бариста;
7. статусы `new → paid → preparing → ready → completed`;
8. невозможность открыть `/reservations` вручную.

## Под admin

```text
admin@coffee.local
Admin123!
```

Проверить:
1. аналитику;
2. пользователей;
3. изменение роли;
4. столики;
5. бронирования;
6. логическое удаление;
7. восстановление;
8. физическое удаление.

---

# 8. Содержательная особенность

## Конструктор напитка

Маршрут:

```text
/drink-calculator
```

Рассчитывает:
- размер S/M/L;
- объём;
- количество шотов эспрессо;
- альтернативное молоко;
- сироп;
- дополнительный эспрессо;
- итоговую цену.

## Проверка бронирования

Маршрут:

```text
/reservations
```

Перед созданием записи:
1. приложение запрашивает бронирования выбранного столика;
2. получает соседние временные интервалы;
3. проверяет пересечение;
4. не позволяет создать конфликтующую бронь.

---

# 9. Release-сборка

```bat
cd /d C:\BeanHouse

flutter build web --release --no-web-resources-cdn --dart-define=PB_URL=http://127.0.0.1:8090
```

Готовая сборка:

```text
build\web
```

Без публичного backend опубликованная версия будет только демонстрационной, потому что `127.0.0.1` указывает на компьютер пользователя.

---

# 10. Git и GitHub

Создать пустой репозиторий, например:

```text
beanhouse-final
```

Из проекта:

```bat
cd /d C:\BeanHouse

git init
git branch -M main
git add .
git status
```

Проверить, что в Git **не попали**:

```text
pocketbase.exe
pocketbase/pb_data/
build/
.dart_tool/
```

Но должна попасть миграция:

```text
pocketbase/pb_migrations/2800000000_beanhouse_schema.js
```

Коммит:

```bat
git commit -m "Final BeanHouse project"
```

Remote:

```bat
git remote add origin https://github.com/ВАШ_ЛОГИН/beanhouse-final.git
```

Push:

```bat
git push -u origin main
```

Если `pb_migrations` игнорируется:

```bat
git add -f pocketbase/pb_migrations/2800000000_beanhouse_schema.js
git commit -m "Add PocketBase migration"
git push
```

---

# 11. Что лежит в документации

```text
docs/PROJECT_DESCRIPTION.md
docs/ER_DIAGRAM.md
docs/DATA_DICTIONARY.md
docs/API_CONTRACT.md
docs/ROUTES_AND_ROLES.md

pocketbase/SCHEMA.md
pocketbase/ACCESS_RULES.md
pocketbase/pb_migrations/2800000000_beanhouse_schema.js
```

Эти файлы можно использовать как основу итогового отчёта.

---

# 12. Рекомендуемые скриншоты для отчёта

1. Вход.
2. Регистрация.
3. Меню.
4. Меню с фильтрами.
5. Карточка позиции.
6. Корзина.
7. Промокод.
8. Мои заказы.
9. Бронирование столика.
10. Конструктор напитка.
11. Профиль.
12. Интерфейс barista.
13. Управление меню.
14. Редактирование позиции.
15. Панель администратора.
16. Пользователи.
17. Столики.
18. Экран «Доступ запрещён».
19. PocketBase с коллекциями.
20. `flutter analyze`.
21. `flutter test`.
22. GitHub-репозиторий.

---

# 13. Перед сдачей

Финальная проверка:

```bat
flutter analyze
flutter test
git status
```

Желательно получить:

```text
No issues found!
All tests passed!
nothing to commit, working tree clean
```
