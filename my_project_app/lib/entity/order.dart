class Order {
  final int userId;
  final int productId;
  final int colorId;
  final int sizeId;
  final int receiptId;
  final int amount;
  final double total;

  Order({
    required this.userId,
    required this.productId,
    required this.colorId,
    required this.sizeId,
    required this.receiptId,
    required this.amount,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId.toString(),
      'product_id': productId.toString(),
      'color_id': colorId.toString(),
      'size_id': sizeId.toString(),
      'receipt_id': receiptId.toString(),
      'amount': amount.toString(),
      'total': total.toString(),
    };
  }
}
