/// All product data for uploading to Firestore 'products' collection.
///
/// Each [ProductModel] contains complete product information including
/// name, brand, price, image path, badge, category, description,
/// available sizes, colors, rating, review count, and stock flags.
library;

// ─── Product Model ────────────────────────────────────────────────────────────

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String image;
  final String badge; // 'NEW', 'TRENDING', 'SALE', 'BEST SELLER', or ''
  final String category; // 'Men', 'Women', 'Kids', 'Sale'
  final String description;
  final List<String> sizes;
  final List<String> colors; // hex color codes
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isNewArrival;
  final bool inStock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    required this.badge,
    required this.category,
    required this.description,
    required this.sizes,
    required this.colors,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.isNewArrival,
    required this.inStock,
  });

  /// Convert to a Map suitable for Firestore upload.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'image': image,
      'badge': badge,
      'category': category,
      'description': description,
      'sizes': sizes,
      'colors': colors,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
      'inStock': inStock,
    };
  }

  /// Create a ProductModel from a Firestore document map.
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String,
      badge: map['badge'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      sizes: List<String>.from(map['sizes'] as List),
      colors: List<String>.from(map['colors'] as List),
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'] as int,
      isFeatured: map['isFeatured'] as bool,
      isNewArrival: map['isNewArrival'] as bool,
      inStock: map['inStock'] as bool,
    );
  }
}

// ─── All Products ─────────────────────────────────────────────────────────────

