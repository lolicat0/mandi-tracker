import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mandi_model.dart';
import '../models/price_model.dart';
import '../models/alert_model.dart';
import '../models/user_model.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, MandiModel> _mandis = {
    'mandi_001': MandiModel(
      id: 'mandi_001',
      name: 'Amritsar Central Mandi',
      district: 'Amritsar',
      latitude: 31.634,
      longitude: 74.872,
    ),
    'mandi_002': MandiModel(
      id: 'mandi_002',
      name: 'Ludhiana City Market',
      district: 'Ludhiana',
      latitude: 30.901,
      longitude: 75.857,
    ),
    'mandi_003': MandiModel(
      id: 'mandi_003',
      name: 'Jalandhar Krishi Mandi',
      district: 'Jalandhar',
      latitude: 31.326,
      longitude: 75.576,
    ),
  };

  List<PriceModel> _prices = [];

  DatabaseService() {
    _initMandis();
    _initPrices();
  }

  void _initMandis() {
    _firestore.collection('mandis').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final newMandis = <String, MandiModel>{};
        for (var doc in snapshot.docs) {
          newMandis[doc.id] = MandiModel.fromMap(doc.data(), doc.id);
        }
        _mandis = newMandis;
        notifyListeners();
      } else {
        // Seed initial mandis to Firestore
        for (var mandi in _mandis.values) {
          _firestore.collection('mandis').doc(mandi.id).set(mandi.toMap());
        }
      }
    });
  }

  void _initPrices() {
    pricesStream.listen((newPrices) {
      _prices = newPrices;
      notifyListeners();
    });
  }

  List<MandiModel> get mandis => _mandis.values.toList();
  List<PriceModel> get prices => List.unmodifiable(_prices);

  Stream<List<PriceModel>> get pricesStream {
    return _firestore
        .collection('prices')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PriceModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addPrice(PriceModel price) async {
    await _firestore.collection('prices').doc(price.id).set(price.toMap());
  }

  MandiModel getMandi(String id) {
    return _mandis[id] ??
        MandiModel(
          id: '',
          name: 'Unknown Data',
          district: 'Unknown',
          latitude: 0,
          longitude: 0,
        );
  }

  // Helper method for AI mock prediction
  String getMockPrediction(String crop) {
    if (crop.toLowerCase() == 'wheat') return "Prices stable today";
    if (crop.toLowerCase() == 'rice') return "Prices likely to increase";
    return "Prices likely to drop soon";
  }

  // Mock Crop Quality Scanner response
  Map<String, dynamic> analyzeCropQuality(String crop) {
    // Simulate AI analysis determining a random grade
    final grades = ['A', 'B', 'B', 'C'];
    grades.shuffle();
    final grade = grades.first;

    // Find latest price for this crop to base our estimate on
    final matchingPrices = _prices
        .where((p) => p.crop.toLowerCase() == crop.toLowerCase())
        .toList();
    double basePrice = matchingPrices.isNotEmpty
        ? matchingPrices.first.price
        : 2000.0;

    // Find best mandi for this crop
    String bestMandiId = _mandis.keys.first;
    if (matchingPrices.isNotEmpty) {
      bestMandiId = matchingPrices.first.mandiId;
      double highestPrice = matchingPrices.first.price;
      for (var p in matchingPrices) {
        if (p.price > highestPrice) {
          highestPrice = p.price;
          bestMandiId = p.mandiId;
        }
      }
    }

    double minPrice;
    double maxPrice;

    switch (grade) {
      case 'A':
        minPrice = basePrice * 1.05;
        maxPrice = basePrice * 1.15;
        break;
      case 'B':
        minPrice = basePrice * 0.95;
        maxPrice = basePrice * 1.05;
        break;
      case 'C':
      default:
        minPrice = basePrice * 0.80;
        maxPrice = basePrice * 0.90;
        break;
    }

    return {
      'grade': grade,
      'minPrice': minPrice.floorToDouble(),
      'maxPrice': maxPrice.ceilToDouble(),
      'bestMandiId': bestMandiId,
      'recommendation': grade == 'A'
          ? 'Sell within the next 48 hours for maximum profit.'
          : grade == 'B'
          ? 'Good quality. Consider selling soon before prices drop.'
          : 'Lower quality detected. Negotiate with local buyers or process further.',
    };
  }

  // --- ALERTS ---
  Stream<List<AlertModel>> getAlertsStream(String userId) {
    return _firestore
        .collection('alerts')
        .where('user_id', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addAlert(AlertModel alert) async {
    await _firestore.collection('alerts').add(alert.toMap());
  }

  Future<void> generateDailyAlertForUser(UserModel user) async {
    if (user.role != UserRole.farmer || user.preferredCrop == null) return;
    
    final crop = user.preferredCrop!;
    // Check if an alert was already generated today
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    final existingAlerts = await _firestore
        .collection('alerts')
        .where('user_id', isEqualTo: user.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .limit(1)
        .get();
        
    if (existingAlerts.docs.isNotEmpty) return; // Already generated today

    // Generate the message based on current prices
    final matchingPrices = _prices.where((p) => p.crop.toLowerCase() == crop.toLowerCase()).toList();
    
    if (matchingPrices.isEmpty) return; // No data to generate alert
    
    // Sort by price descending
    matchingPrices.sort((a, b) => b.price.compareTo(a.price));
    
    // Build price list string
    final StringBuffer priceList = StringBuffer();
    for (var p in matchingPrices.take(3)) {
      final mandi = getMandi(p.mandiId);
      priceList.writeln('${mandi.district} - ₹${p.price.toStringAsFixed(0)}');
    }
    
    final bestMandi = getMandi(matchingPrices.first.mandiId);
    
    final message = '''🌾 Daily Market Update

Crop: $crop

$priceList
Best Market: ${bestMandi.name}

Recommendation:
Sell within the next 48 hours for maximum profit.''';

    final newAlert = AlertModel(
      id: '',
      userId: user.uid,
      message: message,
      crop: crop,
      createdAt: DateTime.now(),
      isRead: false,
    );
    
    await addAlert(newAlert);
  }
}
