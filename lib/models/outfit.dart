/// Outfit Model - Clothing and accessories for AI characters
class Outfit {
  final String id;
  final String name; // Outfit name
  final String description; // Description
  final OutfitCategory category; // Category
  final String thumbnailUrl; // Thumbnail image
  final String? previewUrl; // Full preview image
  final OutfitRarity rarity; // Rarity level
  final int price; // Price (0 for free)
  final bool isUnlocked; // Whether user has unlocked
  final bool isLimited; // Limited edition
  final DateTime? availableUntil; // Available until (for limited items)
  final List<String> tags; // Tags for filtering
  final Map<String, dynamic>? aiPrompt; // AI generation prompt parameters

  Outfit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    this.previewUrl,
    required this.rarity,
    this.price = 0,
    this.isUnlocked = false,
    this.isLimited = false,
    this.availableUntil,
    this.tags = const [],
    this.aiPrompt,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: OutfitCategory.values.firstWhere(
        (e) => e.toString() == 'OutfitCategory.${json['category']}',
        orElse: () => OutfitCategory.casual,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String,
      previewUrl: json['previewUrl'] as String?,
      rarity: OutfitRarity.values.firstWhere(
        (e) => e.toString() == 'OutfitRarity.${json['rarity']}',
        orElse: () => OutfitRarity.common,
      ),
      price: json['price'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isLimited: json['isLimited'] as bool? ?? false,
      availableUntil: json['availableUntil'] != null ? DateTime.parse(json['availableUntil'] as String) : null,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      aiPrompt: json['aiPrompt'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.toString().split('.').last,
      'thumbnailUrl': thumbnailUrl,
      'previewUrl': previewUrl,
      'rarity': rarity.toString().split('.').last,
      'price': price,
      'isUnlocked': isUnlocked,
      'isLimited': isLimited,
      'availableUntil': availableUntil?.toIso8601String(),
      'tags': tags,
      'aiPrompt': aiPrompt,
    };
  }

  Outfit copyWith({
    String? id,
    String? name,
    String? description,
    OutfitCategory? category,
    String? thumbnailUrl,
    String? previewUrl,
    OutfitRarity? rarity,
    int? price,
    bool? isUnlocked,
    bool? isLimited,
    DateTime? availableUntil,
    List<String>? tags,
    Map<String, dynamic>? aiPrompt,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      rarity: rarity ?? this.rarity,
      price: price ?? this.price,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isLimited: isLimited ?? this.isLimited,
      availableUntil: availableUntil ?? this.availableUntil,
      tags: tags ?? this.tags,
      aiPrompt: aiPrompt ?? this.aiPrompt,
    );
  }
}

/// Outfit categories
enum OutfitCategory {
  casual, // Casual wear
  formal, // Formal wear
  traditional, // Traditional clothing (kimono, hanfu, etc.)
  sportswear, // Sportswear
  pajamas, // Sleepwear
  costume, // Cosplay/costume
  seasonal, // Seasonal (summer, winter, etc.)
  wedding, // Wedding dress
  fantasy, // Fantasy style
}

extension OutfitCategoryExtension on OutfitCategory {
  String get displayName {
    switch (this) {
      case OutfitCategory.casual:
        return 'Casual';
      case OutfitCategory.formal:
        return 'Formal';
      case OutfitCategory.traditional:
        return 'Traditional';
      case OutfitCategory.sportswear:
        return 'Sportswear';
      case OutfitCategory.pajamas:
        return 'Sleepwear';
      case OutfitCategory.costume:
        return 'Costume';
      case OutfitCategory.seasonal:
        return 'Seasonal';
      case OutfitCategory.wedding:
        return 'Wedding';
      case OutfitCategory.fantasy:
        return 'Fantasy';
    }
  }

  String get icon {
    switch (this) {
      case OutfitCategory.casual:
        return '👕';
      case OutfitCategory.formal:
        return '👔';
      case OutfitCategory.traditional:
        return '👘';
      case OutfitCategory.sportswear:
        return '⚽';
      case OutfitCategory.pajamas:
        return '🛌';
      case OutfitCategory.costume:
        return '🎭';
      case OutfitCategory.seasonal:
        return '🌸';
      case OutfitCategory.wedding:
        return '💒';
      case OutfitCategory.fantasy:
        return '✨';
    }
  }
}

/// Outfit rarity levels
enum OutfitRarity {
  common, // Common
  rare, // Rare
  epic, // Epic
  legendary, // Legendary
}

extension OutfitRarityExtension on OutfitRarity {
  String get displayName {
    switch (this) {
      case OutfitRarity.common:
        return 'Common';
      case OutfitRarity.rare:
        return 'Rare';
      case OutfitRarity.epic:
        return 'Epic';
      case OutfitRarity.legendary:
        return 'Legendary';
    }
  }

