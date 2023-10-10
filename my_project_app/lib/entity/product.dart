class Product {
  final int productId;
  final String productName;
  final int categoryId;
  final String categoryName;
  final int price;
  final String imgesUrl;

  const Product({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.imgesUrl,
  });

  factory Product.fromJSON(Map<String, dynamic> json) {
    return Product(
      productId: json["product_id"],
      productName: json["product_name"],
      categoryId: json["category_id"],
      categoryName: json["category_name"],
      price: json["price"],
      imgesUrl: json["imgesUrl"],
    );
  }
}
