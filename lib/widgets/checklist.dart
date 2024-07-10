import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uts/models/post.dart';

class ChecklistButton extends StatefulWidget {
  final Post post;
  ChecklistButton({required this.post});

  @override
  _ChecklistButtonState createState() => _ChecklistButtonState();
}

class _ChecklistButtonState extends State<ChecklistButton> {
  bool isChecked = false;
  Color buttonColor = Colors.white;
  Color textColor = Colors.blue;
  String buttonText = 'Dicari';
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _initializeButtonState();
  }

  Future<void> _initializeButtonState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isChecked = widget.post.isFound;
        _isOwner = widget.post.userid == user.uid;
        _updateButtonState();
      });
    }
  }

  void _updateButtonState() {
    if (isChecked) {
      buttonColor = Colors.blue;
      textColor = Colors.white;
      buttonText = 'Ditemukan';
    } else {
      buttonColor = Colors.white;
      textColor = Colors.blue;
      buttonText = 'Dicari';
    }
  }

  Future<void> _handleTap() async {
    if (_isOwner) {
      setState(() {
        isChecked = !isChecked;
        _updateButtonState();
      });

      try {
        // Update Firestore document with the correct ID
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.id) // Use post.id here if it is the document ID
            .update({'isFound': isChecked});
      } catch (e) {
        print('Error updating post: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AbsorbPointer(
        absorbing: !_isOwner, // Disable interaction if not the owner
        child: Container(
          width: 100,
          height: 30,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue),
          ),
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
