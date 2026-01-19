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

  Future<dynamic> getExploreUsers(int currentUserId) async {
    try {
      final response = await _httpService.get(
        '/explore?current_user_id=$currentUserId',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load explore users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load explore users: $e');
    }
  }

  Future<Map<String, dynamic>> likeUser(
    int targetUserId,
    int sourceUserId,
  ) async {
    try {
      final response = await _httpService.post(
        '/like',
        body: {'target_user_id': targetUserId, 'source_user_id': sourceUserId},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to like user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to like user: $e');
    }
  }

  Future<void> removeLike(int targetUserId, int sourceUserId) async {
    try {
      final response = await _httpService.post(
        '/like/remove',
        body: {'target_user_id': targetUserId, 'source_user_id': sourceUserId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove like: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove like: $e');
    }
  }

  Future<void> startChat(int user1, int user2) async {
    try {
      final response = await _httpService.post(
        '/chat/start',
        body: {'user_id_1': user1, 'user_id_2': user2},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to start chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to start chat: $e');
    }
  }

  Future<void> confirmBond(int user1, int user2) async {
    try {
      final response = await _httpService.post(
        '/bond/confirm',
        body: {'user_id_1': user1, 'user_id_2': user2},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to confirm bond: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to confirm bond: $e');
    }
  }

  Future<void> breakBond(int userId) async {
    try {
      final response = await _httpService.post(
        '/bond/break',
        body: {'user_id': userId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to break bond: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to break bond: $e');
    }
  }

  Future<List<dynamic>> getChatList(int currentUserId) async {
    try {
      final response = await _httpService.get(
        '/chat/list?current_user_id=$currentUserId',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load chat list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load chat list: $e');
    }
  }

  Future<List<dynamic>> getChatHistory(int user1, int user2) async {
    try {
      final response = await _httpService.get(
        '/chat/history?user1=$user1&user2=$user2',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load chat history: $e');
    }
  }

  Future<void> sendMessage(int senderId, int receiverId, String message) async {
    try {
      final response = await _httpService.post(
        '/chat/send',
        body: {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<Map<String, dynamic>> getMatches(int userId) async {
    try {
      final response = await _httpService.get('/matches?user_id=$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'liked_me': [], 'matches': []};
      }
    } catch (e) {
      throw Exception('Failed to get matches: $e');
    }
  }

  Future<void> deleteAccount(int userId) async {
    try {
      final response = await _httpService.post(
        '/delete_user',
        body: {'user_id': userId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
