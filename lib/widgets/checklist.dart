import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uts/home.dart';
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

  @override
  void initState() {
    super.initState();
    isChecked = widget.post.isFound;
    _updateButtonState();
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

  void _handleTap() {
    setState(() {
      isChecked = !isChecked;
      _updateButtonState();
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.imageUrl)
          .update({
        'isFound': isChecked,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
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
    );
  }
}
