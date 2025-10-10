import 'package:flutter/material.dart';
import '../../domain/entities/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onBuy;

  const ItemCard({
    super.key,
    required this.item,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  item.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF00FF7F),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: onBuy,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Comprar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF7F),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}