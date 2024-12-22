// shop.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/shop_service.dart';
import '../models/item_model.dart';
import '../services/user_service.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final ShopService _shopService = ShopService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddItemDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _shopService.getShopItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<Item> items = snapshot.data!.docs.map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(items[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            Text('Price: \$${item.price.toStringAsFixed(2)}'),
            Text('Category: ${item.category}'),
            FutureBuilder<Map<String, dynamic>?>(
              future: _userService.fetchPublicUserProfile(item.sellerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading seller info...');
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Error loading seller info');
                }
                return Text('Seller: ${snapshot.data!['name']} - ${snapshot.data!['phone']}');
              },
            ),
          ],
        ),
        trailing: FirebaseAuth.instance.currentUser?.uid == item.sellerId
            ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteItem(item.id),
              )
            : null,
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    String name = '';
    String description = '';
    double price = 0.0;
    String category = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Item'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: "Item Name"),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Description"),
                  onChanged: (value) => description = value,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Price"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Category"),
                  onChanged: (value) => category = value,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                bool success = await _shopService.addItem(
                  name: name,
                  description: description,
                  price: price,
                  category: category,
                );
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Item added successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add item')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String itemId) async {
    bool success = await _shopService.deleteItem(itemId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item')),
      );
    }
  }
}