#!/usr/bin/env bash
# Gym Tracker — one-time setup for Arch/CachyOS
# Run this AFTER installing Android Studio and accepting its SDK setup wizard.
set -e

echo "=== Step 1: Install Java 17 ==="
sudo pacman -S --needed jdk17-openjdk
sudo archlinux-java set java-17-openjdk
java -version

echo ""
echo "=== Step 2: Clone Flutter SDK ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
else
  echo "Flutter already cloned, pulling latest..."
  git -C "$HOME/flutter" pull
fi

# Add to PATH for this session
export PATH="$HOME/flutter/bin:$PATH"

# Add to shell config if not already there
SHELL_RC="$HOME/.bashrc"
if [ -n "$FISH_VERSION" ] || [ "$SHELL" = "/usr/bin/fish" ]; then
  SHELL_RC="$HOME/.config/fish/config.fish"
  EXPORT_LINE="fish_add_path \$HOME/flutter/bin"
else
  EXPORT_LINE='export PATH="$HOME/flutter/bin:$PATH"'
fi

if ! grep -q "flutter/bin" "$SHELL_RC" 2>/dev/null; then
  echo "$EXPORT_LINE" >> "$SHELL_RC"
  echo "Added flutter to $SHELL_RC"
fi

echo ""
echo "=== Step 3: Accept Android licenses ==="
echo "(Requires Android Studio to have been run once and SDK downloaded)"
flutter doctor --android-licenses || true

echo ""
echo "=== Step 4: flutter doctor ==="
flutter doctor -v

echo ""
echo "=== Step 5: Install project dependencies ==="
cd "$(dirname "$0")"
flutter pub get

echo ""
echo "=== Step 6: Generate Hive TypeAdapters ==="
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "=== Step 7: Enable Flutter web ==="
flutter config --enable-web

echo ""
echo "=== All done! ==="
echo ""
echo "--- Android ---"
echo "To run on a connected device:   flutter run"
echo "To build a release APK:         flutter build apk --release"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo "Install via USB:                adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "--- Web (Chromium) ---"
echo "Run dev server:                 CHROME_EXECUTABLE=/usr/bin/chromium flutter run -d chrome"
echo "Production build:               CHROME_EXECUTABLE=/usr/bin/chromium flutter build web"
echo "Output:                         build/web/  (serve with any static file host)"
