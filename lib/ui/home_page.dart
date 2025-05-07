import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_config.dart';
import '../providers/sessions_provider.dart';
import '../providers/settings_provider.dart';

import 'practice_notes_page.dart';
import 'practice_keys_page.dart';
import 'practice_play_page.dart';
import 'session_editor_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    SessionConfig config,
  ) async {
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<SessionsProvider, SettingsProvider>(
      builder: (context, sessions, settings, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(settings.isEditMode ? Icons.check : Icons.settings),
                tooltip:
                    settings.isEditMode ? 'Done Editing' : 'Manage Sessions',
                onPressed: () => settings.isEditMode = !settings.isEditMode,
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
              constraints: const BoxConstraints(maxWidth: 600.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    sessions.configs.length + (settings.isEditMode ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == sessions.configs.length) {
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity(vertical: 4),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () => _editSession(context, null),
                              tooltip: 'Add New Session',
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final config = sessions.configs[index];
                  final successRate =
                      config.practicedTests > 0
                          ? (config.successfulTests /
                              config.practicedTests *
                              100.0)
                          : 100.0;

                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity(vertical: 4),
                    leading: Icon(config.icon, size: 32),
                    title: Text(config.title),
                    subtitle: Text(
                      'Practiced ${config.practicedTests} times, ${successRate.toStringAsFixed(1)}% correct',
                    ),
                    onTap: () => _practiceSession(context, config),
                    trailing:
                        settings.isEditMode
                            ? SizedBox(
                              width: 100,
                              child: Row(
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
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete Session',
                                    onPressed:
                                        () => _confirmDelete(context, config),
                                  ),
                                ],
                              ),
                            )
                            : null,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
