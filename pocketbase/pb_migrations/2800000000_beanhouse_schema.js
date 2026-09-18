migrate((app) => {
  const loggedIn = '@request.auth.id != ""';
  const baristaOrAdmin =
    '@request.auth.role = "barista" || @request.auth.role = "admin"';
  const adminOnly = '@request.auth.role = "admin"';

  function saveCollection(config) {
    const collection = new Collection(config);
    app.save(collection);

    collection.fields.add(
      new AutodateField({
        name: "created",
        onCreate: true,
        onUpdate: false,
      }),
      new AutodateField({
        name: "updated",
        onCreate: true,
        onUpdate: true,
      }),
    );

    app.save(collection);
    return collection;
  }

  const users = app.findCollectionByNameOrId("users");
  users.listRule =
    'id = @request.auth.id || @request.auth.role = "barista" || @request.auth.role = "admin"';
  users.viewRule = users.listRule;
  users.createRule = '@request.body.role = "customer"';
  users.updateRule =
    'id = @request.auth.id || @request.auth.role = "admin"';
  users.deleteRule = adminOnly;

  users.fields.add(
    new TextField({
      name: "full_name",
      required: true,
      max: 100,
    }),
    new SelectField({
      name: "role",
      required: true,
      maxSelect: 1,
      values: ["customer", "barista", "admin"],
    }),
    new BoolField({
      name: "deleted",
    }),
  );

  app.save(users);

  const categories = saveCollection({
    type: "base",
    name: "categories",
    listRule: loggedIn,
    viewRule: loggedIn,
    createRule: baristaOrAdmin,
    updateRule: baristaOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: "text", name: "name", required: true, max: 80 },
      { type: "text", name: "description", max: 500 },
      { type: "bool", name: "deleted" },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_categories_name_unique ON categories (name)",
    ],
  });

  const suppliers = saveCollection({
    type: "base",
    name: "suppliers",
    listRule: loggedIn,
    viewRule: loggedIn,
    createRule: baristaOrAdmin,
    updateRule: baristaOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: "text", name: "name", required: true, max: 120 },
      { type: "text", name: "phone", max: 40 },
      { type: "number", name: "rating", min: 0, max: 5 },
      { type: "bool", name: "deleted" },
    ],
  });

  const ingredients = saveCollection({
    type: "base",
    name: "ingredients",
    listRule: loggedIn,
    viewRule: loggedIn,
    createRule: baristaOrAdmin,
    updateRule: baristaOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: "text", name: "name", required: true, max: 100 },
      { type: "text", name: "unit", required: true, max: 20 },
      { type: "number", name: "stock", min: 0 },
      {
        type: "relation",
        name: "supplier",
        maxSelect: 1,
        collectionId: suppliers.id,
        cascadeDelete: false,
      },
      { type: "bool", name: "deleted" },
    ],
  });

  const cafeTables = saveCollection({
    type: "base",
    name: "cafe_tables",
    listRule: loggedIn,
    viewRule: loggedIn,
    createRule: adminOnly,
    updateRule: adminOnly,
    deleteRule: adminOnly,
    fields: [
      { type: "text", name: "code", required: true, max: 20 },
      { type: "number", name: "seats", required: true, min: 1, max: 12 },
      {
        type: "select",
        name: "zone",
        required: true,
        maxSelect: 1,
        values: ["window", "hall", "quiet"],
      },
      { type: "bool", name: "active" },
      { type: "bool", name: "deleted" },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_cafe_tables_code_unique ON cafe_tables (code)",
    ],
  });

  const menuItems = saveCollection({
    type: "base",
    name: "menu_items",
    listRule: loggedIn,
    viewRule: loggedIn,
    createRule: baristaOrAdmin,
    updateRule: baristaOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: "text", name: "name", required: true, max: 120 },
      { type: "text", name: "sku", required: true, max: 60 },
      {
        type: "relation",
        name: "category",
        required: true,
        maxSelect: 1,
        collectionId: categories.id,
        cascadeDelete: false,
      },
      {
        type: "relation",
        name: "ingredients",
        maxSelect: 20,
        collectionId: ingredients.id,
        cascadeDelete: false,
      },
      {
        type: "select",
        name: "kind",
        required: true,
        maxSelect: 1,
        values: ["coffee", "tea", "dessert", "food", "beans"],
      },
      { type: "number", name: "volume_ml", min: 0, max: 2000 },
      { type: "number", name: "price", required: true, min: 0.01 },
      { type: "number", name: "stock", required: true, min: 0 },
      { type: "url", name: "image_url" },
      { type: "bool", name: "deleted" },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_menu_items_sku_unique ON menu_items (sku)",
    ],
  });

  const promoCodes = saveCollection({
    type: "base",
    name: "promo_codes",
    listRule: loggedIn,
    viewRule: loggedIn,
    createRule: adminOnly,
    updateRule: adminOnly,
    deleteRule: adminOnly,
    fields: [
      { type: "text", name: "code", required: true, max: 40 },
      { type: "number", name: "discount_percent", min: 0, max: 80 },
      { type: "bool", name: "active" },
      { type: "bool", name: "deleted" },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_promo_code_unique ON promo_codes (code)",
    ],
  });

  const profiles = saveCollection({
    type: "base",
    name: "user_profiles",
    listRule:
      'user = @request.auth.id || @request.auth.role = "admin"',
    viewRule:
      'user = @request.auth.id || @request.auth.role = "admin"',
    createRule:
      'user = @request.auth.id || @request.auth.role = "admin"',
    updateRule:
      'user = @request.auth.id || @request.auth.role = "admin"',
    deleteRule: adminOnly,
    fields: [
      {
        type: "relation",
        name: "user",
        required: true,
        maxSelect: 1,
        collectionId: users.id,
        cascadeDelete: true,
      },
      { type: "text", name: "nickname", max: 50 },
      { type: "text", name: "favorite_drink", max: 100 },
      { type: "bool", name: "deleted" },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_profile_user_unique ON user_profiles (user)",
    ],
  });

  const orders = saveCollection({
    type: "base",
    name: "orders",
    listRule:
      'user = @request.auth.id || @request.auth.role = "barista" || @request.auth.role = "admin"',
    viewRule:
      'user = @request.auth.id || @request.auth.role = "barista" || @request.auth.role = "admin"',
    createRule:
      '@request.auth.role = "customer" && @request.body.user = @request.auth.id',
    updateRule: baristaOrAdmin,
    deleteRule: adminOnly,
    fields: [
      {
        type: "relation",
        name: "user",
        required: true,
        maxSelect: 1,
        collectionId: users.id,
        cascadeDelete: false,
      },
      {
        type: "select",
        name: "status",
        required: true,
        maxSelect: 1,
        values: ["new", "paid", "preparing", "ready", "completed", "cancelled"],
      },
      { type: "number", name: "subtotal", min: 0 },
      { type: "number", name: "discount", min: 0 },
      { type: "number", name: "service_fee", min: 0 },
      { type: "number", name: "total", min: 0 },
      {
        type: "relation",
        name: "promo_code",
        maxSelect: 1,
        collectionId: promoCodes.id,
        cascadeDelete: false,
      },
      { type: "bool", name: "deleted" },
    ],
  });

  const orderItems = saveCollection({
    type: "base",
    name: "order_items",
    listRule:
      'order.user = @request.auth.id || @request.auth.role = "barista" || @request.auth.role = "admin"',
    viewRule:
      'order.user = @request.auth.id || @request.auth.role = "barista" || @request.auth.role = "admin"',
    createRule: '@request.auth.role = "customer"',
    updateRule: baristaOrAdmin,
    deleteRule: adminOnly,
    fields: [
      {
        type: "relation",
        name: "order",
        required: true,
        maxSelect: 1,
        collectionId: orders.id,
        cascadeDelete: true,
      },
      {
        type: "relation",
        name: "menu_item",
        required: true,
        maxSelect: 1,
        collectionId: menuItems.id,
        cascadeDelete: false,
      },
      { type: "number", name: "quantity", required: true, min: 1, max: 100 },
      { type: "number", name: "unit_price", required: true, min: 0 },
      { type: "bool", name: "deleted" },
    ],
  });

  const reservations = saveCollection({
    type: "base",
    name: "reservations",
    listRule:
      'user = @request.auth.id || @request.auth.role = "admin"',
    viewRule:
      'user = @request.auth.id || @request.auth.role = "admin"',
    createRule:
      '@request.auth.role = "customer" && @request.body.user = @request.auth.id',
    updateRule:
      'user = @request.auth.id || @request.auth.role = "admin"',
    deleteRule: adminOnly,
    fields: [
      {
        type: "relation",
        name: "user",
        required: true,
        maxSelect: 1,
        collectionId: users.id,
        cascadeDelete: true,
      },
      {
        type: "relation",
        name: "table",
        required: true,
        maxSelect: 1,
        collectionId: cafeTables.id,
        cascadeDelete: false,
      },
      { type: "date", name: "reserved_at", required: true },
      { type: "number", name: "duration_min", required: true, min: 30, max: 240 },
      { type: "number", name: "guests", required: true, min: 1, max: 12 },
      {
        type: "select",
        name: "status",
        required: true,
        maxSelect: 1,
        values: ["confirmed", "completed", "cancelled"],
      },
      { type: "bool", name: "deleted" },
    ],
  });

  const reviews = saveCollection({
    type: "base",
    name: "reviews",
    listRule: loggedIn,
    viewRule: loggedIn,
    createRule:
      '@request.auth.role = "customer" && @request.body.user = @request.auth.id',
    updateRule:
      'user = @request.auth.id || @request.auth.role = "barista" || @request.auth.role = "admin"',
    deleteRule:
      'user = @request.auth.id || @request.auth.role = "barista" || @request.auth.role = "admin"',
    fields: [
      {
        type: "relation",
        name: "user",
        required: true,
        maxSelect: 1,
        collectionId: users.id,
        cascadeDelete: true,
      },
      {
        type: "relation",
        name: "menu_item",
        required: true,
        maxSelect: 1,
        collectionId: menuItems.id,
        cascadeDelete: false,
      },
      { type: "number", name: "rating", required: true, min: 1, max: 5 },
      { type: "text", name: "text", max: 1000 },
      { type: "bool", name: "deleted" },
    ],
  });

  const favorites = saveCollection({
    type: "base",
    name: "favorites",
    listRule: 'user = @request.auth.id',
    viewRule: 'user = @request.auth.id',
    createRule:
      '@request.auth.role = "customer" && @request.body.user = @request.auth.id',
    updateRule: 'user = @request.auth.id',
    deleteRule:
      'user = @request.auth.id || @request.auth.role = "admin"',
    fields: [
      {
        type: "relation",
        name: "user",
        required: true,
        maxSelect: 1,
        collectionId: users.id,
        cascadeDelete: true,
      },
      {
        type: "relation",
        name: "menu_item",
        required: true,
        maxSelect: 1,
        collectionId: menuItems.id,
        cascadeDelete: true,
      },
      { type: "bool", name: "deleted" },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_favorite_user_item_unique ON favorites (user, menu_item)",
    ],
  });

  function saveRecord(collection, values) {
    const record = new Record(collection);
    for (const [key, value] of Object.entries(values)) {
      record.set(key, value);
    }
    app.save(record);
    return record;
  }

  const customer = saveRecord(users, {
    email: "customer@coffee.local",
    password: "Customer123!",
    full_name: "Тестовый посетитель",
    role: "customer",
    verified: true,
  });

  saveRecord(users, {
    email: "barista@coffee.local",
    password: "Barista123!",
    full_name: "Бариста BeanHouse",
    role: "barista",
    verified: true,
  });

  saveRecord(users, {
    email: "admin@coffee.local",
    password: "Admin123!",
    full_name: "Администратор BeanHouse",
    role: "admin",
    verified: true,
  });

  const coffeeCategory = saveRecord(categories, {
    name: "Кофе",
    description: "Классические и авторские кофейные напитки",
    deleted: false,
  });

  const teaCategory = saveRecord(categories, {
    name: "Чай",
    description: "Чай и сезонные напитки",
    deleted: false,
  });

  const dessertCategory = saveRecord(categories, {
    name: "Десерты",
    description: "Десерты собственного производства",
    deleted: false,
  });

  const roaster = saveRecord(suppliers, {
    name: "North Roast",
    phone: "+7 900 111-22-33",
    rating: 4.9,
    deleted: false,
  });

  const dairy = saveRecord(suppliers, {
    name: "Milk & Co",
    phone: "+7 900 222-33-44",
    rating: 4.7,
    deleted: false,
  });

  const bakery = saveRecord(suppliers, {
    name: "Sweet Lab",
    phone: "+7 900 333-44-55",
    rating: 4.8,
    deleted: false,
  });

  const arabica = saveRecord(ingredients, {
    name: "Арабика Бразилия",
    unit: "г",
    stock: 15000,
    supplier: roaster.id,
    deleted: false,
  });

  const milk = saveRecord(ingredients, {
    name: "Молоко 3,2%",
    unit: "мл",
    stock: 30000,
    supplier: dairy.id,
    deleted: false,
  });

  const oatMilk = saveRecord(ingredients, {
    name: "Овсяное молоко",
    unit: "мл",
    stock: 12000,
    supplier: dairy.id,
    deleted: false,
  });

  const chocolate = saveRecord(ingredients, {
    name: "Шоколад",
    unit: "г",
    stock: 5000,
    supplier: bakery.id,
    deleted: false,
  });

  const table1 = saveRecord(cafeTables, {
    code: "A1",
    seats: 2,
    zone: "window",
    active: true,
    deleted: false,
  });

  saveRecord(cafeTables, {
    code: "A2",
    seats: 4,
    zone: "hall",
    active: true,
    deleted: false,
  });

  saveRecord(cafeTables, {
    code: "Q1",
    seats: 2,
    zone: "quiet",
    active: true,
    deleted: false,
  });

  const cappuccino = saveRecord(menuItems, {
    name: "Капучино",
    sku: "COF-CAP-001",
    category: coffeeCategory.id,
    ingredients: [arabica.id, milk.id],
    kind: "coffee",
    volume_ml: 350,
    price: 290,
    stock: 50,
    image_url: "",
    deleted: false,
  });

  const flatWhite = saveRecord(menuItems, {
    name: "Флэт уайт",
    sku: "COF-FW-002",
    category: coffeeCategory.id,
    ingredients: [arabica.id, milk.id],
    kind: "coffee",
    volume_ml: 250,
    price: 310,
    stock: 40,
    image_url: "",
    deleted: false,
  });

  saveRecord(menuItems, {
    name: "Латте на овсяном",
    sku: "COF-OAT-003",
    category: coffeeCategory.id,
    ingredients: [arabica.id, oatMilk.id],
    kind: "coffee",
    volume_ml: 450,
    price: 390,
    stock: 25,
    image_url: "",
    deleted: false,
  });

  saveRecord(menuItems, {
    name: "Какао",
    sku: "DR-CACAO-004",
    category: teaCategory.id,
    ingredients: [milk.id, chocolate.id],
    kind: "tea",
    volume_ml: 350,
    price: 260,
    stock: 30,
    image_url: "",
    deleted: false,
  });

  saveRecord(menuItems, {
    name: "Шоколадный чизкейк",
    sku: "DES-CH-005",
    category: dessertCategory.id,
    ingredients: [chocolate.id],
    kind: "dessert",
    volume_ml: 0,
    price: 340,
    stock: 12,
    image_url: "",
    deleted: false,
  });

  const welcomePromo = saveRecord(promoCodes, {
    code: "COFFEE10",
    discount_percent: 10,
    active: true,
    deleted: false,
  });

  saveRecord(profiles, {
    user: customer.id,
    nickname: "CoffeeLover",
    favorite_drink: "Капучино",
    deleted: false,
  });

  saveRecord(favorites, {
    user: customer.id,
    menu_item: cappuccino.id,
    deleted: false,
  });

  saveRecord(reservations, {
    user: customer.id,
    table: table1.id,
    reserved_at: "2026-09-25 17:00:00.000Z",
    duration_min: 90,
    guests: 2,
    status: "confirmed",
    deleted: false,
  });

  const completedOrder = saveRecord(orders, {
    user: customer.id,
    status: "completed",
    subtotal: 600,
    discount: 60,
    service_fee: 16.2,
    total: 556.2,
    promo_code: welcomePromo.id,
    deleted: false,
  });

  saveRecord(orderItems, {
    order: completedOrder.id,
    menu_item: cappuccino.id,
    quantity: 1,
    unit_price: 290,
    deleted: false,
  });

  saveRecord(orderItems, {
    order: completedOrder.id,
    menu_item: flatWhite.id,
    quantity: 1,
    unit_price: 310,
    deleted: false,
  });

  saveRecord(reviews, {
    user: customer.id,
    menu_item: cappuccino.id,
    rating: 5,
    text: "Мягкий вкус и хорошая молочная текстура.",
    deleted: false,
  });
}, (app) => {
  const customCollections = [
    "favorites",
    "reviews",
    "reservations",
    "order_items",
    "orders",
    "user_profiles",
    "promo_codes",
    "menu_items",
    "cafe_tables",
    "ingredients",
    "suppliers",
    "categories",
  ];

  for (const name of customCollections) {
    try {
      const collection = app.findCollectionByNameOrId(name);
      app.delete(collection);
    } catch (_) {}
  }

  try {
    const users = app.findCollectionByNameOrId("users");
    users.fields.removeByName("full_name");
    users.fields.removeByName("role");
    users.fields.removeByName("deleted");
    users.listRule = null;
    users.viewRule = null;
    users.createRule = "";
    users.updateRule = null;
    users.deleteRule = null;
    app.save(users);
  } catch (_) {}
});
