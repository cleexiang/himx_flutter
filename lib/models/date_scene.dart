class DateScene {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final bool isInitialized; // 是否已经初始化过

  DateScene({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
    this.isInitialized = false,
  });

  DateScene copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? videoUrl,
    bool? isInitialized,
  }) {
    return DateScene(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'isInitialized': isInitialized,
    };
  }

  factory DateScene.fromJson(Map<String, dynamic> json) {
    return DateScene(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      isInitialized: json['isInitialized'] ?? false,
    );
  }
}

// 预设场景列表
class DateScenes {
  static List<DateScene> getPresetScenes() {
    return [
      DateScene(
        id: 'cafe',
        name: '咖啡厅',
        description: '温馨浪漫的咖啡时光',
        imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
        videoUrl: null,
      ),
      DateScene(
        id: 'bali_beach',
        name: '巴厘岛海边',
        description: '碧海蓝天，椰林树影',
        imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
        videoUrl: null,
      ),
      DateScene(
        id: 'paris_restaurant',
        name: '巴黎西餐厅',
        description: '浪漫的法式晚餐',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
        videoUrl: null,
      ),
      DateScene(
        id: 'tokyo_night',
        name: '东京夜景',
        description: '璀璨夜色中的浪漫',
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
        videoUrl: null,
      ),
      DateScene(
        id: 'cinema',
        name: '电影院',
        description: '在光影中感受彼此',
        imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
        videoUrl: null,
      ),
      DateScene(
        id: 'park',
        name: '公园漫步',
        description: '在自然中享受宁静时光',
        imageUrl: 'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?w=800',
        videoUrl: null,
      ),
    ];
  }
}