  String get color {
    switch (this) {
      case OutfitRarity.common:
        return '#B0B0B0'; // Gray
      case OutfitRarity.rare:
        return '#4A90E2'; // Blue
      case OutfitRarity.epic:
        return '#9B59B6'; // Purple
      case OutfitRarity.legendary:
        return '#F39C12'; // Gold
    }
  }
}

/// Character outfit state - tracks what the character is currently wearing
class CharacterOutfit {
  final String roleId;
  final String? currentOutfitId; // Currently equipped outfit
  final List<String> ownedOutfitIds; // All owned outfits
  final DateTime? lastChanged; // Last outfit change time

  CharacterOutfit({
    required this.roleId,
    this.currentOutfitId,
    this.ownedOutfitIds = const [],
    this.lastChanged,
  });

  factory CharacterOutfit.fromJson(Map<String, dynamic> json) {
    return CharacterOutfit(
      roleId: json['roleId'] as String,
      currentOutfitId: json['currentOutfitId'] as String?,
      ownedOutfitIds: (json['ownedOutfitIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      lastChanged: json['lastChanged'] != null ? DateTime.parse(json['lastChanged'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'currentOutfitId': currentOutfitId,
      'ownedOutfitIds': ownedOutfitIds,
      'lastChanged': lastChanged?.toIso8601String(),
    };
  }

  CharacterOutfit copyWith({
    String? roleId,
    String? currentOutfitId,
    List<String>? ownedOutfitIds,
    DateTime? lastChanged,
  }) {
    return CharacterOutfit(
      roleId: roleId ?? this.roleId,
      currentOutfitId: currentOutfitId ?? this.currentOutfitId,
      ownedOutfitIds: ownedOutfitIds ?? this.ownedOutfitIds,
      lastChanged: lastChanged ?? this.lastChanged,
    );
  }
}

/// Preset outfits data
class Outfits {
  static List<Outfit> getPresetOutfits() {
    return [
      // Common - Free outfits
      Outfit(
        id: 'casual_01',
        name: 'White T-Shirt',
        description: 'Classic white t-shirt, simple and comfortable',
        category: OutfitCategory.casual,
        thumbnailUrl: 'https://via.placeholder.com/150',
        rarity: OutfitRarity.common,
        price: 0,
        isUnlocked: true,
        tags: ['basic', 'everyday'],
      ),
      Outfit(
        id: 'casual_02',
        name: 'Blue Jeans',
        description: 'Casual denim jeans',
        category: OutfitCategory.casual,
        thumbnailUrl: 'https://via.placeholder.com/150',
        rarity: OutfitRarity.common,
        price: 0,
        isUnlocked: true,
        tags: ['basic', 'everyday'],
      ),

      // Rare outfits
      Outfit(
        id: 'formal_01',
        name: 'Black Suit',
        description: 'Elegant black suit, perfect for formal occasions',
        category: OutfitCategory.formal,
        thumbnailUrl: 'https://via.placeholder.com/150',
        rarity: OutfitRarity.rare,
        price: 100,
        isUnlocked: false,
        tags: ['elegant', 'formal'],
      ),
      Outfit(
        id: 'traditional_01',
        name: 'Kimono',
        description: 'Traditional Japanese kimono',
        category: OutfitCategory.traditional,
        thumbnailUrl: 'https://via.placeholder.com/150',
        rarity: OutfitRarity.rare,
        price: 150,
        isUnlocked: false,
        tags: ['traditional', 'cultural'],
      ),

      // Epic outfits
      Outfit(
        id: 'wedding_01',
        name: 'Wedding Suit',
        description: 'Stunning wedding suit for special moments',
        category: OutfitCategory.wedding,
        thumbnailUrl: 'https://via.placeholder.com/150',
        rarity: OutfitRarity.epic,
        price: 500,
        isUnlocked: false,
        tags: ['wedding', 'romantic'],
      ),

      // Legendary - Limited edition
      Outfit(
        id: 'seasonal_winter_2024',
        name: 'Winter Snow Prince',
        description: 'Limited winter collection 2024',
        category: OutfitCategory.seasonal,
        thumbnailUrl: 'https://via.placeholder.com/150',
        rarity: OutfitRarity.legendary,
        price: 1000,
        isUnlocked: false,
        isLimited: true,
        availableUntil: DateTime(2024, 12, 31),
        tags: ['limited', 'winter', 'snow'],
      ),
    ];
  }
}
