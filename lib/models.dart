import 'dart:convert';
import 'package:velocity_x/velocity_x.dart';

class Cart {
  // catalog field
  late Catalog _catalog;

  // Collection of IDs - store Ids of each item
  final List<int> _itemIds = [];

  // Get Catalog
  Catalog get catalog => _catalog;

  set catalog(Catalog newCatalog) {
    _catalog = newCatalog;
  }

  // Get items in the cart
  List<Item> get items => _itemIds.map((id) => _catalog.getById(id)).toList();

  // Get total price
  num get totalPrice =>
      items.fold(0, (total, current) => total + current.price);
}

class AddMutation extends VxMutation<Store> {
  final Item item;

  AddMutation(this.item);
  @override
  perform() {
    store!.cart._itemIds.add(item.id);
  }
}

class RemoveMutation extends VxMutation<Store> {
  final Item item;

  RemoveMutation(this.item);
  @override
  perform() {
    store!.cart._itemIds.remove(item.id);
  }
}

class Catalog {
  static late List<Item> items;

  // Get Item by ID
  Item getById(int id) =>
      items.firstWhere((element) => element.id == id, orElse: null);

  // Get Item by position
  Item getByPosition(int pos) => items[pos];
}

class Item {
  final int id;
  final String name;
  final String desc;
  final num price;
  int quantity;
  final String color;
  final String image;

  num get totalPrice => price * quantity;

  Item({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.color,
    required this.image,
    this.quantity = 1,
  });

  Item copyWith({
    required int id,
    required String name,
    required String desc,
    required num price,
    required String color,
    int quantity = 1,
    required String image,
  }) {
    return Item(
      id: id,
      name: name,
      desc: desc,
      price: price,
      color: color,
      image: image,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'price': price,
      'color': color,
      'image': image,
      'quantity': quantity,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    // if (map == null) return null;

    return Item(
      id: map['id'],
      name: map['name'],
      desc: map['desc'],
      price: map['price'],
      color: map['color'],
      image: map['image'],
      quantity: map['quantity'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Item(id: $id, name: $name, desc: $desc, price: $price, color: $color, image: $image)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Item &&
        o.id == id &&
        o.name == name &&
        o.desc == desc &&
        o.price == price &&
        o.color == color &&
        o.image == image;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        desc.hashCode ^
        price.hashCode ^
        color.hashCode ^
        image.hashCode;
  }
}

class SearchMutation extends VxMutation<Store> {
  final String query;

  SearchMutation(this.query);
  @override
  perform() {
    if (query.isNotEmpty) {
      store!.items = Catalog.items
          .where((el) => el.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      store!.items = Catalog.items;
    }
  }
}

class ChangeQuantity extends VxMutation<Store> {
  final Item catalog;
  final int quantity;

  ChangeQuantity(this.catalog, this.quantity);
  @override
  perform() {
    catalog.quantity = quantity;
  }
}

class Store extends VxStore {
  late Catalog catalog;
  late Cart cart;
  late VxNavigator navigator;
  late List<Item> items;

  MyStore() {
    catalog = Catalog();
    cart = Cart();
    cart.catalog = catalog;
  }
}
