import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:notes/models/session_config.dart';
import 'package:provider/provider.dart';

import 'providers/sessions_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/home_page.dart';
import 'utils/note_mapping.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = await SettingsProvider.load();
  final sessions = await SessionsProvider.load();

  void handleUri(Uri? uri) {
    if (uri == null) return;
    uri.queryParametersAll['lang']?.forEach((lang) => settings.language = lang);
    uri.queryParametersAll['session']?.forEach(
      (base64) => sessions.updateConfig(SessionConfig.fromBase64(base64)),
    );
  }

  final appLinks = AppLinks();
  handleUri(await appLinks.getInitialLink());
  PathUrlStrategy().replaceState(null, '', '/');
  if (sessions.configs.isEmpty) {
    SessionConfig.getDefaultConfigs().forEach(sessions.updateConfig);
  }
  appLinks.uriLinkStream.listen(handleUri);

  ThemeData themeData(Brightness brightness) => ThemeData(
    colorSchemeSeed: Colors.pink,
    appBarTheme: AppBarTheme(centerTitle: true),
    brightness: brightness,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: sessions),
      ],
      child: Consumer<SettingsProvider>(
        builder:
            (context, settings, child) => MaterialApp(
              title: "Helma's Note Trainer",
              theme: themeData(Brightness.light),
              darkTheme: themeData(Brightness.dark),
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
      ),
    ),
  );
}
