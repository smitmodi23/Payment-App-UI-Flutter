class ProductModel {
  static const tblProduct = "Product_tb";
  static const colID = 'id';
  static const colName = 'name';
  static const colQty = 'quantity';
  static const colPrice = 'price';
  static const colTotalPrice = 'totalPrice';
  static const colSelected = 'selected';

  int? id;
  String? name;
  String? quantity;
  String? price;
  String? totalPrice;
  String? selected;

  ProductModel(
      {this.id,
        this.name,
        this.quantity,
        this.price,
        this.totalPrice,
        this.selected
      });

  ProductModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    quantity = map['quantity'];
    price = map['price'];
    totalPrice = map['totalPrice'];
    selected = map['selected'];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colName: name,
      colQty: quantity,
      colPrice: price,
      colTotalPrice: totalPrice,
      colSelected: selected
    };
    if (id != null) {
      map[colID] = id;
    }
    return map;
  }
}
