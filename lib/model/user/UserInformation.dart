// To parse this JSON data, do
//
//     final userPhoto = userPhotoFromJson(jsonString);

import 'dart:convert';

UserPhoto userPhotoFromJson(String str) => UserPhoto.fromJson(json.decode(str));

String userPhotoToJson(UserPhoto data) => json.encode(data.toJson());

class UserPhoto {
  Photo photo;

  UserPhoto({
    required this.photo,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) => UserPhoto(
        photo: Photo.fromJson(json["photo"]),
      );

  Map<String, dynamic> toJson() => {
        "photo": photo.toJson(),
      };
}

class Photo {
  String? extension;
  String? url;

  Photo({
    required this.extension,
    required this.url,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        extension: json["extension"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "extension": extension,
        "url": url,
      };
}
