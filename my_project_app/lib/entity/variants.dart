class ProductVariants {
  final int variantsId;
  final int productId;
  final int sizeId;
  final int colorId;
  final int stock;
  final String sizeName;
  final String colorName;
  final String colorCode;

  const ProductVariants({
    required this.variantsId,
    required this.productId,
    required this.sizeId,
    required this.colorId,
    required this.stock,
    required this.sizeName,
    required this.colorName,
    required this.colorCode,
  });

  factory ProductVariants.fromJSON(Map<String, dynamic> json) {
    return ProductVariants(
      variantsId: json["variant_id"],
      productId: json["product_id"],
      sizeId: json["size_id"],
      colorId: json["color_id"],
      stock: json["stock"],
      sizeName: json["size_name"],
      colorName: json["color_name"],
      colorCode: json["color_code"],
    );
  }
}
