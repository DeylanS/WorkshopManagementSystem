class Rating {
  final String ratingId;
  final String ownerId;
  final String foremanId;
  final int stars;
  final String comment;

  Rating({
    required this.ratingId,
    required this.ownerId,
    required this.foremanId,
    required this.stars,
    required this.comment,
  });

  factory Rating.fromMap(Map<String, dynamic> data, String id) {
    return Rating(
      ratingId: id,
      ownerId: data['ownerID'] ?? '',
      foremanId: data['foremanID'] ?? '',
      stars:
          (data['stars'] is int)
              ? data['stars']
              : (data['stars'] as num).round(),
      comment: data['comment'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerID': ownerId,
      'foremanID': foremanId,
      'stars': stars,
      'comment': comment,
    };
  }
}
