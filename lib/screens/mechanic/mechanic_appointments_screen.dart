import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:ts_autoparts_app/constant/const.dart';

class MechanicAppointmentsScreen extends StatefulWidget {
  const MechanicAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MechanicAppointmentsScreen> createState() => _MechanicAppointmentsScreenState();
}

class _MechanicAppointmentsScreenState extends State<MechanicAppointmentsScreen> {
  List<dynamic> _appointments = [];
  List<dynamic> _filteredAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'All';
  String _selectedStatus = 'All';

  final List<String> _filterOptions = ['All', 'Today', 'This Week'];
  final List<String> _statusOptions = ['All', 'pending', 'in_progress', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _filterAppointments() {
    setState(() {
      print('Filtering appointments with status: $_selectedStatus');
      print('Total appointments: ${_appointments.length}');
      _filteredAppointments = _appointments.where((appointment) {
        final appointmentDate = DateTime.parse(appointment['appointment_date']);
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        
        bool dateMatch = true;
        if (_selectedFilter == 'Today') {
          dateMatch = appointmentDate.year == now.year &&
                      appointmentDate.month == now.month &&
                      appointmentDate.day == now.day;
        } else if (_selectedFilter == 'This Week') {
          dateMatch = appointmentDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                      appointmentDate.isBefore(now.add(const Duration(days: 1)));
        }
        
        bool statusMatch = _selectedStatus == 'All' || 
            appointment['status'] == _selectedStatus;
        
        if (statusMatch) {
          print('Matching appointment: ${appointment['id']} with status: ${appointment['status']}');
        }
        
        return dateMatch && statusMatch;
      }).toList();
      print('Filtered appointments count: ${_filteredAppointments.length}');
    });
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await SecureStorage.getToken();
    if (token == null) {
      setState(() {
        _errorMessage = 'User not logged in.';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$baseUrl/api/mechanic/appointments');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = data;
          _filteredAppointments = data;
          _isLoading = false;
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage = errorData['message'] ?? 'Failed to load appointments. (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: Please check your internet connection';
        _isLoading = false;
      });
      debugPrint('Error fetching appointments: $e');
    }
  }

  Future<void> _updateAppointmentStatus(int appointmentId, String newStatus) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/api/mechanic/appointments/$appointmentId/status');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        await _fetchAppointments(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Appointment status updated to ${capitalizeStatus(newStatus)}')),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Failed to update appointment status')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error: Please check your internet connection')),
        );
      }
      debugPrint('Error updating appointment status: $e');
    }
  }

  String capitalizeStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status.split('_').map((word) =>
      word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
    ).join(' ');
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.red[700] ?? Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _onRefresh() {
    return _fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: const Color(0xFF144FAB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Date',
                          border: OutlineInputBorder(),
                        ),
                        items: _filterOptions.map((String filter) {
                          return DropdownMenuItem<String>(
                            value: filter,
                            child: Text(filter),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                              _filterAppointments();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(),
                        ),
                        items: _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(capitalizeStatus(status)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedStatus = newValue;
                              _filterAppointments();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'All';
                          _selectedStatus = 'All';
                          _filterAppointments();
                        });
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_errorMessage!),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchAppointments,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredAppointments.isEmpty
                          ? const Center(child: Text('No appointments found.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = _filteredAppointments[index];
                                final status = appointment['status'] ?? 'unknown';
                                final date = appointment['appointment_date'] ?? 'N/A';
                                final customerName = appointment['user']['name'] ?? 'Unknown Customer';
                                final vehicleInfo = appointment['vehicle_info'] ?? 'No vehicle information';
                                final serviceType = appointment['service_description'] ?? 'No service description specified';
                                final notes = appointment['notes'] ?? 'No additional notes';

                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Appointment #${appointment['id']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: getStatusColor(status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: getStatusColor(status),
                                                ),
                                              ),
                                              child: Text(
                                                capitalizeStatus(status),
                                                style: TextStyle(
                                                  color: getStatusColor(status),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Customer: $customerName',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Date: $date'),
                                        const SizedBox(height: 8),
                                        Text('Service: $serviceType'),
                                        if (status.toLowerCase() == 'accepted') ...[
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => _updateAppointmentStatus(
                                                  appointment['id'],
                                                  'completed',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Mark as Completed'),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (status.toLowerCase() == 'pending') ...[
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => _updateAppointmentStatus(
                                                  appointment['id'],
                                                  'rejected',
                                                ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Reject'),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () => _updateAppointmentStatus(
                                                  appointment['id'],
                                                  'accepted',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Accept'),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (status.toLowerCase() == 'in_progress') ...[
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => _updateAppointmentStatus(
                                                  appointment['id'],
                                                  'completed',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Mark as Completed'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
