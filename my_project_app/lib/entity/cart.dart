class Cart {
  final int cartId;
  final int userId;
  final int productId;
  final int colorId;
  final int sizeId;
  final int boughtAmount;

  const Cart({
    required this.cartId,
    required this.userId,
    required this.productId,
    required this.colorId,
    required this.sizeId,
    required this.boughtAmount,
  });

  factory Cart.fromJSON(Map<String, dynamic> json) {
    return Cart(
      cartId: json["cart_id"],
      userId: json["user_id"],
      productId: json["product_id"],
      colorId: json["color_id"],
      sizeId: json["size_id"],
      boughtAmount: json["amount"],
    );
  }
}
