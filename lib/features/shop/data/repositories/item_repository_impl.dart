import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  @override
  Future<List<Item>> getItems() async {
    // Datos ficticios
    await Future.delayed(const Duration(seconds: 1)); // Simular delay de API
    return [
      ItemModel(
        id: '1',
        name: 'Camiseta NK',
        description: 'Camiseta oficial de Kaizeneka con diseño exclusivo.',
        price: 3,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ItemModel(
        id: '2',
        name: 'Taza NK',
        description: 'Taza para café con logo de Kaizeneka.',
        price: 2,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ItemModel(
        id: '3',
        name: 'Gorra NK',
        description: 'Gorra deportiva con estampado NK.',
        price: 18.75,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ItemModel(
        id: '4',
        name: 'Libro de Misiones',
        description: 'Guía completa de misiones diarias.',
        price: 2,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ItemModel(
        id: '5',
        name: 'Póster Motivacional',
        description: 'Póster para motivarte en tus metas.',
        price: 1,
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }
}