enum FieldKind { text, number, boolean, relation, multiRelation }

class FieldConfig {
  const FieldConfig({
    required this.name,
    required this.label,
    required this.kind,
    this.required = false,
    this.relationCollection,
    this.relationLabelField = 'name',
  });

  final String name;
  final String label;
  final FieldKind kind;
  final bool required;
  final String? relationCollection;
  final String relationLabelField;
}

class EntityConfig {
  const EntityConfig({
    required this.collection,
    required this.title,
    required this.displayField,
    required this.fields,
  });

  final String collection;
  final String title;
  final String displayField;
  final List<FieldConfig> fields;
}

const adminEntities = <EntityConfig>[
  EntityConfig(
    collection: 'users',
    title: 'Пользователи',
    displayField: 'email',
    fields: [
      FieldConfig(
        name: 'email',
        label: 'E-mail',
        kind: FieldKind.text,
        required: true,
      ),
      FieldConfig(
        name: 'full_name',
        label: 'ФИО',
        kind: FieldKind.text,
      ),
      FieldConfig(
        name: 'role',
        label: 'Роль',
        kind: FieldKind.text,
        required: true,
      ),
    ],
  ),
  EntityConfig(
    collection: 'user_profiles',
    title: 'Профили',
    displayField: 'nickname',
    fields: [
      FieldConfig(
        name: 'user',
        label: 'Пользователь',
        kind: FieldKind.relation,
        required: true,
        relationCollection: 'users',
        relationLabelField: 'email',
      ),
      FieldConfig(
        name: 'nickname',
        label: 'Имя в кофейне',
        kind: FieldKind.text,
      ),
      FieldConfig(
        name: 'favorite_drink',
        label: 'Любимый напиток',
        kind: FieldKind.text,
      ),
    ],
  ),
  EntityConfig(
    collection: 'categories',
    title: 'Категории меню',
    displayField: 'name',
    fields: [
      FieldConfig(
        name: 'name',
        label: 'Название',
        kind: FieldKind.text,
        required: true,
      ),
      FieldConfig(
        name: 'description',
        label: 'Описание',
        kind: FieldKind.text,
      ),
    ],
  ),
  EntityConfig(
    collection: 'suppliers',
    title: 'Поставщики',
    displayField: 'name',
    fields: [
      FieldConfig(
        name: 'name',
        label: 'Название',
        kind: FieldKind.text,
        required: true,
      ),
      FieldConfig(
        name: 'phone',
        label: 'Телефон',
        kind: FieldKind.text,
      ),
      FieldConfig(
        name: 'rating',
        label: 'Рейтинг',
        kind: FieldKind.number,
      ),
    ],
  ),
  EntityConfig(
    collection: 'ingredients',
    title: 'Ингредиенты',
    displayField: 'name',
    fields: [
      FieldConfig(
        name: 'name',
        label: 'Название',
        kind: FieldKind.text,
        required: true,
      ),
      FieldConfig(
        name: 'unit',
        label: 'Единица измерения',
        kind: FieldKind.text,
        required: true,
      ),
      FieldConfig(
        name: 'stock',
        label: 'Остаток',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'supplier',
        label: 'Поставщик',
        kind: FieldKind.relation,
        relationCollection: 'suppliers',
      ),
    ],
  ),
  EntityConfig(
    collection: 'cafe_tables',
    title: 'Столики',
    displayField: 'code',
    fields: [
      FieldConfig(
        name: 'code',
        label: 'Номер / код',
        kind: FieldKind.text,
        required: true,
      ),
      FieldConfig(
        name: 'seats',
        label: 'Мест',
        kind: FieldKind.number,
        required: true,
      ),
      FieldConfig(
        name: 'zone',
        label: 'Зона',
        kind: FieldKind.text,
      ),
      FieldConfig(
        name: 'active',
        label: 'Доступен',
        kind: FieldKind.boolean,
      ),
    ],
  ),
  EntityConfig(
    collection: 'promo_codes',
    title: 'Промокоды',
    displayField: 'code',
    fields: [
      FieldConfig(
        name: 'code',
        label: 'Код',
        kind: FieldKind.text,
        required: true,
      ),
      FieldConfig(
        name: 'discount_percent',
        label: 'Скидка %',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'active',
        label: 'Активен',
        kind: FieldKind.boolean,
      ),
    ],
  ),
  EntityConfig(
    collection: 'orders',
    title: 'Заказы',
    displayField: 'id',
    fields: [
      FieldConfig(
        name: 'user',
        label: 'Пользователь',
        kind: FieldKind.relation,
        required: true,
        relationCollection: 'users',
        relationLabelField: 'email',
      ),
      FieldConfig(
        name: 'status',
        label: 'Статус',
        kind: FieldKind.text,
        required: true,
      ),
      FieldConfig(
        name: 'subtotal',
        label: 'Подытог',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'discount',
        label: 'Скидка',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'service_fee',
        label: 'Сервисный сбор',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'total',
        label: 'Итого',
        kind: FieldKind.number,
      ),
    ],
  ),
  EntityConfig(
    collection: 'order_items',
    title: 'Позиции заказов',
    displayField: 'id',
    fields: [
      FieldConfig(
        name: 'order',
        label: 'Заказ',
        kind: FieldKind.relation,
        relationCollection: 'orders',
        relationLabelField: 'id',
      ),
      FieldConfig(
        name: 'menu_item',
        label: 'Позиция меню',
        kind: FieldKind.relation,
        relationCollection: 'menu_items',
      ),
      FieldConfig(
        name: 'quantity',
        label: 'Количество',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'unit_price',
        label: 'Цена',
        kind: FieldKind.number,
      ),
    ],
  ),
  EntityConfig(
    collection: 'reservations',
    title: 'Бронирования',
    displayField: 'id',
    fields: [
      FieldConfig(
        name: 'user',
        label: 'Пользователь',
        kind: FieldKind.relation,
        relationCollection: 'users',
        relationLabelField: 'email',
      ),
      FieldConfig(
        name: 'table',
        label: 'Столик',
        kind: FieldKind.relation,
        relationCollection: 'cafe_tables',
        relationLabelField: 'code',
      ),
      FieldConfig(
        name: 'reserved_at',
        label: 'Дата и время',
        kind: FieldKind.text,
      ),
      FieldConfig(
        name: 'duration_min',
        label: 'Длительность, мин',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'guests',
        label: 'Гостей',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'status',
        label: 'Статус',
        kind: FieldKind.text,
      ),
    ],
  ),
  EntityConfig(
    collection: 'reviews',
    title: 'Отзывы',
    displayField: 'text',
    fields: [
      FieldConfig(
        name: 'user',
        label: 'Пользователь',
        kind: FieldKind.relation,
        relationCollection: 'users',
        relationLabelField: 'email',
      ),
      FieldConfig(
        name: 'menu_item',
        label: 'Позиция меню',
        kind: FieldKind.relation,
        relationCollection: 'menu_items',
      ),
      FieldConfig(
        name: 'rating',
        label: 'Оценка',
        kind: FieldKind.number,
      ),
      FieldConfig(
        name: 'text',
        label: 'Текст',
        kind: FieldKind.text,
      ),
    ],
  ),
  EntityConfig(
    collection: 'favorites',
    title: 'Избранное',
    displayField: 'id',
    fields: [
      FieldConfig(
        name: 'user',
        label: 'Пользователь',
        kind: FieldKind.relation,
        relationCollection: 'users',
        relationLabelField: 'email',
      ),
      FieldConfig(
        name: 'menu_item',
        label: 'Позиция меню',
        kind: FieldKind.relation,
        relationCollection: 'menu_items',
      ),
    ],
  ),
];
