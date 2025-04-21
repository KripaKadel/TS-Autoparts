import 'package:flutter/material.dart';
import 'package:ts_autoparts_app/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('Loading notifications...');
      final notifications = await _notificationService.getNotifications();
      
      if (!mounted) return;
      
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
      
      debugPrint('Loaded ${notifications.length} notifications');
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      setState(() => _isLoading = true);
      await _notificationService.markAllNotificationsAsRead();
      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      setState(() => _isLoading = true);
      await _notificationService.deleteNotification(notificationId);
      await _loadNotifications();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _isLoading ? null : _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
        foregroundColor: Colors.white, 
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading notifications...'),
                ],
              ),
              
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading notifications',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadNotifications,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? const Center(
                      child: Text('No notifications'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          final isRead = notification['read_at'] != null;
                          final createdAt = DateTime.parse(notification['created_at']);
                          final formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(createdAt);

                          return Dismissible(
                            key: Key(notification['id'].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Notification'),
                                  content: const Text('Are you sure you want to delete this notification?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              _deleteNotification(notification['id'].toString());
                            },
                            child: Card(
                              color: isRead ? null : Colors.blue[50],
                              child: ListTile(
                                leading: Icon(
                                  _getNotificationIcon(notification['type']),
                                  color: _getNotificationColor(notification['type']),
                                ),
                                title: Text(notification['title']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notification['message']),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  if (!isRead) {
                                    await _notificationService.markNotificationAsRead(notification['id'].toString());
                                    await _loadNotifications();
                                  }
                                  _handleNotificationTap(notification);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'appointment':
        return Icons.calendar_today;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return Colors.green;
      case 'appointment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'order':
        Navigator.pushNamed(
          context,
          '/order-details',
          arguments: notification['data']['order_id'],
        );
        break;
      case 'appointment':
        Navigator.pushNamed(
          context,
          '/appointment-details',
          arguments: notification['data']['appointment_id'],
        );
        break;
    }
  }
} 