#!/bin/bash

# Flutter install
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Precache for web
flutter precache --web

# Get packages
flutter pub get

# Build web
flutter build web
