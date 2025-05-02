import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_config.dart';
import '../providers/session_config_provider.dart';
import 'practice_names_page.dart';
import 'practice_notes_page.dart';
import 'practice_play_page.dart';
import 'session_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEditMode = false;
  static const _isEditModePrefKey = 'is_edit_mode';

  @override
  void initState() {
    super.initState();
    _loadEditModePreference();
  }

  Future<void> _loadEditModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loadedValue = prefs.getBool(_isEditModePrefKey);
      if (loadedValue != null && loadedValue != _isEditMode) {
        setState(() {
          _isEditMode = loadedValue;
        });
      }
    } catch (e) {
      // Ignore errors loading the preference.
    }
  }

  Future<void> _saveEditModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isEditModePrefKey, _isEditMode);
    } catch (e) {
      // Ignore errors saving the preference.
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SessionConfig config,
  ) async {
    final provider = Provider.of<SessionConfigProvider>(context, listen: false);

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
      provider.deleteConfig(config.id);
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
              SessionType.notes => PracticeNotesPage(config: config),
              SessionType.names => PracticeNamesPage(config: config),
              SessionType.play => PracticePlayPage(config: config),
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionConfigProvider>();
    final configs = sessionProvider.configs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Musical Note Practice'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.settings),
            tooltip: _isEditMode ? 'Done Editing' : 'Manage Sessions',
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
              _saveEditModePreference();
            },
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
            itemCount: configs.length + (_isEditMode ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == configs.length) {
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

              final config = configs[index];
              final successRate =
                  config.practicedTests > 0
                      ? (config.successfulTests / config.practicedTests * 100.0)
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
                    _isEditMode
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
  }
}
