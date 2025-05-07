import 'package:afitnessgym/user_cart_screen.dart';
import 'package:afitnessgym/user_my_orders.dart';
import 'package:afitnessgym/main.dart';
import 'package:afitnessgym/user_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Declare the user data
  String firstName = '';
  String lastName = '';
  String address = '';
  String email = '';
  String contact = '';

  @override
  void initState() {
    super.initState();
    // Fetch user data on screen load
    _getUserData();
  }

  // Get the current logged-in user's data from Firebase
  Future<void> _getUserData() async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch the user document from Firestore
        DocumentSnapshot doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        // Update the UI with user data
        setState(() {
          firstName = doc['firstName'] ?? '';
          lastName = doc['lastName'] ?? '';
          address = doc['address'] ?? '';
          email = user.email ?? '';
          contact = doc['contact'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  int _selectedIndex = 3;

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
      backgroundColor: Colors.grey[800],
      appBar: AppBar(title: Text("Profile"), backgroundColor: Colors.black),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile picture and Name
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                '$firstName $lastName',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(email, style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 10),
              Text(
                address,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                contact,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 30),
              // Log out button
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) =>
                        false, // remove all previous routes
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                ),
                child: Text('Log out', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
