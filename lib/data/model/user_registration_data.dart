class UserRegistrationData {
  String name;
  String phoneNumber;
  String dob;
  double latitude;
  double longitude;
  int? gender;
  String? email;
  int? genderInterest;
  int? relationshipInterest;
  int? height;
  List<int> hobbies;
  bool? isSmoker;
  bool? isDrinker;
  List<String> photos;
  int? religion;
  String? bio;
  String? openingMove;
  String password;
  String? lastLogin;

  UserRegistrationData({
    this.name = '',
    this.phoneNumber = '',
    this.dob = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.gender,
    this.email,
    this.genderInterest,
    this.relationshipInterest,
    this.height,
    this.hobbies = const [],
    this.isSmoker,
    this.isDrinker,
    this.photos = const [],
    this.religion,
    this.bio,
    this.openingMove,
    this.password = '',
    this.lastLogin,
  });

  @override
  String toString() {
    return 'UserRegistrationData(name: $name, phone: $phoneNumber)';
  }
}
