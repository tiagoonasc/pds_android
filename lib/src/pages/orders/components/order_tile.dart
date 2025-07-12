import 'package:flutter/material.dart';
import 'package:teste/src/models/order_model.dart';
import 'package:teste/src/services/utils_services.dart';
import 'package:teste/src/pages/common_widgets/payment_dialog.dart';

class OrderTile extends StatelessWidget {
  final OrderModel order;
  final UtilsServices utilsServices = UtilsServices();

  OrderTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: Text('Pedido: ${order.id.substring(0, 6)}...'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_getStatusText(order.status)}'),
            Text('Total: ${utilsServices.priceToCurrency(order.total, 2)}'),
          ],
        ),
        children: [
          if (order.status == 'pending_payment')
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CardPaymentDialog(order: order),
                  );
                },
                icon: const Icon(Icons.pix, color: Colors.green),
                label: const Text(
                  'Pagar com Pix',
                  style: TextStyle(color: Colors.green),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Aguardando pagamento';
      case 'paid':
        return 'Pago';
      case 'delivered':
        return 'Entregue';
      default:
        return 'Desconhecido';
    }
  }
}
