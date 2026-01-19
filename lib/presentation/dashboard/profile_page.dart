import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:datingapp/data/service/httpservice.dart';
import 'package:datingapp/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepository _authRepository = AuthRepository();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  // Store cached files mapped by photo key (photo1, photo2, etc.)
  final Map<String, File> _cachedPhotos = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = UserSession().userId;
    if (userId == null) {
      setState(() {
        _error = "No user logged in";
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await _authRepository.getUserProfile(userId);
      setState(() {
        _userData = data;
        _isLoading = false;
      });

      if (_userData != null && _userData!['photos'] != null) {
        final photos = _userData!['photos'];
        // Iterate through photo1 to photo5
        for (int i = 1; i <= 5; i++) {
          final key = 'photo$i';
          final filename = photos[key];
          if (filename != null && filename.toString().isNotEmpty) {
            _cacheImage(key, filename);
          }
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cacheImage(String photoKey, String filename) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final directory = Directory('${appDir.path}/static/uploads');

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/$filename');

      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _cachedPhotos[photoKey] = file;
          });
        }
        return;
      }

      // Download if not exists
      final url = Uri.parse('${HttpService().baseUrl}/uploads/$filename');

      // Wait a bit to let Image.network (UI) have priority on the server
      await Future.delayed(const Duration(seconds: 2));

      http.Response? response;
      int attempts = 0;
      while (attempts < 3) {
        try {
          attempts++;
          // Use Connection: Keep-Alive as requested
          response = await http
              .get(url, headers: {'Connection': 'Keep-Alive'})
              .timeout(
                const Duration(seconds: 20),
                onTimeout: () {
                  throw Exception('Connection timed out');
                },
              );

          if (response.statusCode == 200) {
            break; // Success
          }
        } catch (e) {
          if (attempts == 3) rethrow;
          await Future.delayed(Duration(seconds: 1)); // Wait before retry
        }
      }

      if (response != null && response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          setState(() {
            _cachedPhotos[photoKey] = file;
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error caching image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    if (_userData == null) {
      return const Scaffold(body: Center(child: Text("No profile data found")));
    }

    // Use the reusable ProfileCard widget
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "PairMe",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ProfileCard(
        userData: _userData!,
        cachedPhotos: _cachedPhotos,
        isCurrentUser: true,
      ),
    );
  }
}
