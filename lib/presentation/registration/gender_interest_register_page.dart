import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/relationship_interest_register_page.dart';
import 'package:flutter/material.dart';

class GenderInterestRegisterPage extends StatefulWidget {
  final UserRegistrationData registrationData;

  const GenderInterestRegisterPage({super.key, required this.registrationData});

  @override
  State<GenderInterestRegisterPage> createState() =>
      _GenderInterestRegisterPageState();
}

class _GenderInterestRegisterPageState
    extends State<GenderInterestRegisterPage> {
  int? _selectedInterest; // 1: Men, 2: Women, 3: Everyone

  final List<Map<String, dynamic>> _interests = [
    {'id': 1, 'label': 'Men'},
    {'id': 2, 'label': 'Women'},
    {'id': 3, 'label': 'Everyone'},
  ];

  Widget _buildOption(int id, String label) {
    final isSelected = _selectedInterest == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedInterest = id;
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
                "Your interest",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Who do you want to meet?",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ..._interests
                  .map((i) => _buildOption(i['id'], i['label']))
                  .toList(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedInterest == null
                      ? null
                      : () {
                          // Update Data
                          widget.registrationData.genderInterest =
                              _selectedInterest;

                          // Navigate to Next Page (RelationshipRegisterPage)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RelationshipInterestRegisterPage(
                                    registrationData: widget.registrationData,
                                  ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedInterest == null
                          ? Colors.grey
                          : Colors.redAccent,
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
