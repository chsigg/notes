import 'package:flutter/material.dart';
import 'package:note_trainer/providers/settings_provider.dart';
import 'package:note_trainer/utils/note_mapping.dart';
import 'package:provider/provider.dart';

import 'providers/sessions_provider.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SessionsProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: _MyApp(),
    ),
  );
}

class _MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder:
          (context, settings, child) => MaterialApp(
            title: "Helma's Note Trainer",
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            supportedLocales: NoteLocalizations.supportedLocales,
            localizationsDelegates: [NoteLocalizationsDelegate()],
            locale: settings.locale,
            home: HomePage(),
          ),
    );
  }
}
