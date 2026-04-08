import 'package:cloud_firestore/cloud_firestore.dart';

class PriceModel {
  final String id;
  final String mandiId;
  final String crop;
  final double price;
  final DateTime date;
  final DateTime timestamp;

  PriceModel({
    required this.id,
    required this.mandiId,
    required this.crop,
    required this.price,
    required this.date,
    required this.timestamp,
  });

  factory PriceModel.fromMap(Map<String, dynamic> data, String id) {
    return PriceModel(
      id: id,
      mandiId: data['mandi_id'] ?? '',
      crop: data['crop'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mandi_id': mandiId,
      'crop': crop,
      'price': price,
      'date': Timestamp.fromDate(date),
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
