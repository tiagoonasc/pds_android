class ItemModel {
  final String id;
  final String itemName;
  final String imgUrl;
  final String unit;
  final double price;
  final String description;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.imgUrl,
    required this.unit,
    required this.price,
    required this.description,
  });


  factory ItemModel.createFromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] ?? '',
      itemName: map['itemName'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
      unit: map['unit'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'imgUrl': imgUrl,
      'unit': unit,
      'price': price,
      'description': description,
    };
  }
}