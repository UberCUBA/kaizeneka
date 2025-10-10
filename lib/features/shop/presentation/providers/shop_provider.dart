import 'package:flutter/material.dart';
import '../../domain/usecases/get_items.dart';
import '../../domain/entities/item.dart';

class ShopProvider with ChangeNotifier {
  final GetItems getItems;
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;

  ShopProvider(this.getItems);

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await getItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}