// ignore_for_file: depend_on_referenced_packages, unused_import, file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class HomePhoneModel {
  String address;
  String code; // Имя

  HomePhoneModel({
    required this.address,
    required this.code,
  });

  factory HomePhoneModel.fromJson(Map json) => HomePhoneModel(
        address: json['address'],
        code: json['code'],
      );
}
