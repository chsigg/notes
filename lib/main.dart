import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/session_config_provider.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionConfigProvider = await SessionConfigProvider.create();

  runApp(
    ChangeNotifierProvider(
      create: (context) => sessionConfigProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Schedule a callback for after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SessionConfigProvider>(
        context,
        listen: false,
      ).notifyListenersAfterLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musical Note Practice',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
