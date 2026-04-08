import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String userId;
  final String message;
  final String crop;
  final DateTime createdAt;
  final bool isRead;

  AlertModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.crop,
    required this.createdAt,
    this.isRead = false,
  });

  factory AlertModel.fromMap(Map<String, dynamic> data, String id) {
    return AlertModel(
      id: id,
      userId: data['user_id'] ?? '',
      message: data['message'] ?? '',
      crop: data['crop'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'message': message,
      'crop': crop,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
