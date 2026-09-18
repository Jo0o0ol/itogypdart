import 'package:flutter/material.dart';

import '../models/entity_config.dart';
import 'generic_crud_screen.dart';

const menuItemConfig = EntityConfig(
  collection: 'menu_items',
  title: 'Позиции меню',
  displayField: 'name',
  fields: [
    FieldConfig(
      name: 'name',
      label: 'Название',
      kind: FieldKind.text,
      required: true,
    ),
    FieldConfig(
      name: 'sku',
      label: 'Код',
      kind: FieldKind.text,
      required: true,
    ),
    FieldConfig(
      name: 'category',
      label: 'Категория',
      kind: FieldKind.relation,
      required: true,
      relationCollection: 'categories',
    ),
    FieldConfig(
      name: 'ingredients',
      label: 'Ингредиенты',
      kind: FieldKind.multiRelation,
      relationCollection: 'ingredients',
    ),
    FieldConfig(
      name: 'kind',
      label: 'Тип: coffee/tea/dessert/food/beans',
      kind: FieldKind.text,
      required: true,
    ),
    FieldConfig(
      name: 'volume_ml',
      label: 'Объём, мл',
      kind: FieldKind.number,
    ),
    FieldConfig(
      name: 'price',
      label: 'Цена',
      kind: FieldKind.number,
      required: true,
    ),
    FieldConfig(
      name: 'stock',
      label: 'Доступно порций',
      kind: FieldKind.number,
      required: true,
    ),
    FieldConfig(
      name: 'image_url',
      label: 'URL изображения',
      kind: FieldKind.text,
    ),
  ],
);

class MenuItemAdminScreen extends StatelessWidget {
  const MenuItemAdminScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const GenericCrudScreen(config: menuItemConfig);
}
