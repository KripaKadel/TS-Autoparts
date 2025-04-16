import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:ts_autoparts_app/constant/const.dart';
import 'package:ts_autoparts_app/screens/customer/rate_mechanic_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'User not logged in.';
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse('$baseUrl/api/appointments/user');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> allAppointments = json.decode(response.body);

        // Filter out cancelled appointments
        final List<dynamic> activeAppointments = allAppointments.where((appointment) {
          final status = (appointment['status'] ?? '').toString().toLowerCase();
          return status != 'cancelled' && status != 'canceled';
        }).toList();

        // Check review status for completed appointments
        for (var appointment in activeAppointments) {
          if (appointment['status'].toString().toLowerCase() == 'completed') {
            try {
              final reviewResponse = await http.get(
                Uri.parse('$baseUrl/api/reviews/check/${appointment['mechanic_id']}'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );

              if (reviewResponse.statusCode == 200) {
                final reviewData = json.decode(reviewResponse.body);
                appointment['has_review'] = reviewData['has_reviewed'];
              }
            } catch (e) {
              debugPrint('Error checking review status: $e');
            }
          }
        }

        setState(() {
          _appointments = activeAppointments;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load appointments. (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelAppointment(int id) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/api/appointments/$id/cancel');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _fetchAppointments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment cancelled.')),
        );
      } else {
        final responseBody = json.decode(response.body);
        String errorMessage = responseBody['message'] ?? 'Failed to cancel appointment';

        if (responseBody['error_code'] == 'appointment_not_found') {
          errorMessage = 'Appointment not found.';
        } else if (responseBody['error_code'] == 'unauthorized') {
          errorMessage = 'You are not authorized to cancel this appointment.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _navigateToRateReview(dynamic appointment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateMechanicScreen(
          appointment: appointment,
          mechanicName: appointment['mechanic']?['name'] ?? 'Mechanic',
        ),
      ),
    );

    if (result == true) {
      // Refresh appointments to update review status
      _fetchAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF144FAB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _appointments.isEmpty
                  ? const Center(child: Text('You have no appointments.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        final mechanicName = appointment['mechanic']?['name'] ?? 'N/A';
                        final status = appointment['status'] ?? 'N/A';
                        final hasReview = appointment['has_review'] ?? false;

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.calendar_today, color: Color(0xFF144FAB)),
                                title: Text(appointment['service_description'] ?? 'Service'),
                                subtitle: Text(
                                  '${appointment['appointment_date'] ?? 'N/A'}\n'
                                  'Status: $status\n'
                                  'Mechanic: $mechanicName',
                                ),
                                isThreeLine: true,
                                trailing: status.toString().toLowerCase() == 'cancelled'
                                    ? const Text('Cancelled', style: TextStyle(color: Colors.red))
                                    : TextButton(
                                        onPressed: () => _cancelAppointment(appointment['id']),
                                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                      ),
                              ),
                              if (status.toString().toLowerCase() == 'completed') ...[
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: hasReview
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.green),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Reviewed',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : TextButton.icon(
                                          onPressed: () => _navigateToRateReview(appointment),
                                          icon: const Icon(Icons.star_border, size: 18),
                                          label: const Text('Rate & Review'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: primaryColor,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
