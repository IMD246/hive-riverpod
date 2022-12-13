import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'firebase_options.dart';
import 'models/person.dart';
import 'state/providers/person_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    Hive.close();
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              final person = await createOrUpdatePerson(context: context);
              if (person != null) {
                ref.read(personProvider.notifier).add(person);
              }
            },
          );
        },
      ),
      appBar: AppBar(title: const Text("Home Page")),
      body: const PersonsWidget(),
    );
  }
}

class PersonsWidget extends ConsumerWidget {
  const PersonsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(personProvider);
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: provider.listPerson.length,
          itemBuilder: (context, index) {
            final person = provider.listPerson.elementAt(index);
            return PersonItem(person: person);
          },
        );
      },
    );
  }
}

class PersonItem extends ConsumerWidget {
  const PersonItem({super.key, required this.person});
  final Person person;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () async {
        final updatedPerson =
            await createOrUpdatePerson(context: context, person: person);
        if (updatedPerson != null) {
          await ref.read(personProvider.notifier).edit(
                oldPerson: updatedPerson,
              );
        }
      },
      title: Text(
        person.toString(),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await ref.read(personProvider.notifier).remove(
                person: person,
              );
        },
      ),
    );
  }
}

TextEditingController nameController = TextEditingController();
TextEditingController ageController = TextEditingController();

Future<Person?> createOrUpdatePerson(
    {required BuildContext context, Person? person}) {
  String name = person?.name ?? "";

  int? age = person?.age;

  nameController.text = name;

  ageController.text = age?.toString() ?? "";

  return showDialog<Person?>(
    context: context,
    builder: (c) {
      return AlertDialog(
        title: Text(
          person != null ? "Update Person" : "Create Person",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Name",
              ),
              onChanged: (value) {
                name = value;
              },
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                hintText: "age",
              ),
              onChanged: (value) {
                age = int.tryParse(value) ?? 0;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(c).pop(null);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (name.isNotEmpty && age != null) {
                      if (person != null) {
                        final updatedPerson =
                            person.copyWith(name: name, age: age);
                        Navigator.of(context).pop(updatedPerson);
                      } else {
                        final newPerson = Person(name: name, age: age!);
                        Navigator.of(context).pop(newPerson);
                      }
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
