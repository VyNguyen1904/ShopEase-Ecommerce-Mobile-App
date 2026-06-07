class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      iconUrl: json['iconUrl'],
    );
  }
}