const List<ProductModel> allProducts = [
  // ── Men ──────────────────────────────────────────────────────────────────

  ProductModel(
    id: 'p1',
    name: 'Classic Blazer',
    brand: 'LuxeWear',
    price: 89.00,
    image: 'assets/images/Classic blazer.jpg',
    badge: 'BEST SELLER',
    category: 'Men',
    description:
        'A timeless classic blazer tailored for the modern gentleman. '
        'Crafted from premium wool blend fabric with a structured silhouette '
        'and notched lapels for a polished look.',
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    colors: ['#1B2F5E', '#2D2D2D', '#8B7355'],
    rating: 4.8,
    reviewCount: 124,
    isFeatured: true,
    isNewArrival: false,
    inStock: true,
  ),

  ProductModel(
    id: 'p2',
    name: 'Slim Chinos',
    brand: 'UrbanEdge',
    price: 55.00,
    image: 'assets/images/Slim Chinos.jpg',
    badge: '',
    category: 'Men',
    description:
        'Slim-fit chinos made from stretch cotton twill for all-day comfort. '
        'Features a tapered leg, zip fly, and button closure with side '
        'and back pockets.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    colors: ['#C9A84C', '#2D2D2D', '#F5F5DC'],
    rating: 4.5,
    reviewCount: 89,
    isFeatured: true,
    isNewArrival: false,
    inStock: true,
  ),

  ProductModel(
    id: 'p3',
    name: 'Oxford Shirt',
    brand: 'StyleHub',
    price: 48.00,
    image: 'assets/images/Oxford Shirt.jpg',
    badge: 'NEW',
    category: 'Men',
    description:
        'A classic oxford button-down shirt in breathable cotton. '
        'Perfect for both casual and semi-formal occasions with a '
        'regular fit and barrel cuffs.',
    sizes: ['S', 'M', 'L', 'XL'],
    colors: ['#FFFFFF', '#87CEEB', '#1B2F5E'],
    rating: 4.6,
    reviewCount: 203,
    isFeatured: false,
    isNewArrival: true,
    inStock: true,
  ),

  // ── Women ────────────────────────────────────────────────────────────────

  ProductModel(
    id: 'p4',
    name: 'Floral Dress',
    brand: 'LuxeWear',
    price: 65.00,
    image: 'assets/images/Floral Dress.jpg',
    badge: 'TRENDING',
    category: 'Women',
    description:
        'An elegant floral print midi dress with a flattering A-line cut. '
        'Features a V-neckline, short flutter sleeves, and a cinched waist '
        'for a feminine silhouette.',
    sizes: ['XS', 'S', 'M', 'L'],
    colors: ['#FF69B4', '#FFB6C1', '#FFF0F5'],
    rating: 4.9,
    reviewCount: 276,
    isFeatured: true,
    isNewArrival: false,
    inStock: true,
  ),

  ProductModel(
    id: 'p5',
    name: 'Silk Blouse',
    brand: 'UrbanEdge',
    price: 72.00,
    image: 'assets/images/Silk Blouse.jpg',
    badge: '',
    category: 'Women',
    description:
        'A luxurious silk blouse with a relaxed fit and elegant drape. '
        'Features a concealed button placket and long sleeves with '
        'buttoned cuffs for a refined finish.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    colors: ['#FFFFFF', '#1A1A2E', '#D5C5A0'],
    rating: 4.7,
    reviewCount: 158,
    isFeatured: true,
    isNewArrival: false,
    inStock: true,
  ),

  ProductModel(
    id: 'p6',
    name: 'Maxi Skirt',
    brand: 'StyleHub',
    price: 58.00,
    image: 'assets/images/Maxi Skirt.jpg',
    badge: 'NEW',
    category: 'Women',
    description:
        'A flowing maxi skirt in lightweight fabric with a high waistband '
        'and elastic back for a comfortable fit. Features a side slit '
        'and subtle pleating for effortless movement.',
    sizes: ['XS', 'S', 'M', 'L'],
    colors: ['#1A1A2E', '#D5C590', '#8B4513'],
    rating: 4.4,
    reviewCount: 97,
    isFeatured: false,
    isNewArrival: true,
    inStock: true,
  ),

  // ── Kids ─────────────────────────────────────────────────────────────────

  ProductModel(
    id: 'p7',
    name: 'Kids Hoodie',
    brand: 'LuxeWear',
    price: 35.00,
    image: "assets/images/Kid's Hoodie.jpg",
    badge: 'TRENDING',
    category: 'Kids',
    description:
        'A cozy pullover hoodie for kids made from soft fleece-lined cotton. '
        'Features a kangaroo pocket, ribbed cuffs, and an adjustable '
        'drawstring hood for warmth and style.',
    sizes: ['XS', 'S', 'M', 'L'],
    colors: ['#4169E1', '#FF6347', '#32CD32'],
    rating: 4.6,
    reviewCount: 142,
    isFeatured: false,
    isNewArrival: true,
    inStock: true,
  ),

  ProductModel(
    id: 'p8',
    name: 'Kids Jeans',
    brand: 'UrbanEdge',
    price: 30.00,
    image: 'assets/images/Denim Jeans & Jacket.jpg',
    badge: '',
    category: 'Kids',
    description:
        'Durable denim jeans designed for active kids. Features a relaxed '
        'fit with an adjustable elastic waistband, five-pocket styling, '
        'and reinforced knees for extra durability.',
    sizes: ['XS', 'S', 'M', 'L'],
    colors: ['#4169E1', '#1A1A2E', '#708090'],
    rating: 4.3,
    reviewCount: 68,
    isFeatured: false,
    isNewArrival: false,
    inStock: true,
  ),

  // ── Sale ─────────────────────────────────────────────────────────────────

  ProductModel(
    id: 'p9',
    name: 'White Embossed Monogram Co-ord Set',
    brand: 'StyleHub',
    price: 22.00,
    image: 'assets/images/White Embossed Monogram Co-ord Set.jpg',
    badge: 'SALE',
    category: 'Sale',
    description:
        'A stylish co-ord set featuring an embossed monogram pattern '
        'on premium cotton fabric. Includes a relaxed-fit shirt and '
        'matching shorts for a coordinated streetwear look.',
    sizes: ['S', 'M', 'L', 'XL'],
    colors: ['#FFFFFF', '#F5F5DC'],
    rating: 4.2,
    reviewCount: 54,
    isFeatured: false,
    isNewArrival: false,
    inStock: true,
  ),

  ProductModel(
    id: 'p10',
    name: 'WOOD Oversized Tee & Shorts Set',
    brand: 'LuxeWear',
    price: 40.00,
    image: 'assets/images/WOOD Oversized Tee & Shorts Set.jpg',
    badge: 'SALE',
    category: 'Sale',
    description:
        'An oversized tee and shorts set with bold graphic branding. '
        'Made from 100% organic cotton with a drop-shoulder fit tee '
        'and drawstring waist shorts for a relaxed summer vibe.',
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    colors: ['#2D2D2D', '#808080', '#D2B48C'],
    rating: 4.5,
    reviewCount: 112,
    isFeatured: false,
    isNewArrival: true,
    inStock: true,
  ),
];
