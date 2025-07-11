import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:teste/src/models/order_model.dart';
import 'package:teste/src/services/utils_services.dart';

class PaymentDialog extends StatelessWidget {
  final OrderModel order;
  final UtilsServices utilsServices = UtilsServices();

  PaymentDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pagamento com Pix',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                QrImageView(
                  data: order.copyAndPaste,
                  version: QrVersions.auto,
                  size: 200,
                ),
                const SizedBox(height: 10),
                Text(
                  'Vencimento: ${utilsServices.formatDatetime(order.overdueDateTime)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Total: ${utilsServices.priceToCurrency(order.total, 2)}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.copyAndPaste));
                    utilsServices.showToast(message: 'Código copiado com sucesso!');
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copiar código Pix'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    side: const BorderSide(width: 2, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
