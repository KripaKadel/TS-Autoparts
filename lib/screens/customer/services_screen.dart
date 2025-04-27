import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/function/esewa.dart';
import 'package:http/http.dart' as http;
import 'package:ts_autoparts_app/constant/const.dart';

import 'dart:convert';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final AuthService _authService = AuthService();
  String serviceType = "Select Service Type";
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1)); 
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String selectedMechanic = "Select Mechanic";
  int? selectedMechanicId;
  bool isLoading = false;
  bool isFirstBooking = false;
  double appointmentCharge = 500.0;
  double discountedCharge = 450.0; // 10% off

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
    "Fluid Check",
    "Gem"
  ];
  List<Map<String, dynamic>> mechanics = [];

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchMechanics();
    _checkFirstBooking();
  }

  Future<void> _checkAuthAndFetchMechanics() async {
    final user = await _authService.getAuthenticatedUser();
    if (user == null) {
      _redirectToLogin();
      return;
    }
    await fetchMechanics();
  }

  Future<void> fetchMechanics() async {
    setState(() => isLoading = true);
    
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/mechanics'),
        headers: {'Authorization': 'Bearer $token'},
      );

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
      _handleError(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String> _getToken() async {
    final token = await _authService.getCurrentToken();
    if (token == null) {
      _redirectToLogin();
      throw Exception('Not authenticated');
    }
    return token;
  }

  Future<void> _checkFirstBooking() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/appointments'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> appointments = json.decode(response.body);
        setState(() {
          isFirstBooking = appointments.isEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error checking first booking: $e');
    }
  }

  void _redirectToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _handleError(dynamic e) {
    debugPrint('Error details: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _showPaymentDialog() {
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final charge = isFirstBooking ? discountedCharge : appointmentCharge;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFirstBooking) ...[
                const Text('First Booking Discount (10% off)'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Original Price:'),
                    Text('Rs.$appointmentCharge', 
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount:'),
                    Text('-Rs.${(appointmentCharge * 0.1).toStringAsFixed(2)}', 
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rs.$charge', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
              ),
              onPressed: () {
                Navigator.pop(context);
                _initiateEsewaPayment();
              },
              child: const Text('Pay with eSewa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  bool _validateFields() {
    setState(() {
      _isServiceTypeValid = serviceType != "Select Service Type";
      _isDateValid = selectedDate.isAfter(DateTime.now());
      _isTimeValid = selectedTime.hour >= 9 && selectedTime.hour < 17;
      _isMechanicValid = selectedMechanic != "Select Mechanic";
    });

    return _isServiceTypeValid && _isDateValid && _isTimeValid && _isMechanicValid;
  }

  Future<void> _initiateEsewaPayment() async {
    if (!_validateFields()) return;

    setState(() => isLoading = true);

    try {
      final charge = isFirstBooking ? discountedCharge : appointmentCharge;
      final esewa = Esewa(
        context: context,
        productName: "Service Appointment: $serviceType",
        amount: charge,
        onSuccess: () async {
          await _createAppointment();
          setState(() => isLoading = false);
          _showSuccessDialog();
        },
        onFailure: () {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment failed. Please try again.')),
          );
        },
        onCancel: () {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled.')),
          );
        },
      );

      esewa.pay();
    } catch (e) {
      setState(() => isLoading = false);
      _handleError(e);
    }
  }

  Future<void> _createAppointment() async {
    try {
      setState(() => isLoading = true);
      
      final user = await _authService.getAuthenticatedUser();
      if (user == null) {
        _redirectToLogin();
        return;
      }

      final token = await _getToken();
      final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:'
                          '${selectedTime.minute.toString().padLeft(2, '0')}';

      final charge = isFirstBooking ? discountedCharge : appointmentCharge;

      // First create the appointment
      final createAppointmentUrl = Uri.parse('$baseUrl/api/appointments');
      final appointmentResponse = await http.post(
        createAppointmentUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': user.id,
          'mechanic_id': selectedMechanicId,
          'service_description': serviceType,
          'appointment_date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'time': formattedTime,
          'status': 'pending',
          'amount': charge,
          'is_first_booking': isFirstBooking,
        }),
      );

      debugPrint('Appointment creation response: ${appointmentResponse.body}');

      if (appointmentResponse.statusCode == 201) {
        final appointmentData = json.decode(appointmentResponse.body);
        debugPrint('Parsed appointment data: $appointmentData');
        
        // Check for both possible response formats
        final int? appointmentId = appointmentData['id'] ?? 
                                 appointmentData['appointment']?['id'] ?? 
                                 (appointmentData['data']?['id'] as int?);

        if (appointmentId != null) {
          final referenceId = "APT-${DateTime.now().millisecondsSinceEpoch}";
          await _processAppointmentPayment(appointmentId, referenceId);
        } else {
          debugPrint('Response structure: ${appointmentData.keys.join(', ')}');
          throw Exception('Invalid appointment response format: Missing appointment ID. Response: ${appointmentResponse.body}');
        }
      } else {
        final errorData = json.decode(appointmentResponse.body);
        throw Exception(errorData['message'] ?? 'Failed to create appointment');
      }
    } catch (e) {
      debugPrint('Appointment creation error: $e');
      _handleError(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _processAppointmentPayment(int appointmentId, String transactionId) async {
    try {
      final token = await _getToken();
      
      final paymentUrl = Uri.parse('$baseUrl/api/appointments/$appointmentId/payment');
      debugPrint('Sending payment request to: $paymentUrl');
      
      final paymentData = {
        'payment_method': 'esewa',
        'amount': appointmentCharge.toString(), // Convert to string to ensure proper format
        'transaction_id': transactionId,
        'payment_details': {
          'payment_type': 'appointment',
          'service_type': serviceType,
          'mechanic_id': selectedMechanicId,
          'mechanic_name': selectedMechanic,
          'appointment_date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'appointment_time': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
          'service_charge': appointmentCharge,
        },
      };

      debugPrint('Payment request data: ${json.encode(paymentData)}');

      final response = await http.post(
        paymentUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // Add Accept header
        },
        body: json.encode(paymentData),
      );

      debugPrint('Payment response status code: ${response.statusCode}');
      debugPrint('Payment response headers: ${response.headers}');
      debugPrint('Payment response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('Parsed payment response: $responseData');
        
        if (responseData['status'] == true) {
          return;
        } else {
          throw Exception('Payment failed: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = json.decode(response.body);
        final errors = errorData['errors'] ?? {};
        final errorMessages = errors.values.join(', ');
        throw Exception('Validation error: $errorMessages');
      } else if (response.statusCode == 500) {
        // Server error
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Internal server error';
        } catch (e) {
          errorMessage = 'Internal server error: ${response.body}';
        }
        debugPrint('Server error details: $errorMessage');
        throw Exception('Server error: $errorMessage');
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Unknown error';
        } catch (e) {
          errorMessage = 'Failed to process payment: ${response.body}';
        }
        throw Exception('Payment failed with status ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      debugPrint('Payment processing error: $e');
      if (e is FormatException) {
        debugPrint('Invalid JSON response from server');
      }
      rethrow;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Booked!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              Text(
                'Your appointment for $serviceType has been successfully booked.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)} at ${selectedTime.format(context)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  // ... [Keep all your existing UI methods unchanged]
  // This includes:
  // - build() method with all UI components
  // - _buildSummaryRow()
  // - _showServiceTypeDialog()
  // - _showMechanicDialog()
  // - _selectDate()
  // - _selectTime()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Appointment Booking',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        onTap: _showServiceTypeDialog,
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
                              onTap: () => _selectDate(context),
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
                              onTap: () => _selectTime(context),
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
                        onTap: _showMechanicDialog,
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
                  _buildSummaryRow('Service Type', serviceType),
                  _buildSummaryRow('Date', DateFormat('MM/dd/yyyy').format(selectedDate)),
                  _buildSummaryRow('Time', selectedTime.format(context)),
                  _buildSummaryRow('Assigned Mechanic', selectedMechanic),
                  _buildSummaryRow('Appointment Charge', 'Rs.$appointmentCharge'),

                  const SizedBox(height: 40),

                  // Payment Button
                  ElevatedButton(
                    onPressed: _showPaymentDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Book Appointment',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
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

  void _showMechanicDialog() {
    if (mechanics.isEmpty) return;
    
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
                      selectedMechanicId = mechanic['id'];
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedTime) {
      if (picked.hour >= 9 && picked.hour < 17) {
        setState(() {
          selectedTime = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select time between 9 AM and 5 PM'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}