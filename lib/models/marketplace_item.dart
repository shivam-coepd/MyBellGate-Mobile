class MarketplaceItem {
  final int id;
  final String title;
  final String? description;
  final String price;
  final String? image;
  final String sellerName;
  final String? unit;

  MarketplaceItem({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.image,
    required this.sellerName,
    this.unit,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['image_urls'] != null) {
      try {
        final List<dynamic> urls = json['image_urls'] is String 
            ? // Note: in real implementation, you might need jsonDecode
              [] 
            : json['image_urls'];
        if (urls.isNotEmpty) {
          imageUrl = urls.first.toString();
        }
      } catch (_) {}
    }

    return MarketplaceItem(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toString() ?? '0',
      image: imageUrl,
      sellerName: json['seller_name'] ?? 'Unknown',
      unit: json['unit'] ?? '',
    );
  }
}
