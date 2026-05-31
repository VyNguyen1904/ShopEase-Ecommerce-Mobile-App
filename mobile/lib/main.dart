import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runApp(
    // ProviderScope is the root widget required by flutter_riverpod.
    // It makes all providers accessible throughout the widget tree.
    const ProviderScope(child: ShopEaseApp()),
  );
}
