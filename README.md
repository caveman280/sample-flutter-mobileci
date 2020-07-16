![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/caveman280/sample-flutter-mobileci?include_prereleases&style=for-the-badge) [![Build Status](https://img.shields.io/travis/caveman280/sample-flutter-mobileci/master?style=for-the-badge&label=Build:+master)](https://travis-ci.org/caveman280/sample-flutter-mobileci) [![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?style=for-the-badge&logo=gitpod)](https://gitpod.io/#https://github.com/caveman280/sample-flutter-mobileci)

# Sample Flutter project with a mobileCI Twist!

Here lies a the sample Flutter application ready for CI with AppVeyor

We build this with AppVeyor with the following logic:

- On merge to master with "RELEASE", run the e2e test on iOS and Android
- Taking screenshots with Flutter Driver, commiting the results directly to master
- Then, update README.md and CHANGELOG.md - with the new screenshots - and create a tag.
- Finally, trigger the builds for the IPA and APK bundles and upload to the release

Unless, it's a \[chore] PR.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
