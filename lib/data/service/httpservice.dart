import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HttpService {
  // Singleton pattern
  static final HttpService _instance = HttpService._internal();

  factory HttpService() {
    return _instance;
  }

  HttpService._internal();

  // Base URL from .env (fallback for safety)
  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:5000';

  // Default headers with API Key from .env
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'x-api-key': dotenv.env['API_KEY'] ?? '',
  };

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    try {
      final response = await http.get(url, headers: mergedHeaders);
      return response;
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }

  Future<http.Response> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    try {
      final response = await http.post(
        url,
        headers: mergedHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }

  Future<http.Response> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    try {
      final response = await http.put(
        url,
        headers: mergedHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to perform PUT request: $e');
    }
  }

  Future<String?> uploadImage(File file) async {
    final url = Uri.parse('$baseUrl/upload');
    final request = http.MultipartRequest('POST', url);

    // Add headers (excluding Content-Type as MultipartRequest sets it)
    request.headers['x-api-key'] = dotenv.env['API_KEY'] ?? '';

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['filename'];
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
