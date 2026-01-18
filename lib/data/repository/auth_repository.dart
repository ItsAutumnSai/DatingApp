import 'dart:convert';
import 'package:datingapp/data/model/user_model.dart';
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

  // Add login/register methods as needed later
}
