import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_config.dart';
import '../providers/sessions_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/note_mapping.dart';

import 'practice_keys_page.dart';
import 'practice_notes_page.dart';
import 'practice_play_page.dart';
import 'session_editor_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _confirmDelete(BuildContext context, SessionConfig config) async {
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete session "${config.title}"?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      sessions.deleteConfig(config.id);
    }
  }

  void _editSession(BuildContext context, SessionConfig? config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionEditorPage(config: config),
      ),
    );
  }

  void _practiceSession(BuildContext context, SessionConfig config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => switch (config.type) {
              SessionType.keys => PracticeKeysPage(config: config),
              SessionType.notes => PracticeNotesPage(config: config),
              SessionType.play => PracticePlayPage(config: config),
            },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    List<SessionConfig> configs,
    bool isEditMode,
  ) {
    const double leadingWidth = 64;

    if (index == configs.length) {
      return ListTile(
        trailing: IconButton(
          icon: const Icon(Icons.add, color: Colors.green),
          onPressed: () => _editSession(context, null),
          tooltip: 'Add New Session',
        ),
      );
    }

    final config = configs[index];
    var successCountString = '';
    if (config.practicedTests > 0) {
      final successPercent =
          config.successfulTests / config.practicedTests * 100;
      successCountString =
          '${config.successfulTests}\n${successPercent.toStringAsFixed(0)}%';
    }

    final editButtons = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit Session',
          onPressed: () {
            _editSession(context, config);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Delete Session',
          onPressed: () => _confirmDelete(context, config),
        ),
      ],
    );

    return ListTile(
      dense: true,
      visualDensity: VisualDensity(vertical: 4),
      leading: SizedBox(
        width: leadingWidth,
        child: Text(successCountString, textAlign: TextAlign.center),
      ),
      title: Row(
        children: [
          Icon(config.icon, size: 32),
          SizedBox(width: 16),
          Text(config.title),
        ],
      ),
      onTap: () => _practiceSession(context, config),
      trailing: isEditMode ? editButtons : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 100;
    return Consumer2<SessionsProvider, SettingsProvider>(
      builder: (context, sessions, settings, child) {
        final isEditMode = settings.isEditMode;
        final appLanguage = Localizations.localeOf(context).languageCode;
        return Scaffold(
          appBar: AppBar(
            leading: Text('♯♭', style: TextStyle(fontSize: 0)),
            toolbarHeight: iconSize,
            bottom: PreferredSize(
              preferredSize: Size.square(iconSize),
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Container(
                  height: iconSize,
                  width: iconSize,
                  decoration: BoxDecoration(
                    color: (ColorScheme scheme) {
                      return switch (scheme.brightness) {
                        Brightness.dark => scheme.onSurface,
                        Brightness.light => scheme.surface,
                      };
                    }(Theme.of(context).colorScheme),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(iconSize * 0.07),
                    child: Image(image: AssetImage('assets/icons/icon.png')),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isEditMode ? Icons.check : Icons.settings),
                tooltip: isEditMode ? 'Done Editing' : 'Manage Sessions',
                onPressed: () => settings.isEditMode = !isEditMode,
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Show Licenses',
                onPressed: () {
                  showLicensePage(context: context);
                },
              ),
              SizedBox(width: 16),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            sessions.configs.length + (isEditMode ? 1 : 0),
                        itemBuilder: (context, index) {
                          return _buildItem(
                            context,
                            index,
                            sessions.configs,
                            isEditMode,
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        isEditMode
                            ? SegmentedButton<String>(
                              segments: [
                                ...NoteLocalizations.supportedLanguages.map(
                                  (language) => ButtonSegment<String>(
                                    value: language,
                                    label: Text(language),
                                  ),
                                ),
                              ],
                              emptySelectionAllowed: true,
                              showSelectedIcon: settings.language != null,
                              selected: {settings.language ?? appLanguage},
                              onSelectionChanged: (selection) {
                                settings.language =
                                    selection.isNotEmpty
                                        ? selection.first
                                        : settings.language == null
                                        ? appLanguage
                                        : null;
                              },
                            )
                            : SizedBox(height: 80),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
