#!/bin/bash

# Run flutter clean and pub get
flutter clean && flutter pub get

# Run build_runner
flutter pub run build_runner build --delete-conflicting-outputs 