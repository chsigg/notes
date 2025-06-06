import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/providers/settings_provider.dart';
import 'package:provider/provider.dart';

import '../models/session_config.dart';
import '../providers/sessions_provider.dart';
import '../utils/colors.dart';
import '../utils/note_mapping.dart';
import '../utils/session_icons.dart';

class SessionEditorPage extends StatefulWidget {
  final SessionConfig config;

  SessionEditorPage({super.key, SessionConfig? config})
    : config =
          config ??
          SessionConfig(
            title: 'New Session',
            icon: Icons.music_note,
            type: SessionType.notes,
            keys: const [],
            notes: const [],
          ),
      super();

  @override
  State<SessionEditorPage> createState() => _SessionEditorPageState();
}

class _SessionEditorPageState extends State<SessionEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final _numQuestionsController = TextEditingController();

  late IconData _selectedIconData;
  late SessionType _selectedType;

  Set<NoteKey> _selectedKeys = {};
  Set<Note> _selectedNotes = {};

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.config.title;
    final timeLimit = widget.config.timeLimitSeconds;
    _timeLimitController.text = timeLimit <= 0 ? '' : timeLimit.toString();
    final numQuestions = widget.config.numQuestionsPerRound;
    _numQuestionsController.text =
        numQuestions <= 0 ? '' : numQuestions.toString();
    _selectedType = widget.config.type;
    _selectedIconData = widget.config.icon;
    _selectedKeys = Set.from(widget.config.keys);
    _selectedNotes = Set.from(widget.config.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    _numQuestionsController.dispose();
    super.dispose();
  }

  SessionConfig? _getSession() {
    if (!_formKey.currentState!.validate()) {
      return null;
    }
    return SessionConfig(
      id: widget.config.id,
      title: _titleController.text.trim(),
      icon: _selectedIconData,
      type: _selectedType,
      keys: [..._selectedKeys],
      notes: [..._selectedNotes],
      timeLimitSeconds: int.tryParse(_timeLimitController.text) ?? 0,
      numQuestionsPerRound: int.tryParse(_numQuestionsController.text) ?? 0,
    );
  }

  void _saveSession() {
    final config = _getSession();
    if (config == null) return;
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    sessions.updateConfig(config);
    Navigator.pop(context);
  }

  void _shareSession() {
    final config = _getSession();
    if (config == null) return;
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    final uri = Uri.parse('https://csigg.com/notes').replace(
      queryParameters: {
        'session': config.toBase64(),
        if (lang != null) 'lang': lang,
      },
    );
    final messenger = ScaffoldMessenger.of(context);
    Clipboard.setData(ClipboardData(text: uri.toString())).then((_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Session link copied to clipboard!')),
      );
    });
  }

  void _pickIcon() async {
    final pickedIcon = await showDialog<IconData>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _buildIconPickerDialog(dialogContext, _selectedIconData);
      },
    );

    if (pickedIcon != null) {
      setState(() => _selectedIconData = pickedIcon);
    }
  }

  Widget _buildIconPickerDialog(BuildContext context, IconData currentIcon) {
    final iconWidgets = [
      ...SessionIcons.allIcons.map((iconData) {
        return InkWell(
          onTap: () {
            Navigator.of(context).pop(iconData);
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(iconData, size: 48),
          ),
        );
      }),
    ];

    return AlertDialog(
      title: const SizedBox(height: 16),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Wrap(children: iconWidgets),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ],
    );
  }

  Widget _buildItem(
    String text,
    TextStyle style,
    Function onTap,
    bool isSelected,
  ) {
    final color = getSecondaryContainerColor(context);
    return InkWell(
      onTap: () => setState(() => onTap()),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(color: isSelected ? color : null),
        child: OverflowBox(
          maxWidth: double.infinity,
          child: Center(child: Text(text, style: style)),
        ),
      ),
    );
  }

  Widget _buildSelectionGridForNotes() {
    final allNotes = getAllNotes();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 72,
      ),
      itemCount: allNotes.length,
      itemBuilder: (context, index) {
        final note = allNotes[index];
        final style = const TextStyle(fontSize: 24);
        final isSelected = _selectedNotes.contains(note);
        return _buildItem(
          Localizations.of(context, NoteLocalizations).name(note),
          style,
          () {
            if (isSelected) {
              _selectedNotes.remove(note);
            } else {
              _selectedNotes.add(note);
            }
          },
          isSelected,
        );
      },
    );
  }

  Widget _buildSelectionGridForKeys() {
    final allKeys = <NoteKey?>[...getAllKeys()];
    allKeys.insert(83, null); // Highest note has no sharp, insert dummy node.
    final style = const TextStyle(fontSize: 24, fontFamily: 'StaffClefPitches');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisExtent: 108,
      ),
      itemCount: allKeys.length + allKeys.length ~/ 7 + 1,
      itemBuilder: (context, index) {
        // First column shows the clef of that row,
        // the others show the notes without clef.
        final row = index ~/ 8;
        if (row * 8 == index) {
          final rowElements = allKeys
              .sublist(index - row)
              .take(row % 12 == 11 ? 6 : 7)
              .map((item) => item!);
          final item = rowElements.first;
          final text = '    ${getGlyphsFromKey(item)[0]}+';
          final isSelected = _selectedKeys.containsAll(rowElements);
          return _buildItem(text, style, () {
            if (isSelected) {
              _selectedKeys.removeAll(rowElements);
            } else {
              _selectedKeys.addAll(rowElements);
            }
          }, isSelected);
        }

        final item = allKeys[index - row - 1];
        if (item == null) {
          return const SizedBox();
        }
        final text = '+${getGlyphsFromKey(item)[2]}+';
        final isSelected = _selectedKeys.contains(item);
        return _buildItem(text, style, () {
          if (isSelected) {
            _selectedKeys.remove(item);
          } else {
            _selectedKeys.add(item);
          }
        }, isSelected);
      },
    );
  }

  Widget _buildNonEmptyValidator(Set<dynamic> selected) {
    return FormField<void>(
      validator: (value) {
        return selected.isEmpty ? 'Please select some elements' : null;
      },
      builder: (state) {
        if (state.hasError) {
          return Text(
            state.errorText!,
            style: TextStyle(color: getErrorColor(context)),
          );
        }
        return SizedBox();
      },
    );
  }

  static String? _validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final timeLimit = int.tryParse(value);
    if (timeLimit == null || timeLimit < 0) {
      return 'Please enter a positive number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Session',
            onPressed: _shareSession,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Session',
            onPressed: _saveSession,
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity(vertical: 4),
                    leading: IconButton(
                      icon: Icon(_selectedIconData),
                      iconSize: 32,
                      tooltip: 'Change Icon',
                      onPressed: _pickIcon,
                    ),
                    title: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Change Session Title',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  ListTile(
                    title: Text('Practice Type:'),
                    trailing: SegmentedButton<SessionType>(
                      segments: [
                        ButtonSegment<SessionType>(
                          value: SessionType.notes,
                          label: Text('C'),
                          tooltip: 'Pick the correct name',
                        ),
                        ButtonSegment<SessionType>(
                          value: SessionType.keys,
                          label: Icon(Icons.music_note),
                          tooltip: 'Pick the correct note',
                        ),
                        ButtonSegment<SessionType>(
                          value: SessionType.play,
                          label: Icon(Icons.mic),
                          tooltip: 'Play the correct pitch',
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedType = selection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    title: Text('Time Limit:'),
                    trailing: IntrinsicWidth(
                      child: TextFormField(
                        controller: _timeLimitController,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Set Time Limit',
                          suffixText: 'sec',
                        ),
                        validator: _validatePositiveNumber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    title: Text('Round Length:'),
                    trailing: IntrinsicWidth(
                      child: TextFormField(
                        controller: _numQuestionsController,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Tests Per Round',
                        ),
                        validator: _validatePositiveNumber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildNonEmptyValidator(_selectedNotes),
                  const SizedBox(height: 16),

                  _buildSelectionGridForNotes(),
                  const SizedBox(height: 32),

                  if (_selectedType != SessionType.play) ...[
                    _buildNonEmptyValidator(_selectedKeys),
                    const SizedBox(height: 16),

                    _buildSelectionGridForKeys(),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
