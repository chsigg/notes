import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  static TextSpan _regular(String text, {double? fontSize}) {
    final style = TextStyle(fontSize: fontSize);
    return TextSpan(text: text, style: style);
  }

  static TextSpan _bold(String text, {double? fontSize}) {
    final style = TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold);
    return TextSpan(text: text, style: style);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final textSize = textStyle?.fontSize ?? 20.0;
    final titleSize = textSize * 1.4;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Show Licenses',
            onPressed: () => showLicensePage(context: context),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: IconTheme(
          data: IconThemeData(
            size: textSize,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          child: RichText(
            text: TextSpan(
              style: textStyle,
              children: <InlineSpan>[
                _bold('\nGetting Started\n\n', fontSize: titleSize),
                _bold('What is Helma\'s Note Trainer? '),
                _regular(
                  'The app provides interactive exercises to help you recognize musical notes on the staff and their corresponding names. You can create custom practice sessions tailored to your specific learning needs.\n\n',
                ),
                _bold('Basic Navigation: '),
                _regular(
                  'The app primarily uses a list of practice sessions as its main screen. Click on the gear icon at the top right to add/remove or edit sessions. Tap on a session in the list to start practicing.\n\n',
                ),
                _bold('\nPractice Sessions\n\n', fontSize: titleSize),
                _regular(
                  'To start practicing, simply tap on the desired session in the session list. The app offers different types of practice to target specific skills.\n\n',
                ),
                _bold('Notes and Names: '),
                _regular(
                  'You are shown a musical note on the staff and must identify the corresponding name of the note, or the other way around. If you pressed the correct button, it will turn green and the next question will be shown. If you pressed the wrong button, it will turn red.\n\n',
                ),
                _bold('Play: '),
                _regular(
                  'You are shown the name of a note and must play the correct pitch on your instrument. The app uses your device\'s microphone to check if you played within a quarter note of the requested pitch class. That is, you can play at any octave.\nMany instruments are tuned to 440Hz, but note detection works better if the system is calibrated to your instrument. That\'s why the first note of a session is always an A, has a larger tolerance and displays the detected tuning. If you don\'t get this first A quite right, please restart the session.\n\nSessions can have a timer in the top right corner. When the timer expires, the app automatically moves to the next question.\n\nThe app tracks the number of questions you answer, your accuracy, and your total practice time. These statistics appear next to each session in the main list.\n\n',
                ),
                _bold('\nEdit Sessions\n\n', fontSize: titleSize),
                _regular(
                  'Tap the "gear" icon in the top right to manage your sessions. Here, you can select the language for note names at the bottom. Use the green "plus" icon to add a new session, the red "trash" icon to remove one, or the "pencil" icon to edit an existing session. Press the "check" icon at the top to stop managing sessions.\n\n',
                ),
                _bold('Understanding the Session Editor\n\n'),
                _regular(
                  'You can choose the name and icon for your session, change the type and add a timer limit for each question.\n\nSelect the set of note names and notes on the staff that will be displayed during practice.\nTap individual notes to select or deselect them. Tap the clefs to select or deselect the entire row.\n\n',
                ),
                _bold('Sharing Sessions (via a link)\n\n'),
                _regular(
                  'Tap the "share" icon at the top of the session editor. A sharable link encoding the session configuration will be copied to your device\'s clipboard.\nPaste this link into a message, email, or other communication method to share it with others.\nOpening the link on your receiver\'s device should open the app and automatically add the session that is encoded in the link to the list.\n\n',
                ),
                if (kIsWeb) ...[
                  _bold('\nInstallation\n\n', fontSize: titleSize),
                  _regular(
                    'This web site is a progressive web app (PWA) which can be downloaded to your device and used like an app. The procedure to do that depends on your device.\n\n',
                  ),
                  _bold('Android: '),
                  _regular('Press the menu '),
                  WidgetSpan(child: Icon(Icons.more_vert)),
                  _regular(' icon at the top right, select "'),
                  WidgetSpan(child: Icon(Icons.add_to_home_screen)),
                  _regular(
                    ' Add to Home screen" from the menu and press "Install" twice.\n\n',
                  ),
                  _bold('iOS: '),
                  _regular('Press the '),
                  WidgetSpan(child: Icon(Icons.ios_share)),
                  _regular(
                    ' button at the bottom, select "Add to Home Screen ',
                  ),
                  WidgetSpan(child: Icon(Icons.add_box_outlined)),
                  _regular('" from the menu and press "Add".\n'),
                ],
                _bold('\nPrivacy Policy\n\n', fontSize: titleSize),
                _regular(
                  'The app is provided free of charge without ads and doesn\'t collect any personal information or any other data.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
