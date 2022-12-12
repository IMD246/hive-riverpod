import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../models/person.dart';

class PersonNotifier extends ChangeNotifier {
  late Box<Person> _persons;
  List<Person> listPerson = [];
  bool isLoading = false;
  PersonNotifier() {
    init();
  }
  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    if (!Hive.isAdapterRegistered(PersonAdapter().typeId)) {
      Hive.registerAdapter(PersonAdapter());
    }
    _persons = await Hive.openBox('persons');
    // listPerson = _persons.values.toList();
    await getPersons();
    isLoading = false;
  }

  Future<void> getPersons() async {
    int count = 0;
    await FirebaseFirestore.instance.collection('persons').get().then((event) {
      for (var d in event.docs) {
        log(d.data().toString());
        final person = Person.fromMap(d.data());
        log(person.toString());
      }
      // return event.docs.map((e) {
      //   // log(event.docs.elementAt(0).data().toString());
      //   log(e.toString());
      //   return e.data().toString();
      //   // log(event.size.toString());

      //   // return event.docs.map((e) {
      //   //   count++;
      //   //   final person = Person.fromMap(e.data());
      //   //   log(count.toString());
      //   //   log(person.toString());
      //   //   return;
      //   // });
      // });
    });

    // log(value.size.toString());
    // log(value.docs.map((e) => ));
    // value.docs.map((e) {
    //   final person = Person.fromMap(e.data());
    //   log(person.toString());
    //   // listPerson.add(Person.fromMap(e.data()))
    // });
    // log(value.docs.map((e)));
    // log(value.docChanges.toString());
    // if (_persons.values.isNotEmpty) {
    //   listPerson = _persons.values.to;
    // }
    // listPerson = _persons.values.toList();
    notifyListeners();
  }

  Future<void> add(Person newPerson) async {
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(newPerson.id)
        .set(newPerson.toMap());

    // await _persons.put(
    //   newPerson.id.toString(),
    //   newPerson,
    // );

    listPerson.add(newPerson);

    notifyListeners();
  }

  Future<void> edit({required Person oldPerson}) async {
    final getIndex = listPerson.indexWhere(
      (element) => element.id == oldPerson.id,
    );
    final getPerson = listPerson[getIndex];

    await _persons.put(getPerson.key, oldPerson);

    listPerson[getIndex] = listPerson[getIndex].copyWith(
      age: oldPerson.age,
      name: oldPerson.name,
    );

    notifyListeners();
  }

  Future<void> remove({required Person? person}) async {
    await _persons.delete(person?.key);

    listPerson.remove(person);

    notifyListeners();
  }
}
