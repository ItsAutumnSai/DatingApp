import 'package:datingapp/data/model/gender_model.dart';
import 'package:datingapp/data/model/hobby_model.dart';
import 'package:datingapp/data/model/relationship_interest_model.dart';
import 'package:datingapp/data/model/religion_model.dart';
import 'package:datingapp/data/service/httpservice.dart';
import 'package:datingapp/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Map<String, File>? cachedPhotos;
  final bool isCurrentUser;

  const ProfileCard({
    super.key,
    required this.userData,
    this.cachedPhotos,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = userData['name'] ?? 'Unknown';
    final dobString = userData['dateofbirth'];
    String age = 'Unknown';
    if (dobString != null) {
      try {
        final dob = DateTime.parse(dobString);
        final now = DateTime.now();
        int ageCalc = now.year - dob.year;
        if (now.month < dob.month ||
            (now.month == dob.month && now.day < dob.day)) {
          ageCalc--;
        }
        age = ageCalc.toString();
      } catch (e) {
        age = dobString;
      }
    }

    final bio = userData['prefs']?['bio'] ?? 'No bio';
    final openingMove = userData['prefs']?['openingmove'] ?? 'No opening move';
    final gender = GenderModel.getLabel(userData['prefs']?['gender']);
    final height = userData['prefs']?['height'] ?? 0;
    final isSmoker = userData['prefs']?['is_smoke'];
    final isDrinker = userData['prefs']?['is_drink'];
    final religion = ReligionModel.getLabel(userData['prefs']?['religion']);
    final genderInterest = GenderModel.getLabel(
      userData['prefs']?['genderinterest'],
    );
    final relationshipInterest = RelationshipInterestModel.getLabel(
      userData['prefs']?['relationshipinterest'],
    );

    final hobbies1 = HobbyModel.getLabel(userData['hobbies']?['hobby1']);
    final hobbies2 = HobbyModel.getLabel(userData['hobbies']?['hobby2']);
    final hobbies3 = HobbyModel.getLabel(userData['hobbies']?['hobby3']);
    final hobbies4 = HobbyModel.getLabel(userData['hobbies']?['hobby4']);
    final hobbies5 = HobbyModel.getLabel(userData['hobbies']?['hobby5']);

    // Identify Main Photo (photo1) and others
    final photos = userData['photos'] ?? {};
    final validPhotoKeys = <String>[];
    for (int i = 1; i <= 5; i++) {
      final key = 'photo$i';
      if (photos[key] != null && photos[key].toString().isNotEmpty) {
        validPhotoKeys.add(key);
      }
    }

    final photo1Key = 'photo1';
    final otherPhotoKeys = validPhotoKeys.where((k) => k != photo1Key).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Main Photo with Details
          Stack(
            children: [
              // Photo with Margin and Rounded Corners
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 25,
                ),
                height: 600,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildPhotoWidget(photo1Key, height: 500),
                ),
              ),

              // Name, Age and City Overlay
              // Name, Age and Lat/Long Overlay
              Positioned(
                bottom: 40,
                left: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$name, $age",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 20,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Last Login Overlay
              if (userData['prefs']['lastlogin'] != null)
                Positioned(
                  top: 40,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatLastLogin(userData['prefs']['lastlogin']),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // 2. Profile Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // About Me (InfoCard)
                if (bio.isNotEmpty) ...[
                  InfoCard(
                    title: "About Me",
                    child: Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // General
                InfoCard(
                  title: "General",
                  child: Column(
                    children: [
                      _buildRow("Gender", gender),
                      _buildDivider(),
                      _buildRow(
                        "Height",
                        height > 0 ? "$height cm" : "Unknown",
                      ),
                      _buildDivider(),
                      _buildRow("Religion", religion),
                      _buildDivider(),
                      _buildRow(
                        "Smoking",
                        isSmoker == true
                            ? "Yes"
                            : (isSmoker == false ? "No" : "Unknown"),
                      ),
                      _buildDivider(),
                      _buildRow(
                        "Drinking",
                        isDrinker == true
                            ? "Yes"
                            : (isDrinker == false ? "No" : "Unknown"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Hobbies
                InfoCard(
                  title: "Hobbies",
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      if (hobbies1 != 'Unknown') _buildChip(hobbies1),
                      if (hobbies2 != 'Unknown') _buildChip(hobbies2),
                      if (hobbies3 != 'Unknown') _buildChip(hobbies3),
                      if (hobbies4 != 'Unknown') _buildChip(hobbies4),
                      if (hobbies5 != 'Unknown') _buildChip(hobbies5),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Looking For
                InfoCard(
                  title: "Looking For",
                  child: Column(
                    children: [
                      _buildRow("Interested In", genderInterest),
                      _buildDivider(),
                      _buildRow("Relationship", relationshipInterest),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Opening Move (InfoCard)
                if (openingMove.isNotEmpty) ...[
                  InfoCard(
                    title: "Opening Move",
                    trailing: !isCurrentUser
                        ? InkWell(
                            onTap: () {
                              // Chat action
                              print("Chat tapped");
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withAlpha(128),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                            ),
                          )
                        : null,
                    child: Text(
                      openingMove,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),

          // 3. Remaining Photos
          if (otherPhotoKeys.isNotEmpty)
            Column(
              children: otherPhotoKeys.map((key) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ), // Consistent margin
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildPhotoWidget(key, height: 400),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    if (value == 'Unknown' || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.black12);
  }

  Widget _buildChip(String label) {
    return Chip(label: Text(label), backgroundColor: Colors.white);
  }

  Widget _buildPhotoWidget(String key, {double height = 400}) {
    final file = cachedPhotos?[key];
    final filename =
        userData['photos']?[key]; // Fallback if file not cached yet

    if (file != null) {
      return Image.file(
        file,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(
          height: height,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.broken_image)),
        ),
      );
    } else if (filename != null) {
      // Network Fallback
      return Image.network(
        '${HttpService().baseUrl}/uploads/$filename',
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (ctx, err, stack) => Container(
          height: height,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.error)),
        ),
      );
    } else {
      // Logic for if key exists but no value, though filtered out above
      return Container(
        height: height,
        color: Colors.grey[300],
        child: const Center(child: Text("No Image")),
      );
    }
  }
}

String _formatLastLogin(String? isoString) {
  if (isoString == null) return "Unknown";
  try {
    final date = DateTime.parse(
      isoString,
    ).toLocal(); // Backend sends UTC or Server time
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return "Active ${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "Active ${diff.inHours}h ago";
    } else {
      return "Last: ${DateFormat('MMM d').format(date)}";
    }
  } catch (e) {
    return "Unknown";
  }
}
