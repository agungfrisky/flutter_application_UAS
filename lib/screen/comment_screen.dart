import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uts/models/comment_model.dart';
import 'package:flutter_application_uts/models/post_model.dart';

class CommentPage extends StatefulWidget {
  final Post post;
  CommentPage({required this.post});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final List<Comment> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  late String _currentUser;
  late StreamSubscription<QuerySnapshot> _commentsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchComments();
  }

  Future<void> _fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _currentUser = userData?['nama'] ?? 'Anonymous';
          });
        } else {
          setState(() {
            _currentUser = 'Anonymous';
          });
        }
      } catch (e) {
        print('Error fetching user: $e');
        setState(() {
          _currentUser = 'Anonymous';
        });
      }
    } else {
      setState(() {
        _currentUser = 'Anonymous';
      });
    }
  }

  String sanitizeDocumentId(String id) {
    return id.replaceAll(RegExp(r'[/\\]'), '_');
  }

  Future<void> _fetchComments() async {
    final sanitizedId = sanitizeDocumentId(widget.post.imageUrl);
    final commentsStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(sanitizedId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();

    _commentsSubscription = commentsStream.listen((snapshot) {
      if (mounted) {
        setState(() {
          _comments.clear();
          for (var doc in snapshot.docs) {
            _comments.add(Comment.fromMap(doc.data()));
          }
        });
      }
    });
  }

  void _handlePost() {
    if (_commentController.text.isNotEmpty) {
      final comment = Comment(
        user: _currentUser,
        comment: _commentController.text,
        timestamp: Timestamp.now(),
      );
      final sanitizedId = sanitizeDocumentId(widget.post.imageUrl);
      FirebaseFirestore.instance
          .collection('posts')
          .doc(sanitizedId)
          .collection('comments')
          .add(comment.toMap());
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentsSubscription.cancel();
    _commentController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Komentar',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: CommentList(comments: _comments)),
          Divider(),
          CommentInput(controller: _commentController, onPost: _handlePost),
        ],
      ),
    );
  }
}

class CommentList extends StatelessWidget {
  final List<Comment> comments;

  CommentList({required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView(
      reverse: true,
      children:
          comments.map((comment) => CommentItem(comment: comment)).toList(),
    );
  }
}

class CommentItem extends StatelessWidget {
  final Comment comment;

  CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        comment.user,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.comment),
          Text(
            comment.timestamp.toDate().toString(),
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPost;

  CommentInput({required this.controller, required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration.collapsed(
                  hintText: 'Ayo tuliskan komentarmu...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: onPost,
          ),
        ],
      ),
    );
  }
}
