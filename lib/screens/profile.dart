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
          return Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data', style: TextStyle(color: Colors.red)));
        }

        final userData = snapshot.data ?? {};

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green.shade50, Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Profile',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildEditableField(
                              label: 'Name',
                              value: userData['name'] ?? 'N/A',
                              isEditing: _isEditingName,
                              controller: _nameController,
                              onTap: () {
                                setState(() {
                                  _isEditingName = true;
                                  _nameController.text = userData['name'] ?? '';
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
                              showEditIcon: false,
                            ),
                            _buildEditableField(
                              label: 'Phone Number',
                              value: userData['phone'] ?? 'N/A',
                              isEditing: _isEditingPhone,
                              controller: _phoneController,
                              onTap: () {
                                setState(() {
                                  _isEditingPhone = true;
                                  _phoneController.text = userData['phone'] ?? '';
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
                              showEditIcon: false,
                            ),
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
                                      style: TextStyle(color: Colors.green.shade800),
                                      dropdownColor: Colors.green.shade50,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Match Stats',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildStatField(label: 'Match MVP', value: userData['matchMVP'] ?? 0),
                            _buildStatField(label: 'Goals ⚽', value: userData['goals'] ?? 0),
                            _buildStatField(label: 'Assists', value: userData['assists'] ?? 0),
                            _buildStatField(label: 'Yellow Cards', value: userData['yellowCards'] ?? 0),
                            _buildStatField(label: 'Red Cards', value: userData['redCards'] ?? 0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatField({required String label, required dynamic value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
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
    bool showEditIcon = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: isEditing
                    ? (dropdown ??
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: value,
                            filled: true,
                            fillColor: Colors.green.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: Colors.green.shade800),
                        ))
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
              ),
              if (showEditIcon)
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.check : Icons.edit,
                    color: Colors.green.shade800,
                  ),
                  onPressed: isEditing ? onSave : onTap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

