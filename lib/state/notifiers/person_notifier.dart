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
    notifyListeners();
    if (!Hive.isAdapterRegistered(PersonAdapter().typeId)) {
      Hive.registerAdapter(PersonAdapter());
    }
    _persons = await Hive.openBox('persons');
    listPerson = _persons.values.toList();
    await getPersons();
  }

  Future<void> getPersons() async {
    isLoading = true;
    notifyListeners();
    await FirebaseFirestore.instance.collection('persons').get().then((event) {
      for (var d in event.docs) {
        log(d.data().toString());
        final person = Person.fromMap(d.data());
        parsePerson(id: d.id, person: person);
        log(person.toString());
      }
    });
    isLoading = false;
    notifyListeners();
  }

  Future<void> parsePerson({required String id, required Person person}) async {
    if (!_persons.containsKey(id)) {
      await add(person);
      listPerson.add(person);
    }
  }

  Future<void> add(Person newPerson) async {
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(newPerson.id)
        .set(newPerson.toMap());

    await _persons.put(
      newPerson.id.toString(),
      newPerson,
    );

    listPerson.add(newPerson);

    notifyListeners();
  }

  Future<void> edit({required Person oldPerson}) async {
    final getIndex = listPerson.indexWhere(
      (element) => element.id == oldPerson.id,
    );

    final getPerson = listPerson[getIndex];
    if (getIndex >= 0) {
      await FirebaseFirestore.instance
          .collection('persons')
          .doc(oldPerson.id)
          .update(oldPerson.toMap());

      await _persons.put(getPerson.id, oldPerson);

      listPerson[getIndex] = listPerson[getIndex].copyWith(
        age: oldPerson.age,
        name: oldPerson.name,
      );
      notifyListeners();
    }
  }

  Future<void> remove({required Person person}) async {
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(person.id)
        .delete();

    await _persons.delete(person.id);

    listPerson.remove(person);

    notifyListeners();
  }
}
