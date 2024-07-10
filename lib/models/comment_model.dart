import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String user;
  final String comment;
  final Timestamp timestamp;

  Comment({
    required this.user,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  static Comment fromMap(Map<String, dynamic> map) {
    return Comment(
      user: map['user'],
      comment: map['comment'],
      timestamp: map['timestamp'],
    );
  }
}
