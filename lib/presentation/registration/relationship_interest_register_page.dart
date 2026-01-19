import 'package:datingapp/data/model/relationship_interest_model.dart';
import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/height_register_page.dart';
import 'package:flutter/material.dart';

class RelationshipInterestRegisterPage extends StatefulWidget {
  final UserRegistrationData registrationData;

  const RelationshipInterestRegisterPage({
    super.key,
    required this.registrationData,
  });

  @override
  State<RelationshipInterestRegisterPage> createState() =>
      _RelationshipInterestRegisterPageState();
}

class _RelationshipInterestRegisterPageState
    extends State<RelationshipInterestRegisterPage> {
  int? _selectedRelationship;

  Widget _buildOption(int id, String label) {
    final isSelected = _selectedRelationship == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRelationship = id;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.redAccent : Colors.black,
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Relationship Goals",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "What are you looking for?",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ...RelationshipInterestModel.interests.entries
                  .map((entry) => _buildOption(entry.key, entry.value))
                  .toList(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRelationship == null
                      ? null
                      : () {
                          // Update Data
                          widget.registrationData.relationshipInterest =
                              _selectedRelationship;

                          // Navigate to HeightRegisterPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HeightRegisterPage(
                                registrationData: widget.registrationData,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
