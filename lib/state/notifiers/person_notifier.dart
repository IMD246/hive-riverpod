import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../models/person.dart';

List<Person> persons = [
  Person(
    id: "1",
    name: "123",
    age: 4,
  ),
  Person(
    id: "2",
    name: "1234",
    age: 5,
  ),
  Person(
    id: "3",
    name: "12345",
    age: 6,
  ),
];

class PersonNotifier extends ChangeNotifier {
  late Box<Person> _persons;
  late List<Person> listPerson;
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
    await getPersons();
    isLoading = false;
  }

  Future<void> getPersons() async {
    listPerson = _persons.values.toList();
    notifyListeners();
  }

  Future<void> add(Person newPerson) async {
    await _persons.add(newPerson);
    await getPersons();
    notifyListeners();
  }

  Future<void> edit({required Person oldPerson}) async {
    final getPerson = _persons.values.firstWhere(
      (element) => element.id == oldPerson.id,
    );
    _persons.put(getPerson.key, oldPerson);
    await getPersons();
    notifyListeners();
  }

  Future<void> remove({required Person? person}) async {
    await _persons.delete(person?.key);
    await getPersons();
    notifyListeners();
  }
}
