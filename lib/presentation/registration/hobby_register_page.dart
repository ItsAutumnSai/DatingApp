import 'package:datingapp/data/model/hobby_model.dart';
import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/habit_register_page.dart';
import 'package:flutter/material.dart';

class HobbyRegisterPage extends StatefulWidget {
  final UserRegistrationData registrationData;

  const HobbyRegisterPage({super.key, required this.registrationData});

  @override
  State<HobbyRegisterPage> createState() => _HobbyRegisterPageState();
}

class _HobbyRegisterPageState extends State<HobbyRegisterPage> {
  final List<int> _selectedHobbies = [];

  void _toggleHobby(int id) {
    setState(() {
      if (_selectedHobbies.contains(id)) {
        _selectedHobbies.remove(id);
      } else {
        if (_selectedHobbies.length < 5) {
          _selectedHobbies.add(id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only select up to 5 hobbies'),
            ),
          );
        }
      }
    });
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
                "Interests",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Select up to 5 hobbies",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: HobbyModel.hobbies.length,
                  itemBuilder: (context, index) {
                    final id = HobbyModel.hobbies.keys.elementAt(index);
                    final label = HobbyModel.hobbies.values.elementAt(index);
                    final isSelected = _selectedHobbies.contains(id);

                    return GestureDetector(
                      onTap: () => _toggleHobby(id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.redAccent : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.redAccent
                                : Colors.grey[300]!,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedHobbies.isEmpty
                      ? null
                      : () {
                          widget.registrationData.hobbies = _selectedHobbies;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HabitRegisterPage(
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
                    'Continue (${_selectedHobbies.length}/5)',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedHobbies.isEmpty
                          ? Colors.grey
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
