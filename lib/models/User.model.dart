class UserModel {
  final int? phoneNumber;
  final String? email;
  final String? fullName;
  final String? currentAddress;
  final int? codePostal;
  final String? wilaya;
  final String? password;
  final String role;

  UserModel({
    this.phoneNumber,
    this.email,
    this.fullName,
    this.currentAddress,
    this.codePostal,
    this.wilaya,
    this.password,
    this.role = 'CUSTOMER',
  });

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'fullName': fullName,
      'currentAddress': currentAddress,
      'codePostal': codePostal,
      'wilaya': wilaya,
      'password': password,
      'role': role,
    };
  }

  // Create from JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      fullName: json['fullName'],
      currentAddress: json['currentAddress'],
      codePostal: json['codePostal'],
      wilaya: json['wilaya'],
      password: json['password'],
      role: json['role'] ?? 'CUSTOMER',
    );
  }

  // Copy with method for updating specific fields
  UserModel copyWith({
    int? phoneNumber,
    String? email,
    String? fullName,
    String? currentAddress,
    int? codePostal,
    String? wilaya,
    String? password,
    String? role,
  }) {
    return UserModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      currentAddress: currentAddress ?? this.currentAddress,
      codePostal: codePostal ?? this.codePostal,
      wilaya: wilaya ?? this.wilaya,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
