import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_uts/comment.dart';
import 'package:flutter_application_uts/firebase_auth_service.dart';
import 'package:flutter_application_uts/login.dart';
import 'package:flutter_application_uts/models/post.dart';
import 'package:flutter_application_uts/widgets/checklist.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  final List<Post> _posts = [];
  Future<void> _fetchPosts() async {
    final FirebaseAuthService _authService =
        FirebaseAuthService(FirebaseAuth.instance);
    User? user = await _authService.getCurrentUser();
    FirebaseFirestore.instance
        .collection('posts')
        .where('userid', isEqualTo: user?.uid ?? "uid Kosong")
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _posts.clear();
        for (var doc in snapshot.docs) {
          _posts.add(Post.fromMap(doc.data()));
        }
        _posts.sort((a, b) => b.caption.compareTo(a.caption));
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUser();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('asset_media/gambar/icon/acc.jpeg'),
            ),
            SizedBox(height: 10.0),
            Text(
              _currentUser?["nama"] ??
                  "User Kosong", // Placeholder, replace with actual username
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => login()),
                );
              },
              child: Text('Logout'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18.0,
                                backgroundImage: AssetImage(
                                    'asset_media/gambar/icon/acc.jpeg'),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                _posts[index].username,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Image.network(_posts[index].imageUrl),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 8.0, right: 10.0, bottom: 8.0),
                          child: Text(
                            _posts[index].caption,
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Text(
                            "Lokasi: " + _posts[index].location,
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 8.0, right: 10.0, bottom: 10.0),
                          child: Row(
                            children: [
                              ChecklistButton(post: _posts[index]),
                              SizedBox(width: 12.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CommentPage(post: _posts[index])),
                                  );
                                },
                                child: Icon(Icons.chat_bubble_outline,
                                    color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
