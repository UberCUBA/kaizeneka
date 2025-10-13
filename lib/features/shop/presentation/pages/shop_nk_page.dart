import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/payment_service.dart';
import '../providers/shop_provider.dart';
import '../widgets/item_card.dart';
import '../../domain/entities/item.dart';
import 'payment_webview_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ShopNkPage extends StatefulWidget {
  const ShopNkPage({super.key});

  @override
  _ShopNkPageState createState() => _ShopNkPageState();
}

class _ShopNkPageState extends State<ShopNkPage> {
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().fetchItems();
    });
  }

  Future<void> _buyItem(Item item) async {
    print('[PAYMENT] _buyItem called for item: ${item.name}, price: ${item.price}');

    // Mostrar loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procesando pago...'),
          backgroundColor: Colors.blue,
        ),
      );
    }

    try {
      print('[PAYMENT] Starting payment process...');

      // Obtener userId del AuthProvider
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id ?? 'user_unknown';

      print('[PAYMENT] User ID: $userId');

      // Crear pago en el backend
      print('[PAYMENT] Calling createPayment...');
      final paymentResponse = await _paymentService.createPayment(
        itemId: item.id,
        itemName: item.name,
        amount: item.price,
        userId: userId,
      );

      print('[PAYMENT] Payment response received: $paymentResponse');

      // Verificar que tenemos la URL de pago
      if (!paymentResponse.containsKey('paymentUrl')) {
        throw 'Respuesta de pago inválida: falta paymentUrl';
      }

      final paymentUrl = paymentResponse['paymentUrl'] as String;
      print('[PAYMENT] Payment URL: $paymentUrl');

      if (paymentUrl.isEmpty || !paymentUrl.startsWith('http')) {
        throw 'URL de pago inválida: $paymentUrl';
      }

      // Mostrar WebView para completar el pago
      if (mounted) {
        print('[PAYMENT] Opening WebView with URL: $paymentUrl');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentWebViewPage(paymentUrl: paymentUrl),
          ),
        );
      }

    } catch (e) {
      print('[PAYMENT] Error in _buyItem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Shop NK', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return ItemCard(
                item: item,
                onBuy: () => _buyItem(item),
              );
            },
          );
        },
      ),
    );
  }
}