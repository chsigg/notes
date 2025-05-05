import 'package:flutter/material.dart';
import 'package:note_trainer/providers/settings_provider.dart';
import 'package:provider/provider.dart';

import 'providers/sessions_provider.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = MaterialApp(
    title: "Helma's Note Trainer",
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: HomePage(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SessionsProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: app,
    ),
  );
}
