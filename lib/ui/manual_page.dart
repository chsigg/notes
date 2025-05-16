import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  static TextSpan _manualEntry(
    String text, {
    String bold = '',
    double? fontSize,
  }) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold);
    return TextSpan(
      style: TextStyle(fontSize: fontSize),
      children: [TextSpan(text: bold, style: boldStyle), TextSpan(text: text)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = 20.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual'),
        centerTitle: true,
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
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: <InlineSpan>[
              _manualEntry(
                bold: '\nGetting Started',
                '\n\n',
                fontSize: titleSize,
              ),
              _manualEntry(
                bold: 'What is Helma\'s Note Trainer? ',
                'The app provides interactive exercises to help you recognize musical notes on the staff and their corresponding names. You can create custom practice sessions tailored to your specific learning needs.\n\n',
              ),
              _manualEntry(
                bold: 'Basic Navigation: ',
                'The app primarily uses a list of practice sessions as its main screen. Click on the gear icon at the top right to add/remove or edit sessions. Tap on a session in the list to start practicing.\n\n',
              ),
              _manualEntry(
                bold: '\nPractice Sessions',
                '\n\n',
                fontSize: titleSize,
              ),
              _manualEntry(
                bold: 'Understanding Session Types: ',
                'The app offers different types of practice to target specific skills:\n\n',
              ),
              _manualEntry(
                bold: '    • Names: ',
                'You are shown a musical note on the staff and must identify the corresponding name of the note.\n',
              ),
              _manualEntry(
                bold: '    • Notes: ',
                'You are shown the name of a note and must identify the corresponding musical note on the staff.\n',
              ),
              _manualEntry(
                bold: '    • Play: ',
                'You are shown the name of a note and must play the correct pitch on your instrument.\n\n',
              ),
              _manualEntry(
                bold: 'Starting a Practice Session: ',
                'Simply tap on the desired session in the main session list.\n\n',
              ),
              _manualEntry(
                bold: 'During a Practice Session: ',
                'You will be presented with a note/key prompt.\n\n',
              ),
              _manualEntry(
                bold: '    • ',
                'Respond by pressing button with the correct key or note below.\n',
              ),
              _manualEntry(
                bold: '    • ',
                'If the answer is wrong, the button will turn red. If it\'s correct, the button will turn green and shortly after a new note/key will be shown.\n',
              ),
              _manualEntry(
                bold: '    • ',
                'For play session type, play the note on your instrument. The app will detect the pitch and provide feedback whether the pitch is too low, too high, or correct.\n',
              ),
              _manualEntry(
                bold: '    • ',
                'The first note of a play session is always an A which is used to detect the tuning of you instrument.\n',
              ),
              _manualEntry(
                bold: '    • ',
                'Optionally, a timer will be shown at the top right. When it runs out, a new note/key will be shown.\n\n',
              ),
              _manualEntry(
                bold: 'Viewing Practice Stats: ',
                'On the main session list, basic statistics for each session are shown on the left.\n\n',
              ),
              _manualEntry(bold: '    • ', 'Number of practiced tests.\n'),
              _manualEntry(bold: '    • ', 'The rate of correct answers.\n'),
              _manualEntry(bold: '    • ', 'Total practice time.\n\n'),
              _manualEntry(
                bold: '\nEdit Sessions',
                '\n\n',
                fontSize: titleSize,
              ),
              _manualEntry(
                'Tap the "gear" icon in the top right to manage your sessions. Here, you can select the language for note names at the bottom. Use the green "plus" icon to add a new session, the red "trash" icon to remove one, or the "pencil" icon to edit an existing session. Press the "check" icon at the top to stop managing sessions.\n\n',
              ),
              _manualEntry(bold: 'Understanding the Session Editor', '\n\n'),
              _manualEntry(
                bold: '    • ',
                'You can choose the bold and icon for your session, change the type and add a per-question time limit.\n',
              ),
              _manualEntry(
                bold: '    • ',
                'Select the set of note names and notes on the staff that will be displayed during practice.\n',
              ),
              _manualEntry(
                bold: '    • ',
                'Tap individual notes to select or deselect them. Tap the clefs to select or deselect the entire row.\n\n',
              ),
              _manualEntry(bold: 'Sharing Sessions (via a link)', '\n\n'),
              _manualEntry(
                bold: '    • ',
                'Tap the "share" icon at the top of the session editor. A sharable link encoding the session configuration will be copied to your device\'s clipboard.\n',
              ),
              _manualEntry(
                bold: '    • ',
                'Paste this link into a message, email, or other communication method to share it with others.\n',
              ),
              _manualEntry(
                bold: '    • ',
                'Opening the link on your receiver\'s device should open the app and automatically add the session that is encoded in the link to the list.\n\n',
              ),
              if (kIsWeb) ...[
                _manualEntry(
                  bold: '\nInstallation',
                  '\n\n',
                  fontSize: titleSize,
                ),
                _manualEntry(
                  'This web site is a progressive web app (PWA) which can be downloaded to your device and used like an app. The procedure to do that depends on your device.\n\n',
                ),
                _manualEntry(bold: '    • Android: ', 'Press the '),
                WidgetSpan(child: Icon(Icons.more_vert, size: 16)),
                _manualEntry(' icon at the top right, select '),
                WidgetSpan(child: Icon(Icons.add_to_home_screen, size: 16)),
                _manualEntry(
                  ' "Add to Home screen" from the menu and press "Install" twice.\n',
                ),
                _manualEntry(bold: '    • iOS: ', 'Press the '),
                WidgetSpan(child: Icon(Icons.ios_share, size: 16)),
                _manualEntry(
                  ' button at the bottom, select "Add to Home Screen" ',
                ),
                WidgetSpan(child: Icon(Icons.add_box_outlined, size: 16)),
                _manualEntry(' from the menu and press "Add".\n'),
              ],
              _manualEntry(
                bold: '\nPrivacy Policy',
                '\n\n',
                fontSize: titleSize,
              ),
              _manualEntry(
                'The app is provided free of charge without ads and doesn\'t collect any personal information or any other data.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
