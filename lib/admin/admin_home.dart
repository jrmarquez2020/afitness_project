import 'package:afitnessgym/admin/admin_orders.dart';
import 'package:afitnessgym/admin/admin_products.dart';
import 'package:afitnessgym/admin/admin_statistics.dart';
import 'package:afitnessgym/admin/admin_transaction.dart';
import 'package:afitnessgym/admin/admin_users.dart';
import 'package:afitnessgym/main.dart';
import 'package:flutter/material.dart';

class admin_home extends StatefulWidget {
  const admin_home({super.key});

  @override
  State<admin_home> createState() => _admin_homeState();
}

class _admin_homeState extends State<admin_home> {
  @override
  final List<String> gridName = [
    'USERS',
    'PRODUCTS',
    'ORDERS',
    'TRANSACTIONS',
    'SALES ANALYTICS',
  ];
  void changeScreen(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Users(),
        ), // Change to CheckoutScreen
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const admin_products(),
        ), // Change to CheckoutScreen
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const admin_orders(),
        ), // Change to CheckoutScreen
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const admin_transactions(),
        ), // Change to CheckoutScreen
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminStatistics(),
        ), // Change to CheckoutScreen
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false, // remove all previous routes
              );
            },
            icon: Icon(Icons.logout_outlined, color: Colors.red),
          ),
        ],
      ),
      backgroundColor: Colors.grey[800],
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 16,
              ),
              itemCount: gridName.length,
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    changeScreen(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          gridName[index],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
