import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ts_autoparts_app/models/product.dart'; // Import the Product model
import 'package:ts_autoparts_app/constant/const.dart';

class ProductService {
  
  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    try {
      // Make the HTTP GET request to the API
      final response = await http.get(Uri.parse('$baseUrl/api/products'));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON response
        List<dynamic> data = json.decode(response.body);

        // Map the JSON data to a list of Product objects
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        // Handle non-200 status codes
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error fetching products: $e');
      throw Exception('Failed to load products. Error: $e');
    }
  }

  // Fetch a single product by ID (optional, if needed)
  Future<Product> fetchProductById(int id) async {
    try {
      // Make the HTTP GET request to the API
      final response = await http.get(Uri.parse('$baseUrl/api/products/$id'));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON response
        Map<String, dynamic> data = json.decode(response.body);

        // Convert JSON to a Product object
        return Product.fromJson(data);
      } else {
        // Handle non-200 status codes
        throw Exception(
            'Failed to load product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error fetching product: $e');
      throw Exception('Failed to load product. Error: $e');
    }
  }
}