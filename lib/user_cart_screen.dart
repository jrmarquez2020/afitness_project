import 'package:afitnessgym/user_my_orders.dart';
import 'package:afitnessgym/user_profile_screen.dart';
import 'package:afitnessgym/user_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/cart_data.dart'; // Import the global cart list
// Import CartItem model
import 'user_checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Function to calculate total price in pesos
  double getTotalPrice() {
    double total = 0.0;
    for (var item in cartItems) {
      // Clean the price string to remove non-numeric characters (except the decimal point)
      String cleanedPrice = item.price.replaceAll(RegExp(r'[^\d.]'), '');
      double itemPrice = double.tryParse(cleanedPrice) ?? 0.0;
      total += itemPrice;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    fetchUserCartWithTotal();
  }

  Future<void> updateCartQuantity({
    required String itemId,
    required int change, // +1 or -1
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cartDocRef = FirebaseFirestore.instance
        .collection('items')
        .doc(itemId)
        .collection('addCart')
        .doc(userId);

    final cartDoc = await cartDocRef.get();
    int currentQty = (cartDoc.data()?['quantity'] ?? 0).toInt();

    int newQty = currentQty + change;

    if (newQty <= 0) {
      await cartDocRef.delete(); // Remove item if quantity is 0 or less
    } else {
      await cartDocRef.set({'quantity': newQty});
    }
  }

  Future<Map<String, dynamic>> fetchUserCartWithTotal() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return {'items': [], 'total': 0.0};

    final itemsCollection = FirebaseFirestore.instance.collection('items');
    final allItemsSnapshot = await itemsCollection.get();

    List<Map<String, dynamic>> cartItems = [];
    double grandTotal = 0.0;

    for (var itemDoc in allItemsSnapshot.docs) {
      final itemId = itemDoc.id;
      final price = (itemDoc.data()['price'] ?? 0).toDouble();

      final cartDoc =
          await itemsCollection
              .doc(itemId)
              .collection('addCart')
              .doc(userId)
              .get();

      if (cartDoc.exists) {
        final quantity = (cartDoc.data()?['quantity'] ?? 0).toInt();
        final itemTotal = price * quantity;

        grandTotal += itemTotal;

        cartItems.add({
          'itemId': itemId,
          'name': itemDoc.data()['name'] ?? 'No Name',
          'image': itemDoc.data()['image'] ?? '',
          'price': price,
          'quantity': quantity,
          'total': itemTotal,
        });
      }
    }

    return {'items': cartItems, 'total': grandTotal};
  }

  Future<void> deleteCartItem(String itemId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cartDocRef = FirebaseFirestore.instance
        .collection('items')
        .doc(itemId)
        .collection('addCart')
        .doc(userId);

    try {
      await cartDocRef.delete();
      print('Item removed from cart');
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }

  int _selectedIndex = 1;

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
        title: const Text('Your Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      backgroundColor: Colors.grey[800],
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: fetchUserCartWithTotal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    (snapshot.data?['items'] as List).isEmpty) {
                  return const Center(
                    child: Text(
                      'No items in cart!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                // ✅ PLACE IT HERE:
                final cartItems =
                    snapshot.data!['items'] as List<Map<String, dynamic>>;
                final total =
                    (snapshot.data!['total'] as num)
                        .toDouble(); // ✅ this line right here

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final product = cartItems[index];
                          return Card(
                            color: Colors.grey[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading:
                                  product['image'] != null
                                      ? Image.network(
                                        product['image'],
                                        fit: BoxFit.cover,
                                        height: 30,
                                        width: 30,
                                      )
                                      : const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                      ),
                              title: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        product['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '₱ ${product['price']?.toStringAsFixed(2) ?? ''} ',
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    children: [
                                      Center(
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                await updateCartQuantity(
                                                  itemId: product['itemId'],
                                                  change: -1,
                                                );
                                                setState(() {}); // Refresh UI
                                                // or use a state management trigger to refresh the car
                                              },
                                              icon: const Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              '${product['quantity']}',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await updateCartQuantity(
                                                  itemId: product['itemId'],
                                                  change: 1,
                                                );
                                                setState(() {}); // Refresh UI
                                                // or use a state management trigger to refresh the car
                                              },
                                              icon: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              trailing: IconButton(
                                onPressed: () async {
                                  await deleteCartItem(product['itemId']);
                                  setState(
                                    () {},
                                  ); // or use a state management trigger to refresh the car
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ✅ Display Total
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            '₱${total.toStringAsFixed(2)}', // this will now work!
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Proceed to Checkout Button
          ElevatedButton(
            onPressed: () {
              // Navigate to Checkout Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckoutScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff587ed5),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'CHECKOUT',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),
        ],
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
