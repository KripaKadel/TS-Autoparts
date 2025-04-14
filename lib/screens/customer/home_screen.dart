import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_autoparts_app/main.dart';
import 'package:ts_autoparts_app/services/product_service.dart';
import 'package:ts_autoparts_app/models/product.dart';
import 'package:ts_autoparts_app/screens/customer/product_description.dart';
import 'package:ts_autoparts_app/utils/secure_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> futureProducts;
  String? profileImageUrl;
  TextEditingController searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool showSearchResults = false;
  FocusNode searchFocusNode = FocusNode();

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
    setState(() {
      profileImageUrl = imageUrl;
    });
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
                : _buildHome(),
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
                    onPressed: () {},
                  ),
        ],
      ),
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


 

  
  Widget _buildHome() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Results or Main Content
            Expanded(
              child: Stack(
                children: [
                  // Main Content (hidden when searching)
                  if (!showSearchResults) ...[
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            
                            // Promotional Banner
                            Container(
                              height: 180,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFF2F7FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Hi, There ', style: TextStyle(fontSize: 18)),
                                            Text('👋', style: TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Get Up to ',
                                                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: '50% Off',
                                                style: TextStyle(color: Color(0xFF144FAB), fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Enhance Your Ride with Incredible\nDiscounts on ',
                                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                              ),
                                              TextSpan(
                                                text: 'Top-Quality Auto Parts!',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF144FAB),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF144FAB),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ProductsWrapper()),
                                            );
                                          },
                                          child: Text('Shop Now', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 120,
                                    height: 180,
                                    child: Image.asset(
                                      'assets/images/filters.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            // Categories Section
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Categories',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildCategoryItem('assets/icons/Fluids.svg', 'Fluids'),
                                  _buildCategoryItem('assets/icons/Cooling.svg', 'Cooling'),
                                  _buildCategoryItem('assets/icons/Brakes.svg', 'Brakes'),
                                  _buildCategoryItem('assets/icons/Shocks.svg', 'Shocks'),
                                  _buildCategoryItem('assets/icons/Bearing.svg', 'Bearings'),
                                  _buildCategoryItem('assets/icons/Engine.svg', 'Engines'),
                                  _buildCategoryItem('assets/icons/Filters.svg', 'Filters'),
                                  _buildCategoryItem('assets/icons/BodyParts.svg', 'Body Parts'),
                                  _buildCategoryItem('assets/icons/Lights.svg', 'Lights'),
                                  _buildCategoryItem('assets/icons/Battery.svg', 'Battery'),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            // Featured Products Section - Horizontal Scroll with increased height
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Featured Products',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 16),
                            FutureBuilder<List<Product>>(
                              future: futureProducts,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    height: 240, // Increased height
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                } else if (snapshot.hasError) {
                                  return Container(
                                    height: 240, // Increased height
                                    child: Center(child: Text('Error: ${snapshot.error}')),
                                  );
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Container(
                                    height: 240, // Increased height
                                    child: Center(child: Text('No products found')),
                                  );
                                } else {
                                  return Container(
                                    height: 240, // Increased height
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: index == snapshot.data!.length - 1 ? 0 : 16.0,
                                          ),
                                          child: _buildProductCard(snapshot.data![index]),
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 20),

                            // Service Banner Section
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFF2F7FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Get ',
                                                style: TextStyle(color: Colors.black, fontSize: 18),
                                              ),
                                              TextSpan(
                                                text: '10% off',
                                                style: TextStyle(color: Color(0xFF144FAB), fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: ' on your first service!',
                                                style: TextStyle(color: Colors.black, fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF144FAB),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ServicesWrapper()),
                                            );
                                          },
                                          child: Text('Book Appointment', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 120,
                                    child: SvgPicture.asset(
                                      'assets/images/Mechanic.svg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  // Search Results (shown when searching)
                  if (showSearchResults) ...[
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          // Search header
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: () {
                                    setState(() {
                                      showSearchResults = false;
                                      searchController.clear();
                                      filteredProducts = [];
                                      FocusScope.of(context).unfocus();
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    'Search Results',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Search results list
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                return _buildSearchResultItem(filteredProducts[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search Result Item Builder
  Widget _buildSearchResultItem(Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
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
        title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.brand != null) Text('Brand: ${product.brand!}'),
            if (product.model != null) Text('Model: ${product.model!}'),
            SizedBox(height: 4),
            Text(
              'Rs. ${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF144FAB),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDescriptionPage(product: product),
            ),
          );
        },
      ),
    );
  }

  // Product Card Builder (for featured products - horizontal scroll)
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
        width: 160, // Fixed width for horizontal scrolling
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Increased height
            Container(
              height: 160, // Increased from 120
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: product.image_url != null
                    ? Image.network(
                        product.image_url!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 160, // Match container height
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, size: 50, color: Colors.red);
                        },
                      )
                    : Icon(Icons.image, size: 50, color: Colors.grey[700]),
              ),
            ),
            
            // Product Details
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2), // Increased from 4
                  
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text('$dummyRating', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 2), // Increased from 4
                  
                  // Price
                  Text(
                    'Rs. ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF144FAB),
                      fontSize: 14, // Slightly larger font
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

  // Category Item Builder
  Widget _buildCategoryItem(String imagePath, String name) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 0.25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              imagePath,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}