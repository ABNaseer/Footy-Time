// shop_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new item to the shop
  Future<bool> addItem({
    required String name,
    required String description,
    required double price,
    required String category,
  }) async {
    try {
      String? sellerId = _auth.currentUser?.uid;
      if (sellerId == null) return false;

      await _firestore.collection('shop_items').add({
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'sellerId': sellerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding item: $e');
      return false;
    }
  }

  // Fetch all shop items
  Stream<QuerySnapshot> getShopItems() {
    return _firestore.collection('shop_items').orderBy('createdAt', descending: true).snapshots();
  }

  // Delete an item from the shop
  Future<bool> deleteItem(String itemId) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      DocumentSnapshot item = await _firestore.collection('shop_items').doc(itemId).get();
      if (item.exists && item.get('sellerId') == currentUserId) {
        await _firestore.collection('shop_items').doc(itemId).delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting item: $e');
      return false;
    }
  }
}