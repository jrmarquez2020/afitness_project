import 'package:afitnessgym/user_cart_screen.dart';
import 'package:afitnessgym/user_profile_screen.dart';
import 'package:afitnessgym/user_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int _selectedIndex = 2;
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

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Accessing orders directly under users/{userId}/myOrders
    final ordersSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('myOrders')
            .get();

    List<Map<String, dynamic>> orders = [];

    for (var orderDoc in ordersSnapshot.docs) {
      final orderData = orderDoc.data();
      orders.add(orderData);
    }

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My order', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.grey[800],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No favorites yet!',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final favorites = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final order = favorites[index];
              final items = List<Map<String, dynamic>>.from(
                order['items'] ?? [],
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${order['fullName'] ?? 'Unknown'}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Address: ${order['address'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    'Contact: ${order['contact'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    'Status: ${order['modeOfPayment'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    'Status: ${order['status'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...items.map((item) {
                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Image.network(
                          item['image'] ??
                              'assets/placeholder.jpg', // Fallback image
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
                        title: Text(
                          item['name'] ?? 'No Name',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '₱${item['price']?.toString() ?? '0'} x ${item['quantity']?.toString() ?? '1'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          '₱${item['total']?.toString() ?? '0'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
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
