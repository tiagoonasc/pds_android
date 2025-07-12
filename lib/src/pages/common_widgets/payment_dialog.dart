import 'package:flutter/material.dart';
import 'package:teste/src/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardPaymentDialog extends StatefulWidget {
  final OrderModel order;

  const CardPaymentDialog({super.key, required this.order});

  @override
  State<CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<CardPaymentDialog> {
  int _installments = 1;
  bool _isProcessing = false;

  void _payWithCard() async {
    setState(() => _isProcessing = true);

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.order.id)
        .update({
      'status': 'paid',
      'paymentType': 'card',
      'installments': _installments,
    });

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pagamento com Cartão'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Selecione a quantidade de parcelas:'),
          const SizedBox(height: 10),
          DropdownButton<int>(
            value: _installments,
            items: List.generate(6, (i) {
              final parcelas = i + 1;
              return DropdownMenuItem(
                value: parcelas,
                child: Text('$parcelas x'),
              );
            }),
            onChanged: (value) {
              if (value != null) setState(() => _installments = value);
            },
          ),
        ],
      ),
      actions: [
        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _payWithCard,
            child: const Text('Confirmar'),
          ),
        ],
      ],
    );
  }
}
