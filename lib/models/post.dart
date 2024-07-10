class Post {
  final String imageUrl;
  final String username;
  final String userid;
  final String caption;
  final String location;
  final bool isFound;
  final String id; // Add this line for the document ID

  Post({
    required this.imageUrl,
    required this.username,
    required this.userid,
    required this.caption,
    required this.location,
    required this.isFound,
    required this.id, // Initialize the id
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'username': username,
      'userid': userid,
      'caption': caption,
      'location': location,
      'isFound': isFound,
    };
  }

  static Post fromMap(Map<String, dynamic> map, String id) {
    return Post(
      imageUrl: map['imageUrl'],
      username: map['username'],
      userid: map['userid'],
      caption: map['caption'],
      location: map['location'],
      isFound: map['isFound'],
      id: id, // Set the id
    );
  }
}
