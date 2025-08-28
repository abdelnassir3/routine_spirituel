import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BilingualDisplay { both, arOnly, frOnly }

final bilingualDisplayProvider =
    StateProvider<BilingualDisplay>((ref) => BilingualDisplay.both);
