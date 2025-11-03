class ProductDetail {
  final int? id;
  final String? sku;
  final String? title;
  final String? slug;
  final String? manufacturerBrand;
  final String? shortDescription;
  final Category? category;
  final List<ProductImage>? images;
  final String? description;
  final String? thumbnailImage;
  final double? averageReview;
  final String? videoLink;
  final int? quantity;
  final String? price;
  final int? discount;
  final int? oneStar;
  final int? twoStar;
  final int? threeStar;
  final int? fourStar;
  final int? fiveStar;
  final String? promotional;
  final int? totalReviews;
  final List<ProductWeight>? productWeight;
  final List<ProductReview>? productReview;
  final double? priceWithTax;
  final double? discountedPriceWithTax;
  final double? discountedPrice;

  ProductDetail({
    this.id,
    this.sku,
    this.title,
    this.slug,
    this.manufacturerBrand,
    this.shortDescription,
    this.category,
    this.images,
    this.description,
    this.thumbnailImage,
    this.averageReview,
    this.videoLink,
    this.quantity,
    this.price,
    this.discount,
    this.promotional,
    this.totalReviews,
    this.productWeight,
    this.productReview,
    this.priceWithTax,
    this.discountedPriceWithTax,
    this.discountedPrice,
    this.oneStar,
    this.twoStar,
    this.threeStar,
    this.fourStar,
    this.fiveStar,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] as int?,
      sku: json['sku'] as String?,
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      manufacturerBrand: json['manufacturer_brand'] as String?,
      shortDescription: json['short_description'] as String?,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e))
          .toList(),
      description: json['description'] as String?,
      thumbnailImage: json['thumbnail_image'] as String?,
      averageReview: (json['average_review'] as num?)?.toDouble(),
      videoLink: json['video_link'] as String?,
      quantity: json['quantity'] as int?,
      price: json['price']?.toString(),
      discount: json['discount'] as int?,
      promotional: json['promotional'] as String?,
      totalReviews: json['total_reviews'] as int?,
      oneStar: json['one_star'] as int?,
      twoStar: json['two_star'] as int?,
      threeStar: json['three_star'] as int?,
      fourStar: json['four_star'] as int?,
      fiveStar: json['five_star'] as int?,
      productWeight: (json['product_weight'] as List<dynamic>?)
          ?.map((x) => ProductWeight.fromJson(x))
          .toList(),
      productReview: (json['product_review'] as List<dynamic>?)
          ?.map((x) => ProductReview.fromJson(x))
          .toList(),
      priceWithTax: (json['price_with_tax'] as num?)?.toDouble(),
      discountedPriceWithTax:
      (json['discounted_price_with_tax'] as num?)?.toDouble(),
      discountedPrice: (json['discounted_price'] as num?)?.toDouble(),
    );
  }
}
class ProductImage {
  final int? id;
  final String? image;

  ProductImage({
    this.id,
    this.image,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int?,
      image: json['image'] as String?,
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
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      parent: json['parent'],
      thumbnailImage: json['thumbnail_image'],
    );
  }
}

class ProductWeight {
  final int id;
  final String price;
  final Weight weight;
  final double priceWithTax;
  final double discountedPriceWithTax;
  final double discountedPrice; // Added field for discounted price

  ProductWeight({
    required this.id,
    required this.price,
    required this.weight,
    required this.priceWithTax,
    required this.discountedPriceWithTax,
    required this.discountedPrice,
  });

  factory ProductWeight.fromJson(Map<String, dynamic> json) {
    return ProductWeight(
      id: json['id'] ?? 0,
      price: json['price'] ?? "",
      weight: Weight.fromJson(json['weight'] ?? {}),
      priceWithTax: (json['price_with_tax'] as num?)?.toDouble() ?? 0.0,
      discountedPriceWithTax:
          (json['discounted_price_with_tax'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discounted_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Weight {
  final int id;
  final String name;

  Weight({
    required this.id,
    required this.name,
  });

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
    );
  }
}

class ProductReview {
  final Client client;
  final int rate;
  final String comment;
  final DateTime createdOn;

  ProductReview({
    required this.client,
    required this.rate,
    required this.comment,
    required this.createdOn,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      client: Client.fromJson(json['client'] ?? {}),
      rate: json['rate'] ?? 0,
      comment: json['comment'] ?? "",
      createdOn: json['created_on'] != null && json['created_on'] != ""
          ? DateTime.parse(json['created_on'])
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class Client {
  final int id;
  final String username;
  final String email;
  final String? profileImage;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;

  Client({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      profileImage: json['profile_image'],
      phoneNumber: json['phone_number'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
    );
  }
}
