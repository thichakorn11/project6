class Category {
  final int categoryId;
  final String categoryName;
  final String imageUrl;

  const Category(
      {required this.categoryId,
      required this.categoryName,
      required this.imageUrl});

  factory Category.fromJSON(Map<String, dynamic> json) {
    return Category(
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        imageUrl: json["imageUrl"]);
  }

  get isCircular => null;
}
