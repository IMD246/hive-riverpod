import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../notifiers/person_notifier.dart';

final personProvider = ChangeNotifierProvider(
  (_) => PersonNotifier(),
);
