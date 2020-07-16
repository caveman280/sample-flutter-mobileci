// This line imports the extension
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:sampleflutterci/main.dart' as app;

void main() {
  // Enable integration testing with the Flutter Driver extension.
  // See https://flutter.io/testing/ for more info.
  // This line enables the extension
  enableFlutterDriverExtension();

  // remove debug banner for screenshots
  WidgetsApp.debugAllowBannerOverride = false;

  // Call the `main()` of your app or call `runApp` with whatever widget
  // you are interested in testing.
  app.main();
}