import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/sessions_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/home_page.dart';
import 'utils/note_mapping.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final fontLoader = FontLoader('StaffClefPitches');
  fontLoader.addFont(rootBundle.load('assets/fonts/staff_clef_pitches.ttf'));
  await fontLoader.load();

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
    const seedColor = Colors.orange;
    return Consumer<SettingsProvider>(
      builder:
          (context, settings, child) => MaterialApp(
            title: "Helma's Note Trainer",
            theme: ThemeData(colorSchemeSeed: seedColor),
            darkTheme: ThemeData(
              colorSchemeSeed: seedColor,
              brightness: Brightness.dark,
            ),
            supportedLocales: NoteLocalizations.supportedLanguages.map(
              (language) => Locale(language),
            ),
            localizationsDelegates: [
              NoteLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale:
                settings.language != null ? Locale(settings.language!) : null,
            home: HomePage(),
          ),
    );
  }
}
