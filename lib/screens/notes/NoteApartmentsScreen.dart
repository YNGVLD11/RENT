// ignore_for_file: depend_on_referenced_packages, unnecessary_null_comparison

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:p/models/ApartmentModel.dart';
import 'package:p/repository/finestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p/screens/notes/AddApartmentsForm.dart';

/// The details screen for either the A or B screen.
class NoteApartmentsScreen extends StatefulWidget {
  /// Constructs a [NoteDetailScreen].
  const NoteApartmentsScreen({
    required this.label,
    required this.detailsApartmentPath,
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

  /// The path to the detail page
  final String detailsApartmentPath;

  @override
  State<StatefulWidget> createState() => NoteApartmentsScreenState();
}

//функция преобразования списка снапшотов коллекции в список сообщений
StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<ApartmentModel>>
    documentToApartmentsTransformer = StreamTransformer<
            QuerySnapshot<Map<String, dynamic>>,
            List<ApartmentModel>>.fromHandlers(
        handleData: (QuerySnapshot<Map<String, dynamic>> snapShot,
            EventSink<List<ApartmentModel>> sink) {
  List<ApartmentModel> result = [];
  for (var element in snapShot.docs) {
    FirestoreService.getApartments(element.id).then((value) {
      if (value != null) {
        result.add(ApartmentModel(
          address: value['address'],
          number: value['number'],
          mainPhoto: value['mainPhoto'],
          validPhoto: value['validPhoto'],
        ));
        sink.add(result = List.from(result.reversed));
      }
    });
  }
  sink.add(result = List.from(result.reversed));
});

/// The state for DetailsScreen
class NoteApartmentsScreenState extends State<NoteApartmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Квартиры - Список квартир'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('apartments')
              .snapshots()
              .transform(documentToApartmentsTransformer),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return _streamChatsWidget(context, snapshot.data);
              } else {
                return _emptyMessage();
              }
            }
            if (snapshot.hasError) {
              return Text('Произошла ошибка загрузки: ${snapshot.error}');
            }
            return Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DocumentReference ref =
              FirebaseFirestore.instance.collection('apartments').doc();
          print('Идентификатор квартиры: ${ref.id}');
          FirestoreService.addApartment('', '', '', ref.id);
          setState(() {
            showDialog(
                context: context,
                builder: (context) => AddApartmentsForm(
                      uid: ref.id,
                    ));
          });
        },
        //Beamer.of(context).beamToNamed(widget.detailsHomePhonePath),
        tooltip: 'Добавить',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _streamChatsWidget(context, List<ApartmentModel> apartmetnsList) {
  if (apartmetnsList.isEmpty) {
    return _emptyMessage();
  } else {
    return ListView.builder(
        itemCount: apartmetnsList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 250,
            width: MediaQuery.of(context).size.width,
            child: Card(
              child: Column(children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: apartmetnsList[index].mainPhoto == null ||
                                  apartmetnsList[index].mainPhoto == ''
                              ? const NetworkImage(
                                  'https://careappointments.com/wp-content/uploads/2018/10/no_image_placeholder.png')
                              : NetworkImage(apartmetnsList[index].mainPhoto))),
                ),
                Text(
                  'Квартира ${apartmetnsList[index].number}',
                  style: const TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      'Адрес: ${apartmetnsList[index].address}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ]),
            ),
          );
        });
  }
}

Widget _emptyMessage() {
  return Center(
    child: Container(
      child: const Text(
        'Квартир нет',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14.0),
      ),
    ),
  );
}
