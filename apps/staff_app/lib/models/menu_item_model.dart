
class MenuItemModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final bool isAvailable;
  final String imageUrl;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.isAvailable,
    required this.imageUrl,
  });

  factory MenuItemModel.fromMap(String id, Map<String, dynamic> data) {
    return MenuItemModel(
      id: id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      category: (data['category'] as String?) ?? 'Uncategorized',
      description: data['description'] as String? ?? '',
      isAvailable: data['isAvailale'] as bool? ?? true,
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap()=>{
    'name': name,
    'price': price,
    'category': category,
    'description': description,
    'isAvailable': isAvailable,
    'imageUrl': imageUrl,
  };
}
