import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/session_config.dart';
import '../providers/session_config_provider.dart';
import '../utils/note_mapping.dart';
import '../utils/session_icons.dart';

class SessionEditorPage extends StatefulWidget {
  final SessionConfig config;

  SessionEditorPage({super.key, SessionConfig? config})
    : config =
          config ??
          SessionConfig(
            id: const Uuid().v4(),
            title: 'New Session',
            icon: Icons.music_note,
            type: SessionType.notes,
            notes: const [],
            names: const [],
            numChoices: 3,
          ),
      super();

  @override
  State<SessionEditorPage> createState() => _SessionEditorPageState();
}

class _SessionEditorPageState extends State<SessionEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();

  late IconData _selectedIconData;
  late SessionType _selectedType;
  late int _selectedNumChoices;

  Set<String> _selectedNotes = {};
  Set<String> _selectedNames = {};

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.config.title;
    final timeLimit = widget.config.timeLimitSeconds;
    _timeLimitController.text = timeLimit <= 0 ? '' : timeLimit.toString();
    _selectedType = widget.config.type;
    _selectedIconData = widget.config.icon;
    _selectedNumChoices = widget.config.numChoices;
    _selectedNotes = Set.from(widget.config.notes);
    _selectedNames = Set.from(widget.config.names);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      final savedConfig = SessionConfig(
        id: widget.config.id,
        title: _titleController.text.trim(),
        icon: _selectedIconData,
        type: _selectedType,
        notes: _selectedNotes.toList(),
        names: _selectedNames.toList(),
        numChoices: _selectedNumChoices,
        timeLimitSeconds: int.tryParse(_timeLimitController.text) ?? 0,
        practicedTests: widget.config.practicedTests,
        successfulTests: widget.config.successfulTests,
      );
      final sessionProvider = Provider.of<SessionConfigProvider>(
        context,
        listen: false,
      );
      sessionProvider.updateConfig(savedConfig);
      Navigator.pop(context);
    }
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
    final List<Widget> iconWidgets =
        SessionIcons.all_icons.map((iconData) {
          return InkWell(
            onTap: () {
              Navigator.of(context).pop(iconData);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(iconData, size: 48),
            ),
          );
        }).toList();

    return AlertDialog(
      title: const Text('Select Icon'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Wrap(children: iconWidgets),
      ),
      actions: <Widget>[
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
    final color = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () => setState(() => onTap()),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(77) : null,
        ),
        child: OverflowBox(
          maxWidth: double.infinity,
          child: Center(child: Text(text, style: style)),
        ),
      ),
    );
  }

  Widget _buildSelectionGridForNames() {
    final allNames = NoteMapping.getAllNames();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 72,
      ),
      itemCount: allNames.length,
      itemBuilder: (context, index) {
        final item = allNames[index];
        final style = const TextStyle(fontSize: 32);
        final isSelected = _selectedNames.contains(item);
        return _buildItem(item, style, () {
          if (isSelected) {
            _selectedNames.remove(item);
          } else {
            _selectedNames.add(item);
          }
        }, isSelected);
      },
    );
  }

  Widget _buildSelectionGridForNotes() {
    final allNotes = NoteMapping.getAllNotes();
    allNotes.insert(83, ''); // Highest note has no sharp, insert dummy node.
    final style = const TextStyle(fontSize: 24, fontFamily: 'StaffClefPitches');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisExtent: 108,
      ),
      itemCount: allNotes.length + allNotes.length ~/ 7 + 1,
      itemBuilder: (context, index) {
        // First column shows the clef of that row,
        // the others show the notes without clef.
        final row = index ~/ 8;
        if (row * 8 == index) {
          final rowElements = allNotes
              .sublist(index - row)
              .take(row % 12 == 11 ? 6 : 7);
          final item = rowElements.first;
          final text = '    ' + NoteMapping.getNoteStaff(item)[0] + '+';
          final isSelected = _selectedNotes.containsAll(rowElements);
          return _buildItem(text, style, () {
            if (isSelected) {
              _selectedNotes.removeAll(rowElements);
            } else {
              _selectedNotes.addAll(rowElements);
            }
          }, isSelected);
        }

        final item = allNotes[index - row - 1];
        if (item.isEmpty) {
          return const SizedBox();
        }
        final text = '+' + NoteMapping.getNoteStaff(item)[2] + '+';
        final isSelected = _selectedNotes.contains(item);
        return _buildItem(text, style, () {
          if (isSelected) {
            _selectedNotes.remove(item);
          } else {
            _selectedNotes.add(item);
          }
        }, isSelected);
      },
    );
  }

  Widget _buildNonEmptyValidator(Set<String> selected) {
    return FormField<void>(
      validator: (value) {
        return selected.isEmpty ? 'Please select some elements' : null;
      },
      builder: (state) {
        if (state.hasError) {
          return Text(
            state.errorText!,
            style: TextStyle(color: Colors.red[900]),
          );
        }
        return SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Session'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Session',
            onPressed: _saveSession,
          ),
        ],
      ),
      body: Center(
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
                    title: Text('Difficulty'),
                    trailing: SegmentedButton<int>(
                      segments: [
                        ButtonSegment<int>(value: 1, label: Text('1')),
                        ButtonSegment<int>(value: 2, label: Text('2')),
                        ButtonSegment<int>(value: 3, label: Text('3')),
                        ButtonSegment<int>(value: 4, label: Text('4')),
                        ButtonSegment<int>(value: 5, label: Text('5')),
                      ],
                      selected: {_selectedNumChoices},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedNumChoices = selection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  ListTile(
                    title: Text('Time Limit'),
                    trailing: IntrinsicWidth(
                      child: TextFormField(
                        controller: _timeLimitController,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Set Time Limit',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final timeLimit = int.tryParse(value);
                          if (timeLimit == null || timeLimit < 0) {
                            return 'Please enter a valid time limit';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ListTile(
                    title: Text('Answer Type'),
                    trailing: SegmentedButton<SessionType>(
                      segments: [
                        ButtonSegment<SessionType>(
                          value: SessionType.notes,
                          label: Text('Notes'),
                        ),
                        ButtonSegment<SessionType>(
                          value: SessionType.names,
                          label: Text('Names'),
                        ),
                        ButtonSegment<SessionType>(
                          value: SessionType.play,
                          label: Text('Play'),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedType = selection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildNonEmptyValidator(_selectedNames),
                  const SizedBox(height: 16),

                  _buildSelectionGridForNames(),
                  const SizedBox(height: 32),

                  if (_selectedType != SessionType.play) ...[
                    _buildNonEmptyValidator(_selectedNotes),
                    const SizedBox(height: 16),

                    _buildSelectionGridForNotes(),
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
