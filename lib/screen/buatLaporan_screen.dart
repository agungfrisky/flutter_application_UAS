import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uts/auth/firebase_auth_service.dart';
import 'package:flutter_application_uts/models/post_model.dart';
import 'package:image_picker/image_picker.dart';

class BuatLaporanPage extends StatefulWidget {
  @override
  _BuatLaporanPageState createState() => _BuatLaporanPageState();
}

class _BuatLaporanPageState extends State<BuatLaporanPage> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile?.path ?? '');
    });
  }

  Map<String, dynamic>? _currentUser;
  Future<void> _fetchUser() async {
    final FirebaseAuthService _authService =
        FirebaseAuthService(FirebaseAuth.instance);
    User? user = await _authService.getCurrentUser();
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _currentUser = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<void> _uploadPost() async {
    await _fetchUser();
    if (_imageFile != null &&
        _captionController.text.isNotEmpty &&
        _locationController.text.isNotEmpty) {
      try {
        String imageUrl = await _uploadImage(_imageFile!);

        final newPostRef = FirebaseFirestore.instance.collection('posts').doc();
        final post = Post(
          imageUrl: imageUrl,
          username: _currentUser?["nama"] ?? 'usr kosong ',
          userid: _currentUser?["uid"] ?? 'uid kosong ',
          caption: _captionController.text,
          location: _locationController.text,
          isFound: false,
          id: newPostRef.id,
        );

        await newPostRef.set(post.toMap());
        _clearForm();
        Navigator.pop(context);
      } catch (e) {
        print('Upss terjadi error saat mengunggah post: $e');
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef =
          storageRef.child('images/${imageFile.path.split('/').last}');

      final uploadTask = imageRef.putFile(imageFile);
      await uploadTask.whenComplete(() {});

      final downloadURL = await imageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Upss terjadi error saat mengunggah gambar: $e');
      throw Exception('Error pada saat mengunggah gambar');
    }
  }

  void _clearForm() {
    _captionController.clear();
    _locationController.clear();
    setState(() {
      _imageFile = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buat Laporan Kehilangan',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _captionController,
              decoration: InputDecoration(labelText: 'Caption'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Lokasi'),
            ),
            SizedBox(height: 20),
            _imageFile == null
                ? Text('Belum ada gambar yang kamu pilih.')
                : Image.file(
                    _imageFile!,
                    height: MediaQuery.of(context).size.height / 2,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text(
                'Pilih Gambar',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.blue,
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.30, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                backgroundColor: Colors.grey[50],
              ),
            ),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text(
                'Unggah',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.30, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
