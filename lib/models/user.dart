class User {
  final String id;
  final String name;
  final String username;
  final String occupation;
  final List<String> skills;
  final double rating;
  final int reviewCount;
  final String avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.occupation,
    required this.skills,
    required this.rating,
    required this.reviewCount,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      occupation: json['occupation'] as String,
      skills: (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'occupation': occupation,
      'skills': skills,
      'rating': rating,
      'reviewCount': reviewCount,
      'avatarUrl': avatarUrl,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? occupation,
    List<String>? skills,
    double? rating,
    int? reviewCount,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      occupation: occupation ?? this.occupation,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

