import 'package:flutter/widgets.dart';

extension BuildContextExtension on BuildContext {
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    Element? element;
    visitAncestorElements((e) {
      element = e;
      return false;
    });
    return element?.widget as T?;
  }
}
