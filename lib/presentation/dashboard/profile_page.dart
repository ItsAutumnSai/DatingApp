import 'package:datingapp/data/model/gender_model.dart';
import 'package:datingapp/data/model/hobby_model.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:datingapp/data/service/httpservice.dart';
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
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Scaffold(body: Center(child: Text("No profile data found")));
    }

    final name = _userData!['name'] ?? 'Unknown';
    final age = _userData!['dateofbirth'] ?? 'Unknown';
    final bio = _userData!['prefs']?['bio'] ?? 'No bio';
    final openingMove =
        _userData!['prefs']?['openingmove'] ?? 'No opening move';
    final gender = GenderModel.getLabel(_userData!['prefs']?['gender']);
    final hobbies1 = HobbyModel.getLabel(_userData!['hobbies']?['hobby1']);
    final hobbies2 = HobbyModel.getLabel(_userData!['hobbies']?['hobby2']);
    final hobbies3 = HobbyModel.getLabel(_userData!['hobbies']?['hobby3']);
    final hobbies4 = HobbyModel.getLabel(_userData!['hobbies']?['hobby4']);
    final hobbies5 = HobbyModel.getLabel(_userData!['hobbies']?['hobby5']);
    final photo1 = _userData!['photos']?['photo1'] ?? null;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: 500, // Enforce a height so the Stack doesn't collapse
            width: double.infinity,
            child: Stack(
              children: [
                if (photo1 != null)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 25.0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          '${HttpService().baseUrl}/uploads/$photo1',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: Icon(Icons.error));
                          },
                        ),
                      ),
                    ),
                  ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text("Profile"),
                    // Text("Name: $name"),
                    // Text("DOB: $age"),
                    // Text("Bio: $bio"),
                    // Text("Opening Move: $openingMove"),
                    // Text("Gender: $gender"),
                    Text(
                      "Hobbies: $hobbies1, $hobbies2, $hobbies3, $hobbies4, $hobbies5",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
