class UserModel {
  final String? id; // Add ID field
  final String? phoneNumber;
  final String? email;
  final String? fullName;
  final String? currentAddress;
  final int? postalCode;
  final String? wilaya;
  final String? password;
  final String role;
  final String? token; // JWT token field
  final String? profilePicture; // Added profile picture field

  UserModel({
    this.id,
    this.phoneNumber,
    this.email,
    this.fullName,
    this.currentAddress,
    this.postalCode,
    this.wilaya,
    this.password,
    this.role = 'CUSTOMER',
    this.token,
    this.profilePicture,
  });

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'email': email,
      'fullName': fullName,
      'currentAddress': currentAddress,
      'postalCode': postalCode,
      'wilaya': wilaya,
      'password': password,
      'role': role,
      'token': token,
      'profilePicture': profilePicture,
    };
  }

  // Create from JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId']?.toString() ?? json['id']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      email: json['email']?.toString(),
      fullName: json['fullName']?.toString(),
      currentAddress: json['currentAddress']?.toString(),
      postalCode: json['postalCode'] is int
          ? json['postalCode']
          : int.tryParse(json['postalCode']?.toString() ?? ''),
      wilaya: json['wilaya']?.toString(),
      password: json['password']?.toString(),
      role: json['role']?.toString() ?? 'CUSTOMER',
      token: json['accessToken']?.toString() ?? json['token']?.toString(),
      profilePicture:
          json['profilePicture']?.toString() ??
          json['image']?.toString(), // Handle both possible keys
    );
  }

  // Copy with method for updating specific fields
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? fullName,
    String? currentAddress,
    int? postalCode,
    String? wilaya,
    String? password,
    String? role,
    String? token,
    String? profilePicture,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      currentAddress: currentAddress ?? this.currentAddress,
      postalCode: postalCode ?? this.postalCode,
      wilaya: wilaya ?? this.wilaya,
      password: password ?? this.password,
      role: role ?? this.role,
      token: token ?? this.token,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
