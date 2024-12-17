import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad/services/user_service.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String? _selectedPosition;

  final List<String> _positions = ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'];

  bool _isEditingName = false;
  bool _isEditingPhone = false;
  bool _isEditingPosition = false;

  Future<Map<String, dynamic>> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() ?? {};
    }
    return {};
  }

  Future<void> _updateProfile(String field, String value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({field: value});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        final userData = snapshot.data ?? {};

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Name Field
                _buildEditableField(
                  label: 'Name',
                  value: userData['name'] ?? 'N/A',
                  isEditing: _isEditingName,
                  controller: _nameController,
                  onTap: () {
                    setState(() {
                      _isEditingName = true;
                    });
                  },
                  onSave: () {
                    if (_nameController.text.isNotEmpty) {
                      _updateProfile('name', _nameController.text);
                      setState(() {
                        _isEditingName = false;
                      });
                    }
                  },
                ),

                // Phone Field
                _buildEditableField(
                  label: 'Phone Number',
                  value: userData['phone'] ?? 'N/A',
                  isEditing: _isEditingPhone,
                  controller: _phoneController,
                  onTap: () {
                    setState(() {
                      _isEditingPhone = true;
                    });
                  },
                  onSave: () {
                    if (_phoneController.text.isNotEmpty) {
                      _updateProfile('phone', _phoneController.text);
                      setState(() {
                        _isEditingPhone = false;
                      });
                    }
                  },
                ),

                // Position Field
                _buildEditableField(
                  label: 'Primary Position',
                  value: userData['primaryPosition'] ?? 'N/A',
                  isEditing: _isEditingPosition,
                  controller: TextEditingController(text: userData['primaryPosition']),
                  onTap: () {
                    setState(() {
                      _isEditingPosition = true;
                    });
                  },
                  onSave: () {
                    if (_selectedPosition != null) {
                      _updateProfile('primaryPosition', _selectedPosition!);
                      setState(() {
                        _isEditingPosition = false;
                      });
                    }
                  },
                  dropdown: _isEditingPosition
                      ? DropdownButton<String>(
                          value: _selectedPosition,
                          items: _positions.map((String position) {
                            return DropdownMenuItem<String>(
                              value: position,
                              child: Text(position),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPosition = value;
                            });
                          },
                        )
                      : null,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback onTap,
    required VoidCallback onSave,
    Widget? dropdown,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              SizedBox(height: 4),
              isEditing
                  ? (dropdown ??
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: value,
                        ),
                      ))
                  : Text(value),
            ],
          ),
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onTap,
            ),
          if (isEditing)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: onSave,
            ),
        ],
      ),
    );
  }
}
