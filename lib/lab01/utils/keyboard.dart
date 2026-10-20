import 'package:flutter/widgets.dart';

/// Used as `onTapOutside` of every text field.
void dismissKeyboard(PointerDownEvent event) =>
    FocusManager.instance.primaryFocus?.unfocus();
