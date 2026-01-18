import 'package:datingapp/presentation/email_register_page.dart';
import 'package:flutter/material.dart';

class GenderRegisterPage extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String dob;
  final double latitude;
  final double longitude;

  const GenderRegisterPage({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.dob,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<GenderRegisterPage> createState() => _GenderRegisterPageState();
}

class _GenderRegisterPageState extends State<GenderRegisterPage> {
  // final AuthRepository _authRepository = AuthRepository(); // Moved to final step
  int? _selectedGender; // 1: Male, 2: Female, 3: Other

  final List<Map<String, dynamic>> _genders = [
    {'id': 1, 'label': 'Male'},
    {'id': 2, 'label': 'Female'},
    {'id': 3, 'label': 'Other'},
  ];

  Widget _buildGenderOption(int id, String label) {
    final isSelected = _selectedGender == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = id;
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
              Text(
                "${widget.name} is a cool name!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text("What's your gender?", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              ..._genders
                  .map((g) => _buildGenderOption(g['id'], g['label']))
                  .toList(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedGender == null
                      ? null
                      : () {
                          // Navigate to Email Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmailRegisterPage(
                                name: widget.name,
                                phoneNumber: widget.phoneNumber,
                                dob: widget.dob,
                                latitude: widget.latitude,
                                longitude: widget.longitude,
                                gender: _selectedGender!,
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
                      color: _selectedGender == null
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
