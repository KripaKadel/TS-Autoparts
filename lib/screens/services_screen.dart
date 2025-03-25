import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import 'payment_screen.dart'; // Import the PaymentScreen

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String serviceType = "Select Service Type";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String selectedMechanic = "Select Mechanic";
  int? selectedMechanicId; // To store the selected mechanic's ID

  // Validation error states
  bool _isServiceTypeValid = true;
  bool _isDateValid = true;
  bool _isTimeValid = true;
  bool _isMechanicValid = true;

  final Color primaryColor = const Color(0xFF144FAB);

  List<String> serviceTypes = [
    "Oil Change",
    "Tire Rotation",
    "Brake Service",
    "Engine Tune-up",
    "Fluid Check"
  ];
  List<Map<String, dynamic>> mechanics = []; // To store fetched mechanics

  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // Secure storage instance

  @override
  void initState() {
    super.initState();
    fetchMechanics(); // Fetch mechanics when the screen loads
  }

  // Fetch mechanics from the backend
  Future<void> fetchMechanics() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/mechanics'); // Replace with your backend URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          mechanics = data.map((mechanic) => {
            'id': mechanic['id'],
            'name': mechanic['name'],
          }).toList();
        });
      } else {
        throw Exception('Failed to load mechanics: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching mechanics: $e')),
      );
    }
  }

  // Fetch the logged-in user's details
  Future<Map<String, dynamic>> fetchUserDetails() async {
    final token = await _storage.read(key: 'access_token'); // Fetch the token securely
    print('Retrieved token: $token'); // Debug log

    if (token == null) {
      throw Exception('User is not logged in');
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/user'); // Replace with your backend URL
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final userDetails = json.decode(response.body);
        if (userDetails['id'] == null) {
          throw Exception('User ID not found in response');
        }
        return userDetails;
      } else {
        throw Exception('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e'); // Debug log
      throw Exception('Error fetching user details: $e');
    }
  }

  // Validate and proceed to payment
  void _proceedToPayment() {
    // Reset validation errors
    setState(() {
      _isServiceTypeValid = serviceType != "Select Service Type";
      _isDateValid = selectedDate != DateTime.now();
      _isTimeValid = selectedTime != const TimeOfDay(hour: 9, minute: 0);
      _isMechanicValid = selectedMechanicId != null;
    });

    // Check if all fields are valid
    if (!_isServiceTypeValid || !_isDateValid || !_isTimeValid || !_isMechanicValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Navigate to PaymentScreen with appointment details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          serviceType: serviceType,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          selectedMechanicId: selectedMechanicId!,
          onPaymentSuccess: _storeAppointment, // Callback for payment success
        ),
      ),
    );
  }

  // Store appointment in the backend
  Future<void> _storeAppointment() async {
    // Fetch the logged-in user's details
    Map<String, dynamic> userDetails;
    try {
      userDetails = await fetchUserDetails();
      print('User Details: $userDetails'); // Debug log
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
      return;
    }

    final userId = userDetails['id']; // Get the user_id from the fetched details

    // Prepare appointment data
    final appointmentData = {
      'user_id': userId, // Use the fetched user_id
      'mechanic_id': selectedMechanicId,
      'service_description': serviceType,
      'appointment_date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'time': DateFormat('HH:mm').format(DateTime(
        0, 0, 0, selectedTime.hour, selectedTime.minute
      )), // 24-hour format
      'status': 'pending',
    };

    // Debugging: Print the data being sent
    print('Appointment Data: $appointmentData');

    // Send data to the backend
    final url = Uri.parse('http://10.0.2.2:8000/api/appointments'); // Replace with your backend URL
    try {
      final token = await _storage.read(key: 'access_token'); // Fetch the token securely

      if (token == null) {
        throw Exception('User is not logged in');
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request
          'Content-Type': 'application/json',
        },
        body: json.encode(appointmentData),
      );

      // Debugging: Print the response
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
        // Navigate back to home or another screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Appointment Booking',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _showServiceTypeDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isServiceTypeValid ? Colors.transparent : Colors.red,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            serviceType,
                            style: TextStyle(
                              color: serviceType == "Select Service Type" ? Colors.grey : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  if (!_isServiceTypeValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a service type',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Select Time Slot
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Time Slot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isDateValid ? Colors.transparent : Colors.red,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MM/dd/yyyy').format(selectedDate),
                                  style: TextStyle(
                                    color: selectedDate == DateTime.now() ? Colors.grey : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _selectTime(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isTimeValid ? Colors.transparent : Colors.red,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedTime.format(context),
                                  style: TextStyle(
                                    color: selectedTime == const TimeOfDay(hour: 9, minute: 0) ? Colors.grey : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(Icons.access_time, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_isDateValid || !_isTimeValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a valid date and time',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Assigned Mechanic
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assigned Mechanic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _showMechanicDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isMechanicValid ? Colors.transparent : Colors.red,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedMechanic,
                            style: TextStyle(
                              color: selectedMechanic == "Select Mechanic" ? Colors.grey : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  if (!_isMechanicValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a mechanic',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Summary
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // Summary details
              buildSummaryRow('Service Type', serviceType),
              buildSummaryRow('Date', DateFormat('MM/dd/yyyy').format(selectedDate)),
              buildSummaryRow('Time', selectedTime.format(context)),
              buildSummaryRow('Assigned Mechanic', selectedMechanic),

              const SizedBox(height: 40),

              // Payment Button
              ElevatedButton(
                onPressed: _proceedToPayment, // Redirect to PaymentScreen
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Navigate back to HomeWrapper when Cancel is clicked
                  Navigator.pushReplacementNamed(context, '/home'); // Navigate to HomeWrapper route
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Show Service Type Dialog
  void _showServiceTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Service Type'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: serviceTypes.map((service) {
                return ListTile(
                  title: Text(service),
                  onTap: () {
                    setState(() {
                      serviceType = service;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Show Mechanic Dialog
  void _showMechanicDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Mechanic'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mechanics.map((mechanic) {
                return ListTile(
                  title: Text(mechanic['name']),
                  onTap: () {
                    setState(() {
                      selectedMechanic = mechanic['name'];
                      selectedMechanicId = mechanic['id']; // Store mechanic's ID
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
}