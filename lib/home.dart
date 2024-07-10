import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uts/buatLaporan.dart';
import 'package:flutter_application_uts/comment.dart';
import 'package:flutter_application_uts/models/post.dart';
import 'package:flutter_application_uts/profile.dart';
import 'package:flutter_application_uts/widgets/checklist.dart';

class homepage extends StatefulWidget {
  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final List<Post> _posts = [];
  StreamSubscription<QuerySnapshot>? _postsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    _postsSubscription = FirebaseFirestore.instance
        .collection('posts')
        .snapshots()
        .listen((snapshot) {
      print("Data received from Firestore: ${snapshot.docs.length} documents");
      if (mounted) {
        setState(() {
          _posts.clear();
          for (var doc in snapshot.docs) {
            _posts
                .add(Post.fromMap(doc.data() as Map<String, dynamic>, doc.id));
          }
          _posts.sort((a, b) => b.caption.compareTo(a.caption));
        });
      }
    });
  }

  @override
  void dispose() {
    _postsSubscription
        ?.cancel(); // Cancel the subscription to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Ma-Link Feed',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
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
                        backgroundImage:
                            AssetImage('asset_media/gambar/icon/acc.jpeg'),
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
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
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
                        child:
                            Icon(Icons.chat_bubble_outline, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BuatLaporanPage()),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
