import 'package:amazetalk_flutter/features/auth/domain/entities/user_entity.dart';

import 'img_saver.dart';

class UserModel extends UserEntity {
  UserModel(
      {required super.id,
      required super.name,
      required super.email,
      required super.image,
      required super.token});

  @override
  String toString() {
    return 'UserModel{$id, $email, $name,$token   , $image}';
  }

  static Future<UserModel> fromJson(Map<String, dynamic> json) async {
    final imagePath = await ImageSaver.saveImageToGallery(json['image']);

    print('saved path: $imagePath');
    return UserModel(
        id: json['_id'] ?? '', // Ensure safe access
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        token: json["token"] ?? '',
        image: imagePath ?? '');
    // );
  }
}
