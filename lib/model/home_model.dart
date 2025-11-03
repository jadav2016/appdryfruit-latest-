class Product {
  final int id;
  final String title;
  final String? slug;                 // Nullable
  final String? image;                // Nullable
  final String? link;                 // Nullable
  final String? thumbnailImage;       // Nullable
  final double? price;                // Nullable
  final int? discount;                // Nullable
  final Category? category;           // Nullable
  final double? averageReview;        // Nullable
  final int? totalReviews;            // Nullable
  final double? discountedPrice;      // Nullable
  final double? priceWithTax;         // Nullable
  final double? discountedPriceWithTax; // Nullable

  Product({
    required this.id,
    required this.title,
    this.slug,
    this.image,
    this.link,
    this.thumbnailImage,
    this.price,
    this.discount,
    this.category,
    this.averageReview,
    this.totalReviews,
    this.discountedPrice,
    this.priceWithTax,
    this.discountedPriceWithTax,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'],
      image: json['image'],
      link: json['link'],
      thumbnailImage: json['thumbnail_image'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      discount: json['discount'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      averageReview: json['average_review'] != null
          ? double.tryParse(json['average_review'].toString())
          : null,
      totalReviews: json['total_reviews'],
      discountedPrice: json['discounted_price'] != null
          ? double.tryParse(json['discounted_price'].toString())
          : null,
      priceWithTax: json['price_with_tax'] != null
          ? double.tryParse(json['price_with_tax'].toString())
          : null,
      discountedPriceWithTax: json['discounted_price_with_tax'] != null
          ? double.tryParse(json['discounted_price_with_tax'].toString())
          : null,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? parent;
  final String? thumbnailImage;

  Category({
    required this.id,
    required this.name,
    this.parent,
    this.thumbnailImage,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      parent: json['parent'],
      thumbnailImage: json['thumbnail_image'],
    );
  }
}

class Week {
  final int id;
  final String title;
  final String slug;
  final String thumbnailImage;
  final String price;
  final int discount;
  final Category category;
  final double averageReview;
  final int totalReviews;
  final double discountedPrice;
  final double priceWithTax;
  final double discountedPriceWithTax;
  final int totalSales;
  final int quantity;
  final String? productDealExpireAt;

  Week({
    required this.id,
    required this.title,
    required this.slug,
    required this.thumbnailImage,
    required this.price,
    required this.discount,
    required this.category,
    required this.averageReview,
    required this.totalReviews,
    required this.discountedPrice,
    required this.priceWithTax,
    required this.discountedPriceWithTax,
    required this.totalSales,
    required this.quantity,
    required this.productDealExpireAt
  });

  factory Week.fromJson(Map<String, dynamic> json) {
    return Week(
        id: json['id'],
        title: json['title'],
        slug: json['slug'],
        thumbnailImage: json['thumbnail_image'],
        price: json['price'],
        discount: json['discount'],
        category: Category.fromJson(json['category']),
        averageReview: (json['average_review'] as num).toDouble(),
        totalReviews: json['total_reviews'],
        discountedPrice: (json['discounted_price'] as num).toDouble(),
        priceWithTax: (json['price_with_tax'] as num).toDouble(),
        discountedPriceWithTax: (json['discounted_price_with_tax'] as num).toDouble(),
        totalSales: json['total_sales'],
        quantity: json['quantity'],
        productDealExpireAt: json['product_deal_expire_at']
    );
  }
}

class ApiResponse {
  final List<Product> topDiscountedProducts;
  final List<Product> newProducts;
  final List<Product> mostSales;
  final List<Product> slideList;
  final List<Category> categories;
  final List<Product> offerProducts;
  final List<Product> festivalSpecialList;
  final List<Week> week;

  ApiResponse({
    required this.topDiscountedProducts,
    required this.newProducts,
    required this.mostSales,
    required this.offerProducts,
    required this.categories,
    required this.slideList,
    required this.festivalSpecialList,
    required this.week
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      topDiscountedProducts: (json['top_discounted_products'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      slideList: (json['slides'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      newProducts: (json['new_products'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      offerProducts: (json['offer_items'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      mostSales: (json['most_sales'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      categories: (json['categories'] as List)
          .map((item) => Category.fromJson(item))
          .toList(),
      festivalSpecialList: (json['festival_special'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      week: (json['week'] as List)
          .map((item) => Week.fromJson(item))
          .toList(),
    );
  }
}
