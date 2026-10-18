import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prbd_2526_f02/app/my_app.dart';
import 'core/tools/params.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Params.init();
  runApp(
      ProviderScope(
        // observers: [MyProviderObserver()], // import + décommanter les 2 lignes si vous voulez avoir la feature de la FAQ 10
        // retry: (int _, Object _) => null,
        child: MyApp(),
      )
  );
}
