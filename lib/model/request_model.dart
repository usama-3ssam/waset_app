import 'package:waste_app/model/user_model.dart';

class RequestModel extends UserModel {
  @override
  String? name;
  @override
  String? uId;
  @override
  String? image;
  String? dateTime;
  String? text;
  String? location;
  String? requestId;

  RequestModel({
    this.name,
    this.uId,
    this.image,
    this.dateTime,
    this.location,
    this.text,
    this.requestId,
  });

  RequestModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uId = json['uId'];
    image = json['image'];
    dateTime = json['dateTime'];
    text = json['text'];
    location = json['location'];
    requestId = json['postId'];
  }

  // List<String> likes = [];
  // String? get postId => null;
  // final String? postId;
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uId': uId,
      'image': image,
      'dateTime': dateTime,
      'text': text,
      'location': location,
    };
  }
}

// class GetPostModel extends PostModel {
//   @override
//   String? postId;
//
//   /// contains uIds of users who liked the post
//   @override
//   dynamic likes;
//
//   GetPostModel({
//     required String name,
//     required String uId,
//     required String image,
//     required String text,
//     required String postImage,
//     required String dateTime,
//     required int milSecEpoch,
//     required this.postId,
//     required this.likes,
//   }) : super(
//           // name: name,
//           // uId: uId,
//           // image: image,
//           text: text,
//           postImage: postImage,
//           dateTime: dateTime,
//         );
//
//   GetPostModel.fromJson({
//     required Map<String, dynamic> json,
//     required this.postId,
//     required this.likes,
//   }) : super.fromJson(json);
// }
