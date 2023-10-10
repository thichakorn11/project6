// ignore_for_file: camel_case_types

class Category_entity {
  final int categoryId;
  final String categoryName;
  final String imageUrl;

  const Category_entity({
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
  });

  factory Category_entity.fromJSON(Map<String, dynamic> json) {
    return Category_entity(
      categoryId: json["category_id"],
      categoryName: json["category_name"],
      imageUrl: json["imageUrl"],
    );
  }
}
