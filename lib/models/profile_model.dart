// يمثل بيانات الملف الشخصي للمستخدم.
class UserProfile {
  final String id;
  final String fullName;
  final String? email;
  final String phone;
  final String role; // 'customer' or 'owner'
  final String address;
  final String city;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.fullName,
    this.email,
    this.phone = '',
    this.role = 'customer',
    this.address = '',
    this.city = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOwner => role == 'owner';
  bool get isCustomer => role == 'customer';

  String get roleDisplayArabic => isOwner ? 'مالك المتجر' : 'عميل';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      if (email != null) 'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'city': city,
      'is_active': isActive,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? address,
    String? city,
    bool? isActive,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      city: city ?? this.city,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

