import '../../domain/entities/item.dart';

class ItemModel extends Item {
  ItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}