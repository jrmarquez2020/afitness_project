import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'firstName': data['firstName'], 'lastName': data['lastName']};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Text("Users", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                tileColor: Colors.white,
                leading: Icon(Icons.person_3_rounded),
                title: Text(
                  '${user['firstName']} ${user['lastName']}',
                  style: TextStyle(color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
