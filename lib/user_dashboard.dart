import 'package:afitnessgym/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_product_detail_screen.dart';
import 'user_cart_screen.dart';
import 'user_my_orders.dart';

class StrengthTrainingScreen extends StatefulWidget {
  const StrengthTrainingScreen({super.key});

  @override
  _StrengthTrainingScreenState createState() => _StrengthTrainingScreenState();
}

class _StrengthTrainingScreenState extends State<StrengthTrainingScreen> {
  List<Map<String, dynamic>> products = [];
  List<String> favoriteIds = [];
  // Map<bool> favoriteStatuses = {};
  List<bool> favorites = [];

  @override
  void initState() {
    super.initState();

    fetchProductsFromFirestore();
  }

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredProducts = [];
  Future<void> fetchProductsFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('items').get();
      final fetchedProducts =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'name': data['name'],
              'price': '₱${data['price'].toStringAsFixed(2)} ',
              'image': data['image'],
              'description': data['description'],
              'stocks': data['stocks'],
              'id': data['id'],
            };
          }).toList();

      setState(() {
        products = fetchedProducts;
        filteredProducts = fetchedProducts; // copy for display and search
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  void searchProducts(String query) {
    final results =
        products.where((product) {
          final nameLower = product['name'].toLowerCase();
          final searchLower = query.toLowerCase();

          return nameLower.contains(searchLower);
        }).toList();

    setState(() {
      filteredProducts = results;
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CartScreen()),
        (Route<dynamic> route) => false, // remove all previous routes
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FavoriteScreen()),
        (Route<dynamic> route) => false, // remove all previous routes
      );
    } else if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StrengthTrainingScreen()),
        (Route<dynamic> route) => false, // remove all previous routes
      );
    } else if (index == 3) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
        (Route<dynamic> route) => false, // remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0), // optional
        title: TextField(
          controller: searchController,
          style: TextStyle(color: Colors.white), // White text while typing
          decoration: InputDecoration(
            hintText: 'Search here',
            hintStyle: TextStyle(color: Colors.white70),
            suffixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ), // Optional: lighter white for hint,
            filled: true,
            fillColor: Colors.grey[800], // Grey background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0), // Rounded corners
              borderSide: BorderSide.none, // No border
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 16.0,
            ),
          ),
          onChanged: searchProducts,
        ),
      ),

      backgroundColor: Colors.grey[800],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🛒 GridView of Products
            filteredProducts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isFavorites =
                        favorites.length > index && favorites[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(
                                  id: product['id'],
                                  productName: product['name'],
                                  productPrice: product['price'],
                                  productImage: product['image'],
                                  productDescription: product['description'],
                                ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.network(
                              product['image'],
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                product['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product['price'],
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.green[300],
        backgroundColor: Colors.black, // Set background color to black

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'My orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
