import 'dart:convert';
import 'package:datingapp/data/model/user_model.dart';
import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/data/service/httpservice.dart';

class AuthRepository {
  final HttpService _httpService = HttpService();

  Future<User?> checkUserExists(String phoneNumber) async {
    try {
      final response = await _httpService.get(
        '/users/search?phonenumber=$phoneNumber',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        // Log error or throw specific exception
        throw Exception(
          'Failed to check user existence: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Re-throw or handle error
      throw Exception('Network error during user check: $e');
    }
  }

  Future<bool> registerUser(UserRegistrationData data) async {
    try {
      // Map hobbies list to keys
      final Map<String, int> hobbiesMap = {};
      for (int i = 0; i < data.hobbies.length && i < 5; i++) {
        hobbiesMap['hobby${i + 1}'] = data.hobbies[i];
      }

      // Map photos list to keys (using paths as strings for now)
      final Map<String, String> photosMap = {};
      for (int i = 0; i < data.photos.length && i < 5; i++) {
        photosMap['photo${i + 1}'] = data.photos[i];
      }

      final body = {
        'name': data.name,
        'phonenumber': data.phoneNumber,
        'password': data.password,
        'dateofbirth': data.dob,
        if (data.email != null && data.email!.isNotEmpty) 'email': data.email,

        'hobbies': hobbiesMap,
        'photos': photosMap,

        'prefs': {
          'latitude': data.latitude,
          'longitude': data.longitude,
          'gender': data.gender,
          'genderinterest': data.genderInterest,
          'relationshipinterest': data.relationshipInterest,
          'height': data.height,
          'is_smoke': data.isSmoker,
          'is_drink': data.isDrinker,
          'religion': data.religion,
          'bio': data.bio,
          'openingmove': data.openingMove,
        },
      };

      final response = await _httpService.post('/users', body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Registration failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
}
