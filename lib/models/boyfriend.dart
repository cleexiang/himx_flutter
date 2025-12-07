class Boyfriend {
  final String id;
  final String name;
  final String imageUrl;
  final String? videoUrl;
  final String description;

  Boyfriend({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.videoUrl,
    required this.description,
  });

  factory Boyfriend.fromJson(Map<String, dynamic> json) {
    return Boyfriend(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      videoUrl: json['videoUrl'] as String?,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'description': description,
    };
  }
}
