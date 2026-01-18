import 'dart:convert';
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
}
