import 'package:teste/src/models/cart_item_model.dart';
import 'package:teste/src/models/item_model.dart';
import 'package:teste/src/models/order_model.dart';
import 'package:teste/src/models/user_model.dart';

ItemModel cimento = ItemModel(
  description: 'Cimento Votoran o melhor para sua obra',
  imgUrl: 'assets/materiais/cimento.png',
  itemName: 'Cimento',
  price: 42.90,
  unit: 'RS',
  id: '1',
);
ItemModel furadeira = ItemModel(
  description: 'Furadeira de auto rendimento',
  imgUrl: 'assets/materiais/furadeira.png',
  itemName: 'Furadeira',
  price: 239.90,
  unit: 'RS',
  id: '2',
);
ItemModel piso = ItemModel(
  description: 'Porcelanato retificado',
  imgUrl: 'assets/materiais/piso.png',
  itemName: 'Porcelanato',
  price: 80.90,
  unit: 'm2',
  id: '32',
);
ItemModel tijolo = ItemModel(
  description: 'Tijolo catarina, sua paredes no padrao',
  imgUrl: 'assets/materiais/tijolo.png',
  itemName: 'Tijolo',
  price: 00.90,
  unit: 'RS',
  id: '1000',
);
ItemModel tinta = ItemModel(
  description: 'Sua obra com mais viva com as cores Suvinil',
  imgUrl: 'assets/materiais/tinta.png',
  itemName: 'Tinta',
  price: 630.00,
  unit: 'RS',
  id: '8',
);
ItemModel torneira = ItemModel(
  description: 'Torneira Docol, garantia e qualidade compravadas',
  imgUrl: 'assets/materiais/torneira.png',
  itemName: 'Torneira',
  price: 357.90,
  unit: 'RS',
  id: '9',
);

List<ItemModel> items = [cimento, furadeira, piso, tijolo, tinta, torneira];

List<String> categories = [
  'Materiais de construção', 
  'Metais',
  'Pintura',
  'Pisos',
  'Ferramentas',
];

List<CartItemModel> cartItems = [
  CartItemModel(
    item: cimento, 
    quantity: 5,
    ),
  CartItemModel(
    item: furadeira, 
    quantity: 1,
    ),
  CartItemModel(
    item: piso, 
    quantity: 32,
    ),
];
  UserModel user = UserModel(
  phone: '51 9 98161-0808',
  cpf: '999.999.999-99',
  email: 'Tiago@email.com',
  name: 'Tiago Nascimento',
  password: '',
);

List<OrderModel> orders = [
   // Pedido 01
  OrderModel(
    copyAndPaste: 'q1w2e3r4t5y6',
    createdDateTime: DateTime.parse(
      '2025-06-14 23:00:10.458',
    ),
    overdueDateTime: DateTime.parse(
      '2025-06-08 11:00:10.458',
    ),
    id: 'asd6a54da6s2d1',
    status: 'pending_payment',
    total: 85.80,
    items: [
      CartItemModel(
        item: cimento,
        quantity: 2,
      ),
             CartItemModel(
        item: furadeira,
        quantity: 3,
         ),
    ],
  ),
  // Pedido 02
  OrderModel(
    copyAndPaste: 'q1w2e3r4t5y6',
    createdDateTime: DateTime.parse(
      '2025-06-08 10:00:10.458',
    ),
    overdueDateTime: DateTime.parse(
      '2025-09-08 11:00:10.458',
    ),
    id: 'a65s4d6a2s1d6a5s',
    status: 'delivered',
    total: 715.80,
    items: [
      CartItemModel(
        item: torneira,
        quantity: 1,
      ),
    ],
  ),
];
