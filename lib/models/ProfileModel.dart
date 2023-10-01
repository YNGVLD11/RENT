// ignore_for_file: file_names

class ProfileModel {
  String uid;
  String name; // Имя

  ProfileModel({
    required this.uid,
    required this.name,
  });

  factory ProfileModel.fromJson(Map json) => ProfileModel(
        uid: json['uid'],
        name: json['name'],
      );
}
