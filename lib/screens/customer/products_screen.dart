import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_autoparts_app/models/product.dart';
import 'package:ts_autoparts_app/services/product_service.dart';
import 'package:ts_autoparts_app/screens/customer/product_description.dart';
import 'package:ts_autoparts_app/screens/customer/notifications_screen.dart';
import 'package:ts_autoparts_app/utils/secure_storage.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> futureProducts;
  String? profileImageUrl;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool showSearchResults = false;
  
  // Primary color constant for consistency
  final Color primaryColor = const Color(0xFF144FAB);

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService().fetchProducts().then((products) {
      allProducts = products;
      filteredProducts = [];
      return products;
    });
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final imageUrl = await SecureStorage.getProfileImage();
    if (mounted) {
      setState(() {
        profileImageUrl = imageUrl;
      });
    }
  }

  void filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = [];
        showSearchResults = false;
      } else {
        final searchLower = query.toLowerCase();
        filteredProducts = allProducts.where((product) {
          final nameMatch = product.name.toLowerCase().contains(searchLower);
          final brandMatch = product.brand?.toLowerCase().contains(searchLower) ?? false;
          final modelMatch = product.model?.toLowerCase().contains(searchLower) ?? false;
          return nameMatch || brandMatch || modelMatch;
        }).toList();
        showSearchResults = true;
      }
    });
  }

  void _clearSearch() {
    setState(() {
      showSearchResults = false;
      searchController.clear();
      filteredProducts = [];
      FocusScope.of(context).unfocus();
    });
  }



void _applyFilter(String? brand, double minPrice, double maxPrice) {
  setState(() {
    filteredProducts = allProducts.where((product) {
      final brandMatches = brand == null || product.brand == brand;
      final priceMatches = product.price >= minPrice && product.price <= maxPrice;
      return brandMatches && priceMatches;
    }).toList();

    showSearchResults = true;
  });
}

void _showFilterOptions(BuildContext context) {
  String? selectedBrand;
  RangeValues selectedRange = RangeValues(0, 100000);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final brands = allProducts
              .map((e) => e.brand)
              .where((e) => e != null && e.isNotEmpty)
              .toSet()
              .cast<String>()
              .toList();

          return Padding(
            padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Filter Products",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Brand Dropdown
                DropdownButtonFormField<String>(
                  value: selectedBrand,
                  decoration: const InputDecoration(labelText: "Brand"),
                  items: brands.map((brand) {
                    return DropdownMenuItem(value: brand, child: Text(brand));
                  }).toList(),
                  onChanged: (value) {
                    setModalState(() {
                      selectedBrand = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Price Range Slider
                Text("Price Range (Rs. ${selectedRange.start.toInt()} - Rs. ${selectedRange.end.toInt()})"),
                RangeSlider(
                  values: selectedRange,
                  min: 0,
                  max: 100000,
                  divisions: 100,
                  labels: RangeLabels(
                    selectedRange.start.round().toString(),
                    selectedRange.end.round().toString(),
                  ),
                  onChanged: (newRange) {
                    setModalState(() {
                      selectedRange = newRange;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Updated Button Styling
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilter(selectedBrand, selectedRange.start, selectedRange.end);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:primaryColor,
                    foregroundColor: Colors.white,
                    side: BorderSide(color: primaryColor),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Apply Filter"),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: showSearchResults 
                ? _buildSearchResults() 
                : _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset('assets/images/BLogo.svg', height: 40),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                  ? NetworkImage(profileImageUrl!)
                  : const AssetImage('assets/images/profile.jpg') as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                          SizedBox(width: 8),
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              focusNode: searchFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Search by name, brand or model',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey[500]),
                              ),
                      onChanged: filterProducts,
                      onTap: () {
                        if (searchController.text.isNotEmpty) {
                          setState(() {
                            showSearchResults = true;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.grey),
                    onPressed: () {
                      _showFilterOptions(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.notifications_none, color: Colors.grey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found'));
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildProductCard(snapshot.data![index]);
              },
            ),
          );
        }
      },
    );
  }

 Widget _buildSearchResults() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Text(
              'Search Results',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: filteredProducts.isEmpty
            ? Center(
                child: Text(
                  'No results found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredProducts.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildSearchResultItem(filteredProducts[index]);
                },
              ),
      ),
    ],
  );
}


  Widget _buildSearchResultItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDescriptionPage(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: product.image_url != null
                      ? Image.network(
                          product.image_url!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error, color: Colors.red);
                          },
                        )
                      : Icon(Icons.image, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.brand != null)
                      Text(
                        'Brand: ${product.brand!}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (product.model != null)
                      Text(
                        'Model: ${product.model!}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final double dummyRating = 4.5;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDescriptionPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: product.image_url != null
                        ? Image.network(
                            product.image_url!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error, size: 40, color: Colors.red);
                            },
                          )
                        : Icon(Icons.image, size: 40, color: Colors.grey[700]),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          dummyRating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}