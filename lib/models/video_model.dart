class VideoModel {
  final int id;
  final String title;
  final String description;
  final String videoPath;
  final String category;
  final DateTime uploadDate;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoPath,
    required this.category,
    required this.uploadDate,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      videoPath: json['video_path'],
      category: json['category'],
      uploadDate: DateTime.parse(json['upload_date']),
    );
  }
}