class User {
  final int? id;
  final String? name;
  final String? email;
  final String? dateOfBirth;
  final String? phoneNumber;
  // Add other fields as needed based on your API response

  User({this.id, this.name, this.email, this.dateOfBirth, this.phoneNumber});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      dateOfBirth: json['dateofbirth'], // Note: API returns 'dateofbirth'
      phoneNumber: json['phonenumber'], // Note: API returns 'phonenumber'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'dateofbirth': dateOfBirth,
      'phonenumber': phoneNumber,
    };
  }
}
