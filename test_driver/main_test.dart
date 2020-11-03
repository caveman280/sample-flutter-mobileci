// Some introductory articles about integration tests:
// http://cogitas.net/write-integration-test-flutter/
// https://medium.com/flutter-community/testing-flutter-ui-with-flutter-driver-c1583681e337
// https://stackoverflow.com/questions/52462646/how-to-solve-not-found-dartui-error-while-running-integration-tests-on-flutt
//
// Issues with opening the drawer with flutter driver
// https://github.com/flutter/flutter/issues/9002
//
// Rules:
// - Don't import any flutter code (e.g. material.dart)
// - Don't import flutter_test.dart

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:screenshots/screenshots.dart';

void main() {
  final config = Config();

  // We'll increment the screenshot count each time to get a unique filename.
  int screenshotCount = 0;

  group('end-to-end test', () {
    FlutterDriver driver;

    setUpAll(() async {
      // Connect to a running Flutter application instance.
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) driver.close();
    });

    test('tap on the floating action button; verify counter', () async {
      // Finds the floating action button (fab) to tap on
      SerializableFinder fab = find.byTooltip('Increment');

      // Wait for the floating action button to appear
      await driver.waitFor(fab);

      // Screenshot the 0
      await screenshot(driver, config, '${screenshotCount++}');

      // Tap on the fab 5 times
      for (var i = 0; i < 5; ++i) await driver.tap(fab);

      // Wait for text to change to the desired value
      await driver.waitFor(find.text('5'));

      // Screenshot the 5
      await screenshot(driver, config, '${screenshotCount++}');
    });
  });
}
