import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/review.dart';
import 'package:ts_autoparts_app/constant/const.dart';
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class MechanicReviewsScreen extends StatefulWidget {
  final int mechanicId;
  final String mechanicName;

  const MechanicReviewsScreen({
    Key? key,
    required this.mechanicId,
    required this.mechanicName,
  }) : super(key: key);

  @override
  State<MechanicReviewsScreen> createState() => _MechanicReviewsScreenState();
}

class _MechanicReviewsScreenState extends State<MechanicReviewsScreen> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _error;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/mechanics/${widget.mechanicId}/reviews'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          _reviews = (data['data'] as List)
              .map((review) => Review.fromJson(review))
              .toList();

          if (_reviews.isNotEmpty) {
            _averageRating = _reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                _reviews.length;
          }
        }
      } else {
        throw Exception('Failed to fetch reviews');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load reviews: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.mechanicName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchReviews,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber[700],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_reviews.length} ${_reviews.length == 1 ? 'Review' : 'Reviews'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _reviews.isEmpty
                          ? const Center(
                              child: Text(
                                'No reviews yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _reviews.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final review = _reviews[index];
                                return Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Theme.of(context).primaryColor,
                                              child: Text(
                                                review.userName.substring(0, 1).toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    review.userName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('MMM d, yyyy')
                                                        .format(review.createdAt),
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber[700],
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  review.rating.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (review.comment != null &&
                                            review.comment!.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            review.comment!,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
} 