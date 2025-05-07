import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_checkout_screen.dart'; // Import the CheckoutScreen

class ProductDetailScreen extends StatefulWidget {
  final String id;
  final String productName;
  final String productPrice;
  final String productImage;
  final String productDescription;

  const ProductDetailScreen({
    Key? key,
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDescription,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedIndex = 0;

  Future<void> addToCart(String itemId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cartDocRef = FirebaseFirestore.instance
        .collection('items')
        .doc(itemId)
        .collection('addCart')
        .doc(userId); // Use user ID as the doc ID

    final docSnapshot = await cartDocRef.get();

    if (docSnapshot.exists) {
      // If already in cart, increment the quantity
      final currentQuantity = docSnapshot.data()?['quantity'] ?? 0;
      await cartDocRef.update({
        'quantity': currentQuantity + 1,
        'updatedAt': Timestamp.now(),
      });
    } else {
      // If not in cart, create with quantity 1
      await cartDocRef.set({
        'userId': userId,
        'quantity': 1,
        'addedAt': Timestamp.now(),
      });
      print('Added to cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Detail',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.grey[800],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image (Smaller size)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.productImage,
                height: 350, // Reduced the image height
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 40),

            // Product Name
            Text(
              widget.productName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Product Price
            Text(
              widget.productPrice,
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 30),

            // Buttons
            ElevatedButton(
              onPressed:
                  () => {
                    addToCart(widget.id),
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Added to Cart'))),
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
