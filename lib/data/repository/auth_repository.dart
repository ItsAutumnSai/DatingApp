import 'dart:convert';
import 'dart:io';
import 'package:datingapp/data/model/user_model.dart';
import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/data/service/httpservice.dart';

class AuthRepository {
  final HttpService _httpService = HttpService();

  Future<User?> login(String phoneNumber, String password) async {
    try {
      final body = {'phonenumber': phoneNumber, 'password': password};

      final response = await _httpService.post('/login', body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid password');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<int?> registerUser(UserRegistrationData data) async {
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
        final responseData = jsonDecode(response.body);
        return responseData['user_id'];
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

  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    try {
      final response = await _httpService.get('/users/$userId');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load profile: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      final response = await _httpService.put('/users/$userId', body: data);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update profile: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String?> uploadPhoto(File file) async {
    try {
      return await _httpService.uploadImage(file);
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  Future<void> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final response = await _httpService.post(
        '/change_password',
        body: {
          'user_id': userId,
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
