
enum UserRole { farmer, operator }

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final UserRole role;
  // Farmer specific
  final String? village;
  final String? preferredCrop;
  final String? notificationToken;
  // Operator specific
  final String? mandiId;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    this.village,
    this.preferredCrop,
    this.notificationToken,
    this.mandiId,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] == 'operator' ? UserRole.operator : UserRole.farmer,
      village: data['village'],
      preferredCrop: data['preferredCrop'] ?? data['crop'],
      notificationToken: data['notificationToken'],
      mandiId: data['mandi_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role == UserRole.operator ? 'operator' : 'farmer',
      'village': village,
      'preferredCrop': preferredCrop,
      'notificationToken': notificationToken,
      'mandi_id': mandiId,
    };
  }
}
