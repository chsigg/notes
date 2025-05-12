import 'package:flutter/material.dart';

Color getCorrectColor(BuildContext context) {
  return switch (Theme.of(context).brightness) {
    Brightness.dark => Colors.green.shade800,
    Brightness.light => Colors.green.shade400,
  };
}

Color getWrongColor(BuildContext context) {
  return switch (Theme.of(context).brightness) {
    Brightness.dark => Colors.red.shade800,
    Brightness.light => Colors.red.shade400,
  };
}

Color? getSecondaryContainerColor(BuildContext context) =>
    Theme.of(context).colorScheme.secondaryContainer;

Color getErrorColor(context) => Theme.of(context).colorScheme.error;
