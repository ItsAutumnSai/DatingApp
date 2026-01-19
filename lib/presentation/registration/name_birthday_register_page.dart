// import 'package:datingapp/data/repository/auth_repository.dart'; // Unused
import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/gender_register_page.dart';
import 'package:flutter/material.dart';

class NameBirthdayRegisterPage extends StatefulWidget {
  final String phoneNumber;
  final String password;
  final double latitude;
  final double longitude;

  const NameBirthdayRegisterPage({
    super.key,
    required this.phoneNumber,
    required this.password,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<NameBirthdayRegisterPage> createState() =>
      _NameBirthdayRegisterPageState();
}

class _NameBirthdayRegisterPageState extends State<NameBirthdayRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  // final AuthRepository _authRepository = AuthRepository(); // Moved to final registration step

  // Date selection
  int _selectedDay = 1;
  int _selectedMonth = 1; // 1-12
  int _selectedYear = 2000;

  late final List<int> _days;
  late final List<String> _months;
  late final List<int> _years;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  @override
  void initState() {
    super.initState();
    _days = List.generate(31, (index) => index + 1);
    _months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    // Years from 1950 to (Current Year - 18)
    final currentYear = DateTime.now().year;
    _years = List.generate(
      currentYear - 18 - 1950 + 1,
      (index) => 1950 + index,
    ).reversed.toList();
    _selectedYear = 2000; // Default year

    // Safety check if 2000 is in range, else use first available
    if (!_years.contains(_selectedYear)) {
      _selectedYear = _years.first;
    }

    _dayController = FixedExtentScrollController(
      initialItem: _days.indexOf(_selectedDay),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedYear),
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildPicker({
    required List<dynamic> items,
    required Function(dynamic) onChanged,
    required dynamic selectedItem,
    required FixedExtentScrollController controller,
  }) {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: controller, // Use the passed controller
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(items[index]);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {
            final isSelected = items[index] == selectedItem;
            return Center(
              child: Text(
                items[index].toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w300,
                  color: isSelected ? Colors.redAccent : Colors.grey[400],
                ),
              ),
            );
          },
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
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar removed from here
                const Text(
                  "Profile",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "It doesn't have to be your real name!",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "When were you born?",
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildPicker(
                        items: _days,
                        selectedItem: _selectedDay,
                        controller: _dayController,
                        onChanged: (val) {
                          setState(() => _selectedDay = val);
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildPicker(
                        items: _months,
                        selectedItem:
                            _months[_selectedMonth - 1], // Display string
                        controller: _monthController,
                        onChanged: (val) {
                          setState(() {
                            // Find index of val in _months to set _selectedMonth int
                            _selectedMonth = _months.indexOf(val) + 1;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildPicker(
                        items: _years,
                        selectedItem: _selectedYear,
                        controller: _yearController,
                        onChanged: (val) {
                          setState(() => _selectedYear = val);
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final dob =
                            "$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}";

                        // 1. Calculate Age
                        final now = DateTime.now();
                        final birthday = DateTime(
                          _selectedYear,
                          _selectedMonth,
                          _selectedDay,
                        );
                        int age = now.year - birthday.year;
                        if (now.month < birthday.month ||
                            (now.month == birthday.month &&
                                now.day < birthday.day)) {
                          age--;
                        }

                        // 2. Show Confirmation Dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("You're $age right?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                  },
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog

                                    // Create Registration Data
                                    final registrationData =
                                        UserRegistrationData(
                                          name: _nameController.text,
                                          phoneNumber: widget.phoneNumber,
                                          password: widget.password,
                                          dob: dob,
                                          latitude: widget.latitude,
                                          longitude: widget.longitude,
                                        );

                                    // 3. Navigate to Gender Page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GenderRegisterPage(
                                              registrationData:
                                                  registrationData,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                      }
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
      ),
    );
  }
}
