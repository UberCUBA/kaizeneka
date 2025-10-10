import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/payment_service.dart';
import '../providers/shop_provider.dart';
import '../widgets/item_card.dart';
import '../../domain/entities/item.dart';

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
      // Obtener userId - por ahora usamos un ID de ejemplo
      // TODO: Integrar con AuthProvider cuando esté disponible
      final userId = 'user_123'; // Temporal hasta integrar AuthProvider

      // Crear pago en el backend
      final paymentResponse = await _paymentService.createPayment(
        itemId: item.id,
        itemName: item.name,
        amount: item.price,
        userId: userId,
      );

      // Abrir URL de pago
      final paymentUrl = paymentResponse['paymentUrl'] as String;

      if (paymentUrl.isEmpty || !paymentUrl.startsWith('http')) {
        throw 'URL de pago inválida: $paymentUrl';
      }

      final uri = Uri.parse(paymentUrl);

      // Mostrar mensaje de redirección
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirigiendo al marketplace de QvaPay...'),
            backgroundColor: Color(0xFF00FF7F),
          ),
        );
      }

      // Pequeña pausa para que el usuario vea el mensaje
      await Future.delayed(const Duration(milliseconds: 500));

      // Para Flutter Web, mostrar diálogo con la URL
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Completar Pago'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Serás redirigido al marketplace de QvaPay para completar tu pago.'),
                  const SizedBox(height: 16),
                  const Text('URL de pago:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(paymentUrl, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    print('[PAYMENT] User clicked "Ir a Pagar"');
                    print('[PAYMENT] Attempting to launch URL: $paymentUrl');

                    try {
                      print('[PAYMENT] Checking if can launch URL...');
                      final canLaunch = await canLaunchUrl(uri);
                      print('[PAYMENT] Can launch result: $canLaunch');

                      if (canLaunch) {
                        print('[PAYMENT] Launching with externalApplication...');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                        print('[PAYMENT] URL launched successfully');
                      } else {
                        print('[PAYMENT] Cannot launch, showing fallback message');
                        // Copiar al portapapeles como fallback
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copia esta URL y ábrela en tu navegador:\n$paymentUrl'),
                              duration: const Duration(seconds: 10),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      print('[PAYMENT] Error launching URL: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al abrir URL: $e\n\nCopia manualmente: $paymentUrl'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 10),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Ir a Pagar'),
                ),
              ],
            );
          },
        );
      }

    } catch (e) {
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