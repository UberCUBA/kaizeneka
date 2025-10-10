import '../entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getItems();
}