# Module 1: Introduction to Flutter — Sessions 1–5

> **Course:** Cross-Platform Mobile Development with Flutter & Dart  
> **Module:** M1 — Flutter Overview & Environment Setup  
> **Sessions:** 1 through 5  
> **Prerequisites:** Basic programming knowledge (any language), comfort with the command line  
> **Author:** Flutter Course Team  
> **Last Updated:** May 2026

---

## 📋 Table of Contents

1. [Session 1 — Flutter Overview & Environment Setup](#session-1--flutter-overview--environment-setup)
2. [Session 2 — Project Structure & Tooling](#session-2--project-structure--tooling)
3. [Session 3 — Hot Reload / Restart & Widget Tree](#session-3--hot-reload--restart--widget-tree)
4. [Session 4 — Basic UI Composition with Scaffold](#session-4--basic-ui-composition-with-scaffold)
5. [Session 5 — Summary & Common Pitfalls](#session-5--summary--common-pitfalls)
6. [Module Summary](#module-summary)
7. [Review Questions](#review-questions)

---

# Session 1 – Flutter Overview & Environment Setup

## 1.1 What is Flutter?

Welcome to one of the most exciting frameworks in modern mobile development. Flutter is an **open-source UI toolkit** created by Google that lets you build natively compiled applications for **mobile (iOS & Android)**, **web**, **desktop (Windows, macOS, Linux)**, and even **embedded devices** — all from a **single codebase** written in the **Dart** programming language.

Let that sink in. You write your code once and deploy everywhere. Not a web wrapper, not a JavaScript bridge — genuine native performance with pixel-perfect UI control.

### 1.1.1 A Brief History of Flutter

Understanding where Flutter came from helps you appreciate what problems it solves.

| Year | Milestone |
|------|-----------|
| 2015 | Google engineers start "Sky" — a proof of concept for a high-performance mobile UI framework |
| 2017 | Flutter Alpha released at Google I/O |
| 2018 | Flutter 1.0 (stable) released at Flutter Live |
| 2019 | Flutter 1.12 adds web support (beta) |
| 2020 | Flutter 1.22 adds stable iOS & Android support, web still beta |
| 2021 | **Flutter 2.0** — multi-platform stable release (mobile + web + desktop beta) |
| 2022 | Flutter 3.0 — full stable support for all 6 platforms |
| 2023 | Flutter 3.x — Impeller rendering engine replaces Skia on iOS |
| 2024 | Flutter 3.19+ — Impeller on Android (opt-in), improved Dart 3 features |
| 2025+ | Continued performance improvements, AI tooling integration |

### 1.1.2 Why Does Flutter Exist?

Before Flutter, building for both iOS and Android meant:

- **Native Development:** Two separate codebases (Swift/Obj-C for iOS, Kotlin/Java for Android), two separate teams, double the maintenance.
- **JavaScript Bridges (React Native, Ionic):** A JavaScript thread communicates with native components over a "bridge." This bridge introduces latency, jank, and unpredictable behavior.
- **WebViews (Cordova, PhoneGap):** Wrapped web apps that feel slow and don't look native.

Flutter took a radically different approach: **bring your own rendering engine**. Flutter doesn't rely on native UI widgets at all. It draws every pixel itself using a graphics engine (first Skia, now Impeller), giving you complete control and consistent behavior across platforms.

### 1.1.3 Flutter vs. The Competition

Let's do an honest, professor-level comparison:

| Feature | Flutter | React Native | Xamarin | Native (iOS/Android) |
|---------|---------|--------------|---------|----------------------|
| **Language** | Dart | JavaScript/TypeScript | C# | Swift/Kotlin |
| **Rendering** | Own engine (Skia/Impeller) | Native components via bridge | Native components via wrapper | Native components |
| **Performance** | ⭐⭐⭐⭐⭐ Near-native | ⭐⭐⭐ Good (bridge overhead) | ⭐⭐⭐⭐ Good | ⭐⭐⭐⭐⭐ Best |
| **UI Consistency** | ⭐⭐⭐⭐⭐ Pixel-perfect | ⭐⭐⭐ Platform-dependent | ⭐⭐⭐ Platform-dependent | ⭐⭐⭐ Platform-specific |
| **Code Reuse** | ~95%+ | ~70–80% | ~70–80% | 0% (two codebases) |
| **Hot Reload** | ✅ Yes (sub-second) | ✅ Yes | ⚠️ Limited | ❌ No |
| **Ecosystem** | Growing rapidly | Very mature | Mature (Microsoft) | Most mature |
| **Learning Curve** | Dart (easy), Widgets | JS (familiar), JSX | C# (familiar) | Swift/Kotlin |
| **Community** | Large & growing | Very large | Medium | Huge |
| **Company Support** | Google | Meta (Facebook) | Microsoft | Apple / Google |

> **💡 Pro Tip:** React Native's new architecture (JSI + Fabric) significantly reduced bridge overhead, making it a much stronger competitor. But Flutter's rendering independence still gives it unique advantages for highly custom UIs and animations.

**When to choose Flutter:**
- You need pixel-perfect custom UI
- Performance is critical (animations, games, real-time data)
- You want one team and one codebase for all platforms
- Your team is open to learning Dart

**When to consider React Native:**
- Your team is already JavaScript-heavy
- You need very deep access to platform-specific native APIs
- Your app heavily relies on standard platform UI (native pickers, etc.)

---

## 1.2 Flutter Architecture: Under the Hood

This is where Flutter gets genuinely interesting. Understanding the architecture separates good Flutter developers from great ones.

### 1.2.1 The Three Layers of Flutter

Flutter's architecture is divided into three major layers:

```
┌─────────────────────────────────────────────────────────┐
│                   YOUR FLUTTER APP                       │
│          (Dart code: widgets, business logic)            │
├─────────────────────────────────────────────────────────┤
│                  FLUTTER FRAMEWORK                       │
│  Material / Cupertino / Widgets / Rendering / Animation  │
│              Painting / Gestures / Foundation            │
├─────────────────────────────────────────────────────────┤
│                   FLUTTER ENGINE                         │
│         Skia / Impeller (C++) — draws pixels             │
│         Dart Runtime — executes your Dart code           │
│         Platform Channels — talk to OS APIs              │
├─────────────────────────────────────────────────────────┤
│              PLATFORM EMBEDDER (OS-specific)             │
│    iOS App   │  Android App  │  Windows  │  macOS/Linux  │
└─────────────────────────────────────────────────────────┘
```

**Layer 1: Platform Embedder**  
Each platform has a thin embedder written in the platform's native language (Swift for iOS, Java/Kotlin for Android, C++ for desktop). Its only job is to set up a surface (a canvas) for the Flutter engine to draw on, forward input events (touch, keyboard), and provide access to platform services.

**Layer 2: Flutter Engine**  
Written in C++, this is the heart of Flutter. It contains:
- **Skia/Impeller** — the 2D graphics library that draws everything
- **Dart Runtime** — compiles and executes your Dart code
- **Text layout** — handles fonts, bidi text, emoji
- **Platform Channels** — the bridge to native code when needed

**Layer 3: Flutter Framework**  
Written entirely in Dart. This is where you spend most of your time. It includes:
- `foundation` — core utilities, change notification
- `animation` — animation controllers, tweens, curves
- `painting` — borders, gradients, text painting
- `gestures` — touch recognition
- `rendering` — the render tree (layout + painting)
- `widgets` — the widget tree (core building blocks)
- `material` and `cupertino` — platform-specific design systems

### 1.2.2 The Skia & Impeller Rendering Engines

**Skia** was Flutter's original graphics engine — the same engine that powers Chrome and Android. It's mature and battle-tested, but it has a significant flaw: it compiles shaders (tiny graphics programs) **at runtime**, causing first-run jank (visible stutters).

**Impeller** is Flutter's new rendering engine, designed from the ground up to solve the shader compilation problem. Impeller pre-compiles all shaders at build time, resulting in smooth 60/120fps animations with zero jank. As of Flutter 3.x:
- iOS: Impeller is **on by default**
- Android: Impeller is available as opt-in (stabilizing rapidly)

### 1.2.3 The Three Trees: Widget, Element, and Render

This is one of the most important concepts in Flutter. Pay close attention.

Flutter maintains **three parallel trees** at runtime:

```
Widget Tree         Element Tree        Render Tree
(Configuration)     (Lifecycle)         (Layout & Paint)

  Column              Column              RenderFlex
    │                   │                    │
  Text "Hi"           Text "Hi"           RenderParagraph
    │                   │                    │
  Icon(star)          Icon(star)          RenderCustomPaint
```

**Widget Tree — "What do I want?"**
- Widgets are **immutable configuration objects**
- They describe what the UI should look like
- Created and destroyed constantly (they are cheap, like blueprints)
- When `setState()` is called, Flutter rebuilds widgets

**Element Tree — "What do I have?"**
- Elements are the **live instances** that bridge widgets and render objects
- They persist across widget rebuilds (they are the stable backbone)
- Each element holds a reference to its current widget configuration
- Elements track lifecycle: mounted, active, unmounted

**Render Tree — "Where do I go and how do I look?"**
- Render objects perform actual **layout and painting**
- They are expensive to create — Flutter tries to reuse them
- They know their size, position, and how to paint themselves
- This is what Skia/Impeller actually draws

> **💡 Pro Tip:** When you call `setState()`, Flutter rebuilds the **widget** subtree cheaply (widgets are just immutable data classes). It then **reconciles** those new widgets with the existing element tree, updating only what changed in the render tree. This diff-and-patch process is why Flutter is fast despite seemingly "rebuilding everything."

---

## 1.3 Installing Flutter SDK

Let's get your hands dirty. We'll walk through installation on all three major platforms.

### 1.3.1 Windows Installation

**System Requirements:**
- Windows 10 or later (64-bit)
- 1.64 GB disk space (excluding IDE/tools)
- Git for Windows
- PowerShell 5.0 or newer

**Step 1: Download the Flutter SDK**

```bash
# Option A: Using Git (recommended — allows easy updates)
git clone https://github.com/flutter/flutter.git -b stable C:\flutter

# Option B: Download the ZIP from https://flutter.dev/docs/get-started/install/windows
# and extract to C:\flutter (avoid paths with spaces or special characters!)
```

**Step 2: Add Flutter to your PATH**

Open PowerShell as Administrator:

```powershell
# Add Flutter to the current session
$env:Path += ";C:\flutter\bin"

# To make it permanent, add to System Environment Variables:
[System.Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path + ";C:\flutter\bin",
    [System.EnvironmentVariableTarget]::Machine
)
```

Or manually:
1. Press `Win + X` → System → Advanced System Settings
2. Click "Environment Variables"
3. Under "System Variables", find `Path`, click Edit
4. Click "New" and add `C:\flutter\bin`
5. Click OK on all dialogs

**Step 3: Install Git for Windows**

```bash
# Download from https://git-scm.com/download/win
# Or using winget:
winget install Git.Git
```

**Step 4: Verify Installation**

```bash
flutter --version
# Expected output:
# Flutter 3.x.x • channel stable • https://github.com/flutter/flutter.git
# Framework • revision xxxxxx • ...
# Engine • revision xxxxxx
# Dart • version x.x.x • ...
```

### 1.3.2 macOS Installation

**System Requirements:**
- macOS 10.15 (Catalina) or later
- 2.8 GB disk space
- Xcode (for iOS development)

```bash
# Step 1: Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Step 2: Install Flutter via Homebrew (easiest method)
brew install --cask flutter

# OR install manually:
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Step 3: Add to PATH (add to ~/.zshrc or ~/.bash_profile)
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Step 4: Install Xcode (required for iOS)
# Download from Mac App Store or:
xcode-select --install

# Step 5: Accept Xcode license
sudo xcodebuild -license accept

# Step 6: Install CocoaPods (iOS dependency manager)
sudo gem install cocoapods
# OR with Homebrew (preferred on Apple Silicon):
brew install cocoapods
```

### 1.3.3 Linux Installation

```bash
# Step 1: Install dependencies
sudo apt-get update
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa

# Step 2: Clone Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Step 3: Add to PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Step 4: Install Android Studio dependencies for Linux
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
```

---

## 1.4 Installing Android Studio & Setting Up Android Emulator

### 1.4.1 Installing Android Studio

```bash
# macOS (Homebrew)
brew install --cask android-studio

# Windows: Download installer from https://developer.android.com/studio
# Linux: Download .tar.gz from https://developer.android.com/studio
# Extract and run: ./android-studio/bin/studio.sh
```

**First-time Setup Wizard:**
1. Launch Android Studio
2. Follow the setup wizard (select "Standard" installation)
3. Let it download Android SDK, SDK Tools, and system images
4. This takes 5-15 minutes depending on your connection

### 1.4.2 Installing Flutter & Dart Plugins in Android Studio

1. Open Android Studio → Preferences (macOS) / Settings (Windows)
2. Navigate to **Plugins**
3. Search for "Flutter" and install (Dart installs automatically)
4. Restart Android Studio

### 1.4.3 Setting Up Android Emulator

```bash
# Step 1: Open Android Studio
# Step 2: Click "More Actions" → "Virtual Device Manager" (or Tools > Device Manager)
# Step 3: Click "Create Device"
# Step 4: Select hardware profile (e.g., Pixel 6)
# Step 5: Select system image (e.g., API 34 - Android 14)
# Step 6: Click Finish

# Start the emulator from command line:
# Find your AVD name:
emulator -list-avds

# Start it:
emulator -avd Pixel_6_API_34

# Or use Flutter directly (it auto-detects running emulators):
flutter emulators
flutter emulators --launch <emulator_id>
```

**Setting up Android SDK via Command Line:**

```bash
# Accept Android licenses (required!):
flutter doctor --android-licenses
# Press 'y' for each license prompt

# Verify Android SDK path:
flutter doctor -v
```

---

## 1.5 Installing VS Code with Flutter Extensions

VS Code is the preferred editor for most Flutter developers due to its speed and excellent extension support.

```bash
# macOS (Homebrew)
brew install --cask visual-studio-code

# Windows (winget)
winget install Microsoft.VisualStudioCode

# Linux (snap)
sudo snap install code --classic
```

**Essential Extensions:**

Open VS Code, press `Ctrl+Shift+X` (or `Cmd+Shift+X` on macOS) and install:

1. **Flutter** (by Dart Code) — essential, includes Dart support
2. **Dart** (by Dart Code) — usually installed with Flutter
3. **Pubspec Assist** — quick package adding
4. **Better Comments** — color-coded comment styles
5. **Error Lens** — inline error display
6. **Bracket Pair Colorizer 2** (or use built-in setting)

**Useful VS Code Settings for Flutter** (add to `settings.json`):

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true,
    "editor.rulers": [80]
  },
  "dart.debugExternalPackageLibraries": false,
  "dart.debugSdkLibraries": false
}
```

**Key Keyboard Shortcuts:**

| Action | Windows/Linux | macOS |
|--------|---------------|-------|
| Hot Reload | `Ctrl+F5` / `r` in terminal | `Cmd+F5` / `r` |
| Hot Restart | `Shift+F5` / `R` in terminal | `Shift+F5` / `R` |
| Open DevTools | `Ctrl+Shift+P` → "Dart: Open DevTools" | Same |
| Wrap with Widget | `Ctrl+.` | `Cmd+.` |
| Format Document | `Shift+Alt+F` | `Shift+Option+F` |

---

## 1.6 Running `flutter doctor` and Fixing Common Errors

`flutter doctor` is your diagnostic tool. Run it after any setup step.

```bash
flutter doctor
```

**Sample Output (all good):**

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.19.x, on macOS 14.x)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.x)
[✓] Xcode - develop for iOS and macOS (Xcode 15.x)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.x)
[✓] VS Code (version 1.9x.x)
[✓] Connected device (3 available)
[✓] Network resources
```

**Common Errors and Fixes:**

**Error 1: Android licenses not accepted**
```
[!] Android toolchain (missing Android license files)
```
```bash
# Fix:
flutter doctor --android-licenses
# Press 'y' for each prompt
```

**Error 2: Android SDK not found**
```
[✗] Android toolchain - develop for Android devices
      ✗ ANDROID_HOME = /Users/you/Library/Android/sdk
        but Android SDK not found at this location
```
```bash
# Fix: Set ANDROID_HOME environment variable
# macOS/Linux:
export ANDROID_HOME=$HOME/Library/Android/sdk        # macOS
export ANDROID_HOME=$HOME/Android/Sdk                # Linux
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
echo 'export ANDROID_HOME=...' >> ~/.zshrc

# Windows PowerShell:
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\You\AppData\Local\Android\Sdk", "Machine")
```

**Error 3: Xcode not installed (macOS)**
```
[✗] Xcode - develop for iOS and macOS
      ✗ Xcode installation is incomplete
```
```bash
# Fix:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
```

**Error 4: CocoaPods not installed (macOS)**
```
[!] CocoaPods not installed
```
```bash
# Fix:
sudo gem install cocoapods
pod setup
```

**Error 5: No connected devices**
```
[!] Connected device
      ! No devices available
```
```bash
# Fix: Start an emulator or connect a physical device
flutter emulators --launch <emulator_id>
# Or enable USB debugging on your Android device
```

---

## 1.7 Creating Your First Flutter Project

```bash
# Create a new project
flutter create my_first_app

# With specific options:
flutter create \
  --org com.yourcompany \
  --project-name my_first_app \
  --platforms android,ios,web \
  my_first_app

# Navigate into it
cd my_first_app

# Run it
flutter run
```

### 1.7.1 What Each Generated File Does

After running `flutter create my_app`, you get this structure:

```
my_first_app/
├── android/              ← Android-specific project files
├── ios/                  ← iOS-specific project files (Xcode)
├── linux/                ← Linux desktop (if enabled)
├── macos/                ← macOS desktop (if enabled)
├── web/                  ← Web support files (index.html, etc.)
├── windows/              ← Windows desktop (if enabled)
├── lib/
│   └── main.dart         ← YOUR APP STARTS HERE
├── test/
│   └── widget_test.dart  ← Automated tests
├── pubspec.yaml          ← Project manifest (dependencies, assets)
├── pubspec.lock          ← Locked dependency versions
├── analysis_options.yaml ← Dart linter rules
├── .gitignore            ← Files to exclude from git
└── README.md             ← Project documentation
```

**Let's look at the default `main.dart`:**

```dart
// lib/main.dart — The entry point of every Flutter application

// Import the Flutter Material design library
import 'package:flutter/material.dart';

// main() is the entry point — just like in C, Java, or Python
// runApp() takes a Widget and makes it the root of the widget tree
void main() {
  runApp(const MyApp());
}

// MyApp is a StatelessWidget — it never changes its state
// Think of it as the application container/shell
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // build() is called whenever Flutter needs to render this widget
  // BuildContext gives access to the widget's location in the tree
  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up Material Design theming and navigation
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Use Material Design 3 (modern)
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// MyHomePage is a StatefulWidget — it can change over time
// The title is passed as a constructor parameter
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // Properties declared in StatefulWidget are immutable
  final String title;

  // createState() creates the mutable State object
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// _MyHomePageState holds the mutable data for MyHomePage
// The underscore makes it private to this file
class _MyHomePageState extends State<MyHomePage> {
  // This is the mutable state — a counter that increments
  int _counter = 0;

  void _incrementCounter() {
    // setState() tells Flutter: "something changed, please rebuild!"
    // Only the widgets that depend on _counter will rebuild
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is called every time setState() is called
    // Flutter is smart enough to make this efficient
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title), // Access StatefulWidget props via `widget`
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter', // String interpolation in Dart
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### ⚠️ Common Mistakes — Session 1

1. **Installing Flutter in a path with spaces** (e.g., `C:\Program Files\flutter`). Always use paths without spaces: `C:\flutter` or `C:\dev\flutter`.

2. **Not running `flutter doctor --android-licenses`** after Android Studio setup. The licenses must be accepted before Flutter can use the Android toolchain.

3. **Forgetting to restart the terminal** after modifying PATH. Changes to environment variables don't take effect in already-open terminals.

4. **Using an outdated Flutter channel.** Always use `stable` channel unless you have a specific reason not to: `flutter channel stable && flutter upgrade`.

5. **Mixing Android Studio and VS Code setups.** Pick one primary IDE to avoid configuration conflicts, especially with Flutter SDK path settings.

### ✏️ Exercises — Session 1

**Exercise 1.1:** Install Flutter on your machine and run `flutter doctor`. Take a screenshot of the output. Fix at least one warning if any exist.
> *Hint: Run `flutter doctor -v` for verbose output that shows exactly what's being checked.*

**Exercise 1.2:** Create a new Flutter project called `hello_flutter`. Modify `main.dart` to display your name instead of the counter. Run it on an emulator or physical device.
> *Hint: Find the `Text` widget in the `body` and change its content.*

**Exercise 1.3:** Look at the generated `main.dart`. Identify and label: (a) the entry point, (b) a StatelessWidget, (c) a StatefulWidget, (d) a call to `setState`. Write a short explanation of each in comments.
> *Hint: The `void main()` function is always the entry point in Dart.*

**Exercise 1.4 (Challenge):** Research what the `BuildContext` parameter in `build()` is used for. Write 3-5 sentences explaining it in your own words.
> *Hint: Think of it as a "location tag" that tells a widget where it is in the tree.*

---

# Session 2 – Project Structure & Tooling

## 2.1 Full Flutter Project Structure Breakdown

When you work professionally on Flutter, you need to know every file in your project. Let's go deep.

```
my_app/
├── .dart_tool/           ← Generated by Dart tools (do NOT commit)
│   └── package_config.json  ← Maps package names to local paths
├── .flutter-plugins       ← Auto-generated plugin registry (do NOT edit)
├── .flutter-plugins-dependencies ← Plugin dependency graph
├── android/
│   ├── app/
│   │   ├── build.gradle  ← Android app-level build config
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml ← App permissions, activities
│   │           ├── kotlin/com/example/myapp/
│   │           │   └── MainActivity.kt ← Flutter entry point for Android
│   │           └── res/               ← Android resources (icons, etc.)
│   ├── build.gradle      ← Project-level Android build config
│   ├── gradle/
│   │   └── wrapper/
│   │       └── gradle-wrapper.properties ← Gradle version spec
│   ├── gradle.properties  ← Gradle options (memory, R8, etc.)
│   └── settings.gradle    ← Project structure definition
├── ios/
│   ├── Runner/
│   │   ├── AppDelegate.swift ← iOS app entry point
│   │   ├── Info.plist         ← iOS app configuration, permissions
│   │   └── Assets.xcassets/   ← iOS icons, launch images
│   ├── Runner.xcodeproj/  ← Xcode project file
│   ├── Runner.xcworkspace/ ← Xcode workspace (use this to open)
│   └── Podfile            ← CocoaPods dependencies
├── lib/                   ← YOUR DART CODE LIVES HERE
│   └── main.dart          ← Entry point
├── test/                  ← All test files
│   └── widget_test.dart   ← Default widget test
├── assets/                ← Images, fonts, JSON files (you create this)
├── pubspec.yaml           ← Project configuration (THE most important file)
├── pubspec.lock           ← Locked versions (commit this!)
├── analysis_options.yaml  ← Linter rules
└── .gitignore
```

### 2.1.1 The `lib/` Directory — Where You Live

The `lib/` directory is where all your Dart code lives. For a professional project, you'll structure it like this:

```
lib/
├── main.dart                    ← Entry point only
├── app.dart                     ← MaterialApp configuration
├── core/                        ← Shared utilities, constants
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_dimensions.dart
│   ├── extensions/              ← Dart extension methods
│   ├── utils/                   ← Helper functions
│   └── errors/                  ← Error classes
├── features/                    ← Feature-based organization
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/                      ← Shared widgets, services
│   ├── widgets/
│   └── services/
└── config/                      ← App-wide configuration
    ├── router/
    └── theme/
```

> **💡 Pro Tip:** The most popular architectural patterns for Flutter projects are **Clean Architecture** (features → data/domain/presentation), **MVVM**, and **BLoC pattern**. We'll cover these in later modules. For now, organize by feature, not by type.

---

## 2.2 `pubspec.yaml` Deep Dive

The `pubspec.yaml` is the heart of your Flutter project. It defines everything from dependencies to assets to fonts. YAML is indentation-sensitive — always use **2 spaces** (never tabs).

```yaml
# pubspec.yaml — Full annotated example

# Package name: must be lowercase_with_underscores
# This is also used as your import path: package:my_app/...
name: my_app

# Human-readable description shown on pub.dev if published
description: "A comprehensive Flutter ecommerce application."

# Semantic versioning: major.minor.patch+build_number
# The part after '+' is the build number (incremented for each release)
version: 1.0.0+1

# Minimum Dart SDK version required
# Flutter versions include a specific Dart version
environment:
  sdk: '>=3.0.0 <4.0.0'

# ─────────────────────────────────────────
# DEPENDENCIES — packages your app NEEDS to run
# ─────────────────────────────────────────
dependencies:
  flutter:
    sdk: flutter  # The Flutter framework itself

  # Cupertino icons for iOS-style icons
  cupertino_icons: ^1.0.6

  # State management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # HTTP client for API calls
  dio: ^5.4.0

  # Local storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # Navigation
  go_router: ^13.2.0

  # JSON serialization
  json_annotation: ^4.8.1

  # Image loading from network with caching
  cached_network_image: ^3.3.1

  # Internationalization (i18n)
  flutter_localizations:
    sdk: flutter  # Part of Flutter SDK

  # Git dependency (uncomment to use):
  # my_package:
  #   git:
  #     url: https://github.com/example/my_package.git
  #     ref: main  # branch, tag, or commit hash

  # Local path dependency (for monorepos):
  # my_local_package:
  #   path: ../my_local_package

# ─────────────────────────────────────────
# DEV DEPENDENCIES — only used during development
# NOT included in the release build
# ─────────────────────────────────────────
dev_dependencies:
  flutter_test:
    sdk: flutter  # Flutter testing framework

  # Linting rules
  flutter_lints: ^3.0.0

  # Code generation for JSON serialization
  build_runner: ^2.4.8
  json_serializable: ^6.7.1

  # Mocking for tests
  mocktail: ^1.0.1

  # Integration testing
  integration_test:
    sdk: flutter

# ─────────────────────────────────────────
# FLUTTER-SPECIFIC CONFIGURATION
# ─────────────────────────────────────────
flutter:
  # This line makes the Material Icons font available
  uses-material-design: true

  # ASSETS — files included in the app bundle
  assets:
    # You can list individual files:
    - assets/images/logo.png
    - assets/images/onboarding_1.png
    # Or entire directories (note the trailing slash!):
    - assets/images/
    - assets/icons/
    - assets/data/config.json
    - assets/animations/  # Lottie JSON files

  # FONTS — custom fonts bundled with the app
  fonts:
    - family: Poppins  # The name you use in TextStyle
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
          weight: 400
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
        - asset: assets/fonts/Poppins-Italic.ttf
          style: italic

    - family: Montserrat
      fonts:
        - asset: assets/fonts/Montserrat-Regular.ttf
        - asset: assets/fonts/Montserrat-Bold.ttf
          weight: 700
```

**Version Constraint Syntax:**

```yaml
# Caret syntax (^) — allows compatible updates
flutter_bloc: ^8.1.3  # allows >= 8.1.3 and < 9.0.0

# Range syntax
some_package: '>=2.0.0 <3.0.0'

# Exact version (avoid unless necessary)
some_package: 2.1.4

# Any version (very bad practice — never do this in production)
some_package: any
```

---

## 2.3 Build Flavors: dev / staging / production

Real apps have multiple environments: development (local APIs, debug logging), staging (pre-production testing), and production (live users, real data). Flutter handles this with **flavors** (Android) and **schemes** (iOS), combined with `--dart-define`.

### 2.3.1 Using `--dart-define` (Simplest Approach)

```dart
// lib/config/env.dart

// Read compile-time constants passed via --dart-define
// The second argument is the default value
const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://dev-api.myapp.com',
);
const bool enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);
const String googleMapsApiKey = String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

class AppConfig {
  static const String environment = appEnv;
  static const String baseUrl = apiBaseUrl;
  static const bool isProduction = appEnv == 'production';
  static const bool isDevelopment = appEnv == 'dev';
}
```

**Running with different environments:**

```bash
# Development
flutter run --dart-define=APP_ENV=dev \
            --dart-define=API_BASE_URL=https://dev-api.myapp.com \
            --dart-define=ENABLE_LOGGING=true

# Staging
flutter run --dart-define=APP_ENV=staging \
            --dart-define=API_BASE_URL=https://staging-api.myapp.com \
            --dart-define=ENABLE_LOGGING=true

# Production
flutter build apk --dart-define=APP_ENV=production \
                  --dart-define=API_BASE_URL=https://api.myapp.com \
                  --dart-define=ENABLE_LOGGING=false
```

### 2.3.2 Using `--dart-define-from-file` (Flutter 3.7+)

Create environment files:

```json
// config/dev.json
{
  "APP_ENV": "dev",
  "API_BASE_URL": "https://dev-api.myapp.com",
  "ENABLE_LOGGING": "true",
  "APP_NAME": "MyApp Dev"
}
```

```json
// config/production.json
{
  "APP_ENV": "production",
  "API_BASE_URL": "https://api.myapp.com",
  "ENABLE_LOGGING": "false",
  "APP_NAME": "MyApp"
}
```

```bash
# Run with a config file
flutter run --dart-define-from-file=config/dev.json

# Build production
flutter build apk --dart-define-from-file=config/production.json
```

> **💡 Pro Tip:** Add your config JSON files to `.gitignore` if they contain API keys or secrets. Use environment variable injection in your CI/CD pipeline to generate them at build time.

---

## 2.4 Flutter CLI Commands Reference

```bash
# ─── PROJECT MANAGEMENT ───────────────────────────────────

# Create a new project
flutter create <project_name>
flutter create --org com.mycompany --platforms android,ios my_app

# Upgrade Flutter SDK
flutter upgrade

# Switch Flutter channel
flutter channel stable    # Most stable
flutter channel beta      # Upcoming features
flutter channel master    # Bleeding edge (not recommended for production)

# ─── DEPENDENCY MANAGEMENT ────────────────────────────────

# Get/install all dependencies listed in pubspec.yaml
flutter pub get

# Upgrade all dependencies to latest compatible versions
flutter pub upgrade

# Upgrade a specific package
flutter pub upgrade flutter_bloc

# Add a package (shorthand)
flutter pub add dio

# Remove a package
flutter pub remove some_package

# Resolve dependency conflicts
flutter pub deps  # Show dependency tree

# ─── RUNNING & BUILDING ───────────────────────────────────

# Run on a connected device/emulator
flutter run

# Run on a specific device
flutter devices  # List available devices
flutter run -d <device_id>

# Run in release mode (optimized, no debug overlay)
flutter run --release

# Run in profile mode (for performance profiling)
flutter run --profile

# Build Android APK (debug)
flutter build apk --debug

# Build Android APK (release)
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build iOS (release)
flutter build ios --release

# Build web
flutter build web

# Build Windows/macOS/Linux
flutter build windows
flutter build macos
flutter build linux

# ─── TESTING ──────────────────────────────────────────────

# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# ─── CODE QUALITY ─────────────────────────────────────────

# Run the Dart analyzer (find errors, warnings, hints)
flutter analyze

# Format all Dart files
dart format .
# Or:
dart format lib/ test/

# Fix simple issues automatically
dart fix --apply

# ─── MAINTENANCE ──────────────────────────────────────────

# Clean the build cache (fixes many mysterious build errors)
flutter clean

# After cleaning, always run pub get
flutter pub get

# Check for outdated packages
flutter pub outdated

# ─── DIAGNOSTICS ──────────────────────────────────────────

# Run environment diagnostics
flutter doctor
flutter doctor -v  # Verbose output

# Show Flutter SDK info
flutter --version

# List connected devices
flutter devices

# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Show logs from running app
flutter logs
```

---

## 2.5 Understanding `main.dart` and the Entry Point

Every Flutter app has one entry point: the `main()` function in `lib/main.dart`.

```dart
// lib/main.dart — Professional setup example

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome

// Import your app configuration
import 'app.dart';
import 'core/constants/app_config.dart';

// The main function can be async if you need to await initialization
void main() async {
  // IMPORTANT: Must call this before any async operations in main()
  // It initializes the Flutter engine bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only in this example)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style (status bar appearance)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize any services before the app starts
  // await FirebaseInitializer.initialize();
  // await HiveInitializer.initialize();

  // Launch the app
  runApp(const MyApp());
}
```

```dart
// lib/app.dart — The root application widget

import 'package:flutter/material.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App title (shown in task switcher)
      title: 'ShopEase',

      // Remove the debug banner in the top-right corner
      debugShowCheckedModeBanner: false,

      // Custom theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system preference

      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}
```

### ⚠️ Common Mistakes — Session 2

1. **Forgetting to run `flutter pub get` after modifying `pubspec.yaml`.** The IDE usually prompts you, but if things break, always try `flutter pub get` first.

2. **YAML indentation errors.** YAML uses exactly 2 spaces for indentation. Never use tabs. One wrong indentation level will cause cryptic "Bad state" errors.

3. **Declaring assets without a trailing slash for directories.** Use `assets/images/` not `assets/images` to include all files in a directory.

4. **Not calling `WidgetsFlutterBinding.ensureInitialized()`** before using `async` operations in `main()`. This causes a black screen or crash on startup.

5. **Committing generated files.** Add `.dart_tool/`, `build/`, `.flutter-plugins`, `.flutter-plugins-dependencies` to `.gitignore`. But DO commit `pubspec.lock`.

### ✏️ Exercises — Session 2

**Exercise 2.1:** Add the `http` package to your project's `pubspec.yaml`. Then write a comment explaining the difference between `^0.13.0` and `0.13.0` as version constraints.
> *Hint: Look up "semantic versioning" and caret constraints.*

**Exercise 2.2:** Create a directory called `assets/images/` in your project and add any PNG image to it. Register it in `pubspec.yaml` and display it using the `Image.asset()` widget.
> *Hint: After modifying pubspec.yaml, run `flutter pub get`.*

**Exercise 2.3:** Modify the `main()` function in your project to be `async` and restrict the app to portrait-only mode using `SystemChrome.setPreferredOrientations()`.
> *Hint: Don't forget `WidgetsFlutterBinding.ensureInitialized()` before using async operations.*

**Exercise 2.4 (Challenge):** Create a simple `AppConfig` class that reads an `APP_NAME` compile-time constant using `String.fromEnvironment()`. Run the app twice — once without setting the constant (it should show the default) and once with `--dart-define=APP_NAME=MyTestApp`.
> *Hint: Print the value using `debugPrint(AppConfig.appName)` in main().*

---

# Session 3 – Hot Reload / Restart & Widget Tree

## 3.1 Hot Reload vs Hot Restart vs Full Restart

Understanding these three modes is essential for an efficient Flutter development workflow.

### 3.1.1 Hot Reload (`r` in terminal / `Ctrl+F5` in VS Code)

**What it does internally:**
1. Flutter compiles only the changed Dart files into **kernel bytecode**
2. The new bytecode is injected into the running Dart VM
3. Flutter calls `reassemble()` on the root widget (forcing a rebuild)
4. The widget tree is rebuilt with the new code
5. **The app state is PRESERVED**

**What it can update:**
- Changes to `build()` methods (UI changes)
- New widgets added or removed
- Style changes, layout changes
- Logic inside `build()` methods

**What it CANNOT update:**
- Changes to `initState()` (the app is already initialized)
- Changes to `main()` function
- Added or removed static fields
- Changed global variables (the values are kept from the old code)

```bash
# In terminal while app is running:
r   # Hot reload
R   # Hot restart
q   # Quit
h   # Show help
p   # Show widget bounds
o   # Toggle operating system (Android/iOS rendering)
s   # Save screenshot
```

### 3.1.2 Hot Restart (`R` in terminal / `Shift+F5` in VS Code)

**What it does internally:**
1. Stops the current Dart VM isolate
2. Recompiles the full app (takes a few seconds)
3. Starts a completely fresh Dart VM
4. Runs `main()` again from the beginning
5. **App state is RESET**

**When to use hot restart:**
- After changing `initState()` or constructor logic
- After adding new dependencies
- After modifying `main()` or global variables
- When hot reload doesn't seem to pick up changes
- After adding new platform (native) code

### 3.1.3 Full Restart (Stop and re-run the app)

**What it does:**
- Completely stops the app process
- Reinstalls the debug APK/app on the device
- Runs `main()` from scratch with a clean state

**When you need a full restart:**
- After changing `pubspec.yaml` (adding dependencies or assets)
- After modifying Android `build.gradle` or iOS `Podfile`
- After changing native Android/iOS code
- After running `flutter clean && flutter pub get`

**Comparison Table:**

| Feature | Hot Reload | Hot Restart | Full Restart |
|---------|-----------|-------------|--------------|
| Speed | < 1 second | 2–5 seconds | 10–30 seconds |
| State preserved | ✅ Yes | ❌ No | ❌ No |
| Applies `initState()` changes | ❌ No | ✅ Yes | ✅ Yes |
| Applies `main()` changes | ❌ No | ✅ Yes | ✅ Yes |
| Re-installs app | ❌ No | ❌ No | ✅ Yes |
| Applies native code changes | ❌ No | ❌ No | ✅ Yes |

> **💡 Pro Tip:** Use hot reload for 90% of UI iteration. Use hot restart when state changes make things look wrong. Only do a full restart after native code changes or adding packages. Mastering this workflow saves you hours per week.

---

## 3.2 The Widget, Element, and Render Trees — Deep Dive

### 3.2.1 Widgets — The Blueprints

```dart
// Widgets are IMMUTABLE configuration objects.
// They are cheap to create and destroy.

// Example: A Text widget is just a Dart class holding configuration data
class Text extends Widget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  // ... more fields
}

// Creating a widget is like filling out a form — it just holds data
// The heavy work (layout, painting) happens in the render objects

// Every time your state changes, Flutter creates NEW widget instances:
Text('Hello')  // Old widget (discarded)
Text('World')  // New widget (created after setState())
```

### 3.2.2 Widget Types: StatelessWidget vs StatefulWidget

```dart
// ─────────────────────────────────────────────────────────
// STATELESS WIDGET
// ─────────────────────────────────────────────────────────
// Use when: The UI depends only on the data passed in (props)
// and never needs to change internally.
// Examples: Labels, icons, display cards, layout containers

class UserAvatarWidget extends StatelessWidget {
  // All data is passed through the constructor — no internal state
  final String imageUrl;
  final String username;
  final double size;

  const UserAvatarWidget({
    super.key, // Always use super.key for performance
    required this.imageUrl,
    required this.username,
    this.size = 48.0, // Default parameter value
  });

  @override
  Widget build(BuildContext context) {
    // This runs every time the parent rebuilds and passes new data
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(height: 4),
        Text(
          username,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// STATEFUL WIDGET
// ─────────────────────────────────────────────────────────
// Use when: The widget needs to track internal state that changes over time.
// Examples: Checkboxes, forms, counters, animations, toggles, timers

class LikeButton extends StatefulWidget {
  // Configuration that comes from outside (immutable)
  final int initialLikeCount;
  final VoidCallback? onLikeChanged;

  const LikeButton({
    super.key,
    required this.initialLikeCount,
    this.onLikeChanged,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  // Internal mutable state
  late bool _isLiked;
  late int _likeCount;

  // initState() is called ONCE when this widget is first inserted into the tree
  // Think of it as a constructor for the state
  @override
  void initState() {
    super.initState(); // Always call super.initState() first!
    _isLiked = false;
    _likeCount = widget.initialLikeCount; // Access the widget's config via `widget`
  }

  // dispose() is called when this widget is permanently removed from the tree
  // Clean up: cancel timers, close streams, dispose controllers here
  @override
  void dispose() {
    // Example: _animationController.dispose();
    super.dispose(); // Always call super.dispose() last!
  }

  void _toggleLike() {
    // setState() marks this widget as needing a rebuild
    // The function inside setState() should ONLY update state — no async work!
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    // Notify parent (optional callback)
    widget.onLikeChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(_isLiked), // Required for AnimatedSwitcher
              color: _isLiked ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Text('$_likeCount'),
        ],
      ),
    );
  }
}
```

### 3.2.3 Widget Tree Diagram (ASCII)

```
MaterialApp
    │
    └── Scaffold
            │
            ├── AppBar
            │     │
            │     └── Text("Home")
            │
            ├── body: Column
            │         │
            │         ├── Text("Hello, World!")
            │         │
            │         ├── SizedBox(height: 16)
            │         │
            │         └── Row
            │               │
            │               ├── Icon(Icons.star)
            │               │
            │               └── Text("Flutter")
            │
            └── FloatingActionButton
                      │
                      └── Icon(Icons.add)
```

```
Element Tree (mirrors Widget Tree but persists across rebuilds):

MaterialApp [StatefulElement]
    │
    └── Scaffold [StatelessElement]
            │
            ├── AppBar [StatelessElement]
            │     └── Text [StatelessElement]
            │
            ├── Column [StatelessElement]
            │     ├── Text [StatelessElement]
            │     ├── SizedBox [StatelessElement]
            │     └── Row [StatelessElement]
            │           ├── Icon [StatelessElement]
            │           └── Text [StatelessElement]
            │
            └── FAB [StatelessElement]
                  └── Icon [StatelessElement]
```

```
Render Tree (only renders what's needed):

RenderView
    │
    └── RenderSemanticsAnnotations
            │
            └── RenderFlex (Column)
                    │
                    ├── RenderParagraph ("Hello, World!")
                    │
                    ├── RenderConstrainedBox (SizedBox)
                    │
                    └── RenderFlex (Row)
                            │
                            ├── RenderCustomPaint (Icon)
                            │
                            └── RenderParagraph ("Flutter")
```

### 3.2.4 The Widget Lifecycle (StatefulWidget)

```dart
class LifecycleExampleWidget extends StatefulWidget {
  const LifecycleExampleWidget({super.key});

  @override
  State<LifecycleExampleWidget> createState() => _LifecycleExampleState();
}

class _LifecycleExampleState extends State<LifecycleExampleWidget> {

  // 1. CONSTRUCTOR — called when State is created
  // Use for synchronous initialization of simple variables
  _LifecycleExampleState() {
    debugPrint('1. Constructor called');
  }

  // 2. initState() — called once after the widget is inserted into the tree
  // The widget property is now available (unlike the constructor)
  // Use for: subscriptions, animation controllers, fetching initial data
  @override
  void initState() {
    super.initState(); // ALWAYS first
    debugPrint('2. initState() called');
    // context is NOT fully available here for some operations
    // For things needing context, use: 
    // WidgetsBinding.instance.addPostFrameCallback((_) { ... });
  }

  // 3. didChangeDependencies() — called after initState() and when 
  // an InheritedWidget (like Theme or MediaQuery) this widget depends on changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('3. didChangeDependencies() called');
    // context is fully available here — safe to use Theme.of(context), etc.
  }

  // 4. build() — called every time the widget needs to rebuild
  // Called after initState, didChangeDependencies, and setState
  @override
  Widget build(BuildContext context) {
    debugPrint('4. build() called');
    return const Placeholder();
  }

  // 5. didUpdateWidget() — called when the parent passes new configuration
  // (new widget properties) to this existing state
  @override
  void didUpdateWidget(LifecycleExampleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('5. didUpdateWidget() called');
    // Compare oldWidget vs widget to respond to changes
  }

  // 6. setState() — triggers a rebuild
  // (not a lifecycle method, but triggers build())

  // 7. deactivate() — called when this widget is removed from the tree
  // May be reinserted (e.g., when navigating back)
  @override
  void deactivate() {
    debugPrint('7. deactivate() called');
    super.deactivate();
  }

  // 8. dispose() — called when this widget is permanently removed
  // CRITICAL: Clean up ALL resources here
  @override
  void dispose() {
    debugPrint('8. dispose() called');
    // animationController.dispose();
    // streamSubscription.cancel();
    // textEditingController.dispose();
    super.dispose(); // ALWAYS last
  }
}
```

---

## 3.3 Flutter DevTools

Flutter DevTools is a suite of debugging and profiling tools that runs in your browser. It's invaluable for production-quality Flutter development.

### 3.3.1 Launching DevTools

```bash
# Method 1: From terminal (while app is running)
flutter run
# Then in the terminal output, look for:
# "An Observatory debugger and profiler on ... is available at: http://127.0.0.1:9100/..."
# Or run:
dart devtools

# Method 2: VS Code
# While app is running, press Ctrl+Shift+P → "Dart: Open DevTools"

# Method 3: Android Studio
# Run your app, then click the "Flutter Inspector" tab at the bottom
```

### 3.3.2 Key DevTools Features

**Widget Inspector:**
- Visualize the entire widget tree
- Click any widget to see its properties and constraints
- Toggle "Select Widget Mode" to click on UI elements to inspect them
- See which widgets are rebuilding (highlight repaint)

**Performance View:**
- Frame timeline showing each frame's build and raster time
- Identify jank (frames that take > 16ms for 60fps)
- Profile mode must be used for accurate performance data

**Memory View:**
- Track heap memory usage over time
- Detect memory leaks
- Take heap snapshots

**Network View:**
- Monitor HTTP requests made by the app
- See request/response headers and bodies

**Logging View:**
- See `debugPrint()` and `print()` output
- Filter logs by severity

```dart
// Using debugPrint (recommended over print for Flutter)
debugPrint('User logged in: $userId');

// Using log for structured logging
import 'dart:developer';
log('Payment processed', name: 'PaymentService', error: exception);
```

### ⚠️ Common Mistakes — Session 3

1. **Using hot reload when `initState()` changes need to apply.** If you modified `initState()`, you must hot restart or the change won't take effect.

2. **Calling `setState()` inside `build()`.** This creates an infinite loop — `build()` is called → `setState()` triggers another build → infinite. Always call `setState()` from event handlers.

3. **Forgetting to call `dispose()` on controllers.** AnimationControllers, TextEditingControllers, and StreamSubscriptions that aren't disposed cause memory leaks.

4. **Using `BuildContext` after `async` operations.** The widget might have been disposed while you were awaiting. Always check `if (mounted)` before using context after an await.

```dart
// ❌ WRONG — context might be invalid after await
void _loadData() async {
  final data = await fetchDataFromApi();
  Navigator.of(context).push(...); // Context might be disposed!
}

// ✅ CORRECT — check mounted after every await
void _loadData() async {
  final data = await fetchDataFromApi();
  if (!mounted) return; // Bail out if widget was disposed
  Navigator.of(context).push(...);
}
```

5. **Overusing StatefulWidget.** Not everything needs to be stateful. Prefer StatelessWidget and lift state up to where it's truly needed.

### ✏️ Exercises — Session 3

**Exercise 3.1:** Create a `CounterWidget` as a StatefulWidget with increment and decrement buttons. Add `debugPrint` statements in `initState()`, `build()`, and `dispose()`. Observe when each is called by navigating to and from the screen.
> *Hint: Wrap the widget in a Navigator.push() to trigger dispose when navigating back.*

**Exercise 3.2:** Create a `TypingIndicator` StatefulWidget that shows/hides a blinking dot every 500ms using a Timer from `dart:async`. Make sure to cancel the timer in `dispose()`.
> *Hint: Import `dart:async` and use `Timer.periodic(Duration(milliseconds: 500), callback)`.*

**Exercise 3.3:** Open Flutter DevTools Widget Inspector while your app is running. Inspect the widget tree and identify: (a) the element count, (b) at least one widget with a constraint value, and (c) one widget that is rebuilding frequently.
> *Hint: Turn on "highlight repaints" in DevTools to see which widgets rebuild.*

---

# Session 4 – Basic UI Composition with Scaffold

## 4.1 MaterialApp and Its Properties

`MaterialApp` is the root widget of most Flutter apps. It sets up Material Design, navigation, theming, localization, and more.

```dart
// lib/app.dart — Comprehensive MaterialApp example

import 'package:flutter/material.dart';

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ── Identity ───────────────────────────────────────────
      title: 'ShopEase',                    // Shown in task switcher
      debugShowCheckedModeBanner: false,     // Remove the red "DEBUG" banner

      // ── Theming ─────────────────────────────────────────────
      // Light theme (default)
      theme: ThemeData(
        // Color scheme generated from a seed color (Material 3)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Purple accent
          brightness: Brightness.light,
        ),
        useMaterial3: true, // Enable Material Design 3

        // Custom font family (must be registered in pubspec.yaml)
        fontFamily: 'Poppins',

        // Customize specific component themes
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),

      // Dark theme (activated when system is in dark mode)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),

      // Follow system light/dark preference
      themeMode: ThemeMode.system, // ThemeMode.light | ThemeMode.dark | ThemeMode.system

      // ── Navigation ──────────────────────────────────────────
      // Simple approach: set home widget
      home: const HomeScreen(),

      // Named routes (simple apps)
      // routes: {
      //   '/': (context) => const HomeScreen(),
      //   '/product': (context) => const ProductScreen(),
      //   '/cart': (context) => const CartScreen(),
      // },

      // Initial route
      // initialRoute: '/',

      // ── Localization ────────────────────────────────────────
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,

      // ── Error Handling ──────────────────────────────────────
      // Override the default red error screen in debug mode:
      builder: (context, child) {
        // You can wrap the entire app here (e.g., with a global error handler)
        return child ?? const SizedBox.shrink();
      },

      // ── Scrolling Behavior ──────────────────────────────────
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        // Enable mouse dragging on desktop/web
        dragDevices: {
          // PointerDeviceKind.mouse,
          // PointerDeviceKind.touch,
        },
      ),
    );
  }
}
```

---

## 4.2 Scaffold Widget: The Page Template

`Scaffold` is the layout structure for a single screen in a Material Design app. Think of it as a page template with named slots.

```
┌─────────────────────────────────────────────┐
│                   AppBar                    │ ← appBar
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│                   body                      │ ← body
│                                             │
│                                             │
│                   [FAB]                     │ ← floatingActionButton
├─────────────────────────────────────────────┤
│              BottomNavigationBar            │ ← bottomNavigationBar
└─────────────────────────────────────────────┘
     ↑
  drawer (slides in from left)
  endDrawer (slides in from right)
```

```dart
// lib/screens/home_screen.dart — Comprehensive Scaffold example

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track which bottom nav item is selected

  // The pages shown for each bottom nav item
  static const List<Widget> _pages = [
    _HomeTab(),
    _SearchTab(),
    _CartTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ────────────────────────────────────────────────────
      appBar: AppBar(
        // Title — can be any widget, not just Text
        title: const Text(
          'ShopEase',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // Center the title (already set in theme, but can override here)
        centerTitle: true,

        // Left side actions (leading widget)
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),

        // Right side actions
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],

        // Bottom of AppBar (e.g., TabBar or search bar)
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(60),
        //   child: SearchBar(),
        // ),

        // Background color (overrides theme)
        backgroundColor: Colors.white,

        // Shadow below the AppBar
        elevation: 1,
      ),

      // ── Drawer ────────────────────────────────────────────────────
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header with user info
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'John Doe',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'john@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────
      body: _pages[_selectedIndex],

      // ── Floating Action Button ─────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB press
        },
        tooltip: 'Add to cart',
        child: const Icon(Icons.add_shopping_cart),
      ),

      // Position the FAB (center, end, etc.)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ── Bottom Navigation Bar ──────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

      // ── Background Color ───────────────────────────────────────────
      backgroundColor: const Color(0xFFF8F9FA),

      // ── Safe Area (avoid notches/system UI) ─────────────────────────
      // Scaffold automatically respects safe areas for the body
      // For custom handling, wrap children with SafeArea widget
    );
  }
}

// Placeholder tab widgets (simplified)
class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Home'));
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Search'));
}

class _CartTab extends StatelessWidget {
  const _CartTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Cart'));
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Profile'));
}
```

---

## 4.3 Basic Layout Widgets

Layout in Flutter is done through **layout widgets** — widgets that position and size their children.

### 4.3.1 Container

```dart
// Container is the most versatile layout widget
// It can control: size, padding, margin, color, decoration, alignment

Container(
  // Size constraints
  width: 200,
  height: 100,
  // OR: constraints: BoxConstraints(minWidth: 100, maxWidth: 300),

  // Inner spacing (space inside the container)
  padding: const EdgeInsets.all(16),
  // EdgeInsets variants:
  // EdgeInsets.all(16)                  — all sides
  // EdgeInsets.symmetric(h: 16, v: 8)  — horizontal/vertical
  // EdgeInsets.only(left: 16, top: 8)  — specific sides
  // EdgeInsets.fromLTRB(8, 16, 8, 16)  — left, top, right, bottom

  // Outer spacing (space outside the container)
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

  // Alignment of child within the container
  alignment: Alignment.center,
  // Other alignments: topLeft, topCenter, topRight, centerLeft, centerRight,
  //                   bottomLeft, bottomCenter, bottomRight

  // Background decoration (use BoxDecoration instead of color for more control)
  decoration: BoxDecoration(
    // Solid color
    color: Colors.white,

    // Gradient (can't use both color and gradient — use gradient only)
    // gradient: LinearGradient(colors: [Colors.purple, Colors.blue]),

    // Rounded corners
    borderRadius: BorderRadius.circular(16),

    // Border
    border: Border.all(color: Colors.grey.shade200, width: 1),

    // Shadow
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),

  // Child widget
  child: const Text('Hello'),
)
```

### 4.3.2 Column and Row

```dart
// Column — vertical layout
// Row — horizontal layout

Column(
  // How to position children along the MAIN axis (vertical for Column)
  mainAxisAlignment: MainAxisAlignment.center,
  // Options: start, end, center, spaceBetween, spaceAround, spaceEvenly

  // How to size children along the MAIN axis
  mainAxisSize: MainAxisSize.max, // Expand to full height
  // MainAxisSize.min — shrink to fit children

  // How to align children along the CROSS axis (horizontal for Column)
  crossAxisAlignment: CrossAxisAlignment.stretch,
  // Options: start, end, center, stretch, baseline

  children: [
    // Fixed-size widgets
    const Text('Item 1'),
    const SizedBox(height: 8), // Spacer

    // Flexible — takes remaining space proportionally
    Flexible(
      flex: 1, // Share of remaining space
      child: Container(color: Colors.blue),
    ),

    // Expanded — forces child to fill remaining space
    Expanded(
      flex: 2, // Gets 2x more space than Flexible(flex: 1)
      child: Container(color: Colors.red),
    ),
  ],
)

// Row — same properties but horizontal
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Icon(Icons.star, color: Colors.amber),
    const Text('4.8'),
    const Spacer(), // Flexible spacer that fills available space
    const Text('(128 reviews)'),
  ],
)
```

### 4.3.3 Padding, Center, SizedBox, Align

```dart
// Padding — adds space around a child
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Text('Padded text'),
)

// Center — centers child within parent
Center(
  child: Text('I am centered'),
)

// SizedBox — fixed-size box (also used as spacer)
const SizedBox(width: 200, height: 100, child: Text('Fixed size'))
// As spacer (no child):
const SizedBox(height: 16) // 16px vertical gap in a Column
const SizedBox(width: 8)   // 8px horizontal gap in a Row
// SizedBox.expand() — fills all available space

// Align — aligns child within parent with fine control
Align(
  alignment: Alignment.topRight,
  child: const Text('Top right'),
)
// Alignment(x, y) where x, y are -1.0 to 1.0:
// Alignment(-1, -1) = topLeft
// Alignment(0, 0) = center
// Alignment(1, 1) = bottomRight
```

---

## 4.4 Text Widget and Style Options

```dart
// Basic Text
const Text('Hello, World!')

// Styled Text
Text(
  'Flutter is amazing!',
  style: TextStyle(
    // Font
    fontSize: 24,
    fontWeight: FontWeight.bold,      // thin, extraLight, light, normal, medium,
                                      // semiBold, bold, extraBold, w900
    fontStyle: FontStyle.italic,

    // Color
    color: const Color(0xFF333333),
    // Colors.blue, Colors.red, Color(0xFFRRGGBB), Color.fromARGB(a, r, g, b)

    // Decoration
    decoration: TextDecoration.underline,
    decorationColor: Colors.blue,
    decorationStyle: TextDecorationStyle.dashed,

    // Letter and word spacing
    letterSpacing: 1.2,
    wordSpacing: 4.0,

    // Line height
    height: 1.5, // 1.5x the font size

    // Background color
    backgroundColor: Colors.yellow,

    // Shadow
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  ),

  // Alignment within Text widget
  textAlign: TextAlign.center, // left, right, center, justify, start, end

  // Max lines (truncates text)
  maxLines: 2,

  // What to show when text overflows
  overflow: TextOverflow.ellipsis, // clip, fade, ellipsis, visible

  // Soft wrap (allow line breaks)
  softWrap: true,
)

// Rich Text — multiple styles in one text block
RichText(
  text: TextSpan(
    // Default style for this span
    style: const TextStyle(color: Colors.black, fontSize: 16),
    children: [
      const TextSpan(text: 'Price: '),
      TextSpan(
        text: '\$49.99',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const TextSpan(text: ' (on sale!)'),
    ],
  ),
)

// Selectable text (user can copy it)
SelectableText(
  'This text can be selected and copied',
  style: const TextStyle(fontSize: 16),
)
```

---

## 4.5 Image Widget

```dart
// ─────────────────────────────────────────────────────────────
// ASSET IMAGES — bundled with the app
// (must be declared in pubspec.yaml first!)
// ─────────────────────────────────────────────────────────────
Image.asset(
  'assets/images/logo.png',
  width: 200,
  height: 100,
  fit: BoxFit.contain, // cover, contain, fill, fitWidth, fitHeight, none, scaleDown
)

// ─────────────────────────────────────────────────────────────
// NETWORK IMAGES — loaded from a URL
// ─────────────────────────────────────────────────────────────
Image.network(
  'https://example.com/product.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  // Placeholder while loading
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child; // Loaded!
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
  // Error handling
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.broken_image, size: 64, color: Colors.grey);
  },
)

// ─────────────────────────────────────────────────────────────
// CACHED NETWORK IMAGE (requires cached_network_image package)
// MUCH better for production — caches images on device
// ─────────────────────────────────────────────────────────────
// import 'package:cached_network_image/cached_network_image.dart';
//
// CachedNetworkImage(
//   imageUrl: 'https://example.com/product.jpg',
//   placeholder: (context, url) => const CircularProgressIndicator(),
//   errorWidget: (context, url, error) => const Icon(Icons.error),
//   fit: BoxFit.cover,
// )

// ─────────────────────────────────────────────────────────────
// CIRCLE IMAGE — for avatars
// ─────────────────────────────────────────────────────────────
const CircleAvatar(
  radius: 30,
  backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
  // OR for assets:
  // backgroundImage: AssetImage('assets/images/avatar.png'),
)

// ─────────────────────────────────────────────────────────────
// ROUNDED CORNERS IMAGE using ClipRRect
// ─────────────────────────────────────────────────────────────
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.network(
    'https://example.com/product.jpg',
    width: 120,
    height: 120,
    fit: BoxFit.cover,
  ),
)
```

---

## 4.6 Building a Complete Multi-Section Home Screen

Let's put it all together and build a realistic ShopEase home screen:

```dart
// lib/screens/home_tab.dart — Complete ecommerce home screen

import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Allow the entire screen to scroll
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ─────────────────────────────────────────
          const _SearchSection(),

          // ── Banner Carousel ─────────────────────────────────────
          const _BannerSection(),

          // ── Categories ──────────────────────────────────────────
          const _SectionHeader(title: 'Categories', actionText: 'See all'),
          const _CategoriesSection(),

          // ── Featured Products ────────────────────────────────────
          const _SectionHeader(title: 'Featured', actionText: 'See all'),
          const _FeaturedProductsSection(),

          // Bottom padding for nav bar
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── Search Bar Section ──────────────────────────────────────────────────────

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning! 👋',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Find your products',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Search Icon
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner Section ──────────────────────────────────────────────────────────

class _BannerSection extends StatefulWidget {
  const _BannerSection();

  @override
  State<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<_BannerSection> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<_BannerData> _banners = [
    _BannerData(
      title: 'Summer Sale',
      subtitle: 'Up to 50% off',
      color: const Color(0xFF6C63FF),
    ),
    _BannerData(
      title: 'New Arrivals',
      subtitle: 'Shop the latest',
      color: const Color(0xFFFF6584),
    ),
    _BannerData(
      title: 'Free Shipping',
      subtitle: 'On orders over \$50',
      color: const Color(0xFF43B97F),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose(); // Always dispose controllers!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PageView for swipeable banners
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: banner.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        banner.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: banner.color,
                        ),
                        onPressed: () {},
                        child: const Text('Shop Now'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Dot indicators
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final Color color;
  _BannerData({required this.title, required this.subtitle, required this.color});
}

// ── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionHeader({required this.title, required this.actionText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}

// ── Categories Section ──────────────────────────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  final List<Map<String, dynamic>> _categories = const [
    {'icon': Icons.phone_android, 'label': 'Electronics', 'color': Color(0xFF6C63FF)},
    {'icon': Icons.checkroom, 'label': 'Fashion', 'color': Color(0xFFFF6584)},
    {'icon': Icons.home, 'label': 'Home', 'color': Color(0xFF43B97F)},
    {'icon': Icons.sports_soccer, 'label': 'Sports', 'color': Color(0xFFFFB740)},
    {'icon': Icons.book, 'label': 'Books', 'color': Color(0xFF00BCD4)},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        // Horizontal scroll
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category['label'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Featured Products Section ───────────────────────────────────────────────

class _FeaturedProductsSection extends StatelessWidget {
  const _FeaturedProductsSection();

  @override
  Widget build(BuildContext context) {
    // Grid of product cards
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        // Don't scroll this grid — let the parent SingleChildScrollView scroll
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,       // 2 columns
          crossAxisSpacing: 12,    // Horizontal gap
          mainAxisSpacing: 12,     // Vertical gap
          childAspectRatio: 0.75,  // Width / Height ratio per cell
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const _ProductCard();
        },
      ),
    );
  }
}

// ── Product Card ────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: Colors.grey.shade100,
                width: double.infinity,
                child: const Icon(Icons.image, size: 64, color: Colors.grey),
              ),
            ),
          ),

          // Product info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Name',
                  style: TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '\$29.99',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### ⚠️ Common Mistakes — Session 4

1. **Using `Column` inside a `SingleChildScrollView` without setting `mainAxisSize: MainAxisSize.min`.** The Column tries to be infinitely tall, which conflicts with the scroll view. Also, never put an unbounded `ListView` or `GridView` directly inside a `Column` without setting `shrinkWrap: true` and `physics: NeverScrollableScrollPhysics()`.

2. **Nesting Scaffolds.** Only one `Scaffold` per route. Nesting them causes visual glitches and incorrect Material behavior.

3. **Using `Color(0xRRGGBB)` without the alpha channel.** Color requires 8-digit hex with alpha: `Color(0xFFRRGGBB)` (FF = fully opaque). Using 6 digits makes the color black.

4. **Forgetting `const` on widgets that can be const.** Adding `const` to widgets that don't change avoids unnecessary rebuilds. VS Code and the analyzer will suggest this.

5. **Using `Text` directly inside a `Row`/`Column` that might overflow.** Wrap with `Expanded` or set `overflow: TextOverflow.ellipsis`.

### ✏️ Exercises — Session 4

**Exercise 4.1:** Build a `ProfileScreen` using Scaffold with an AppBar that has a back button (leading: BackButton()) and a "Settings" icon action. The body should show a centered Column with: an avatar image, the user's name in bold, an email in grey, and a bio text.
> *Hint: Use `CircleAvatar` for the avatar, and style Text widgets with different TextStyles.*

**Exercise 4.2:** Create a `ProductDetailScreen` that takes a product name and price as constructor parameters. Display: (1) a large image placeholder at the top, (2) the product name and price, (3) a description paragraph, and (4) an "Add to Cart" button fixed at the bottom using Scaffold's `bottomNavigationBar` property with a Container.
> *Hint: Use `bottomNavigationBar: Container(padding: ..., child: ElevatedButton(...))` for a sticky bottom button.*

**Exercise 4.3:** Build a horizontal scrollable list of colored category chips. Each chip should be a Container with a color and label text. Tap on a chip to see which one is selected (highlight it differently).
> *Hint: Use ListView with `scrollDirection: Axis.horizontal` and track `_selectedIndex` in a StatefulWidget.*

**Exercise 4.4 (Challenge):** Extend the `_BannerSection` from the lecture to auto-scroll every 3 seconds using a `Timer.periodic`. When the user swipes manually, the timer should reset.
> *Hint: Use `_pageController.animateToPage()` inside a Timer callback. Cancel and restart the timer in `onPageChanged`.*

---

# Session 5 – Summary & Common Pitfalls

## 5.1 Top 10 Flutter Setup Pitfalls and How to Fix Them

This session compiles the most common problems developers face when starting with Flutter. Save this as your troubleshooting reference.

---

### Pitfall 1: PATH Not Set Correctly

**Symptom:** Running `flutter` in a terminal gives "command not found" or `flutter : The term 'flutter' is not recognized`.

**Diagnosis:**
```bash
# Check what's in your PATH:
echo $env:Path   # PowerShell
echo $PATH       # bash/zsh
```

**Fix — Windows:**
```powershell
# Check current PATH:
$env:Path -split ';'

# Add Flutter temporarily (current session only):
$env:Path += ";C:\flutter\bin"

# Add permanently via System Properties or:
[Environment]::SetEnvironmentVariable(
  "PATH",
  [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";C:\flutter\bin",
  "Machine"
)
# Then CLOSE AND REOPEN PowerShell
```

**Fix — macOS/Linux:**
```bash
# Find your shell's config file:
# Bash: ~/.bashrc or ~/.bash_profile
# Zsh:  ~/.zshrc
# Fish: ~/.config/fish/config.fish

# Add this line to the appropriate file:
export PATH="$HOME/flutter/bin:$PATH"

# Apply changes:
source ~/.zshrc  # or ~/.bashrc

# Verify:
which flutter
# Should output: /home/user/flutter/bin/flutter
```

---

### Pitfall 2: Gradle Sync Failures on Android

Gradle failures are the most common source of frustration for Flutter beginners. Here are the top causes:

**Symptom A:** `Could not resolve com.android.tools.build:gradle:x.x.x`

```
# Fix: Update Gradle and Android Gradle Plugin versions
# android/build.gradle:
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'  // Update this
    }
}

# android/gradle/wrapper/gradle-wrapper.properties:
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
```

**Symptom B:** `Minimum supported Gradle version is X.X`

```bash
# Fix: Update the Gradle wrapper
# android/gradle/wrapper/gradle-wrapper.properties
# Change distributionUrl to the required version

# Or run:
cd android && ./gradlew wrapper --gradle-version 8.3
```

**Symptom C:** `SDK location not found. Define a valid SDK location`

```bash
# Fix: Create a local.properties file in the android/ directory
# android/local.properties:
sdk.dir=/Users/yourname/Library/Android/sdk        # macOS
sdk.dir=C\:\\Users\\yourname\\AppData\\Local\\Android\\Sdk  # Windows
sdk.dir=/home/yourname/Android/Sdk                  # Linux
```

**Symptom D:** Java/JDK version mismatch

```bash
# Check Java version:
java -version

# Flutter uses its own bundled JDK for Android builds (Flutter 3.10+)
# To use it:
export JAVA_HOME=$(flutter doctor -v | grep "Java binary" | awk '{print $NF}' | sed 's/\/bin\/java//')

# Or set Android Studio's JDK:
# In Android Studio: File > Project Structure > SDK Location > JDK Location
```

**Nuclear option — clear all caches:**
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run
```

---

### Pitfall 3: CocoaPods Issues on iOS (macOS)

**Symptom A:** `CocoaPods not installed` or `pod: command not found`

```bash
# Fix 1: Install via RubyGems
sudo gem install cocoapods

# Fix 2 (Apple Silicon M1/M2/M3): Use Homebrew instead
brew install cocoapods

# Fix 3: If you have both and they conflict:
which pod  # Should point to /usr/local/bin/pod or /opt/homebrew/bin/pod
```

**Symptom B:** `CDN: trunk Repo update failed`

```bash
# Fix: The trunk CDN is sometimes down. Switch to GitHub source:
pod repo remove trunk
pod setup
# Or add this to your Podfile:
# source 'https://github.com/CocoaPods/Specs.git'
```

**Symptom C:** `pod install` fails with Ruby errors on Apple Silicon

```bash
# Fix: Run under Rosetta or use the correct Ruby
arch -x86_64 pod install

# Better fix: Use rbenv to manage Ruby versions
brew install rbenv ruby-build
rbenv install 3.1.0
rbenv global 3.1.0
gem install cocoapods
```

**Symptom D:** `The iOS Simulator SDK is not installed`

```bash
# Fix:
sudo xcode-select --switch /Applications/Xcode.app
sudo xcodebuild -runFirstLaunch

# List available simulators:
xcrun simctl list devices

# Boot a simulator:
xcrun simctl boot "iPhone 15"
open -a Simulator
```

---

### Pitfall 4: Android Emulator is Slow or Won't Start

**Symptoms:** Emulator takes forever to start, freezes, or crashes.

**Fix 1: Enable Hardware Acceleration (HAXM / WHPX on Windows)**

```bash
# Windows: Enable Hyper-V or WHPX in Windows Features
# OR install Intel HAXM from Android Studio:
# SDK Manager → SDK Tools → Intel x86 Emulator Accelerator (HAXM)

# macOS: HAXM is installed automatically with Android Studio

# Linux: Enable KVM
sudo apt-get install qemu-kvm
sudo adduser $USER kvm
# Restart the computer
```

**Fix 2: Allocate More RAM to Emulator**
```bash
# In Android Studio AVD Manager:
# Edit the emulator → Show Advanced Settings
# Set RAM to 2048MB or more
# Set VM heap to 512MB
```

**Fix 3: Use a Physical Device Instead**
```bash
# Enable Developer Options on Android:
# Settings > About Phone > Tap "Build Number" 7 times
# Then: Settings > Developer Options > USB Debugging > ON

# Connect and verify:
flutter devices
# Should show your physical device

flutter run
```

---

### Pitfall 5: `flutter pub get` Fails / Dependency Conflicts

**Symptom:** `Because X depends on Y >=2.0.0 and Z depends on Y <2.0.0, version solving failed.`

```bash
# Fix 1: View the dependency conflict in detail
flutter pub deps

# Fix 2: Upgrade all packages
flutter pub upgrade --major-versions

# Fix 3: Override a conflicting version (use sparingly)
# pubspec.yaml:
dependency_overrides:
  some_conflicting_package: ^2.0.0

# Fix 4: Remove and re-get
flutter clean
flutter pub get

# Fix 5: Use a compatible version
# Check pub.dev for compatible versions between your packages
```

---

### Pitfall 6: `flutter run` Shows "No devices found"

```bash
# List all devices (including not started):
flutter devices

# List emulators:
flutter emulators

# Launch a specific emulator:
flutter emulators --launch Pixel_6_API_34

# Run on a specific device:
flutter run -d <device_id>

# Connect to Chrome for web:
flutter run -d chrome

# If Android device connected but not showing:
adb devices  # Check ADB sees it
adb kill-server && adb start-server  # Restart ADB
flutter devices  # Try again
```

---

### Pitfall 7: Hot Reload Not Working

**Symptoms:** Changes don't appear after pressing `r`, or the app seems stuck.

```bash
# Try Hot Restart instead:
R  # In terminal

# If still stuck, full restart:
q  # Quit
flutter run

# If changes are in initState() or main() — they NEED a hot restart
# Hot reload only works for build() method changes

# Check for compilation errors in the terminal output
# A syntax error prevents hot reload from working
```

---

### Pitfall 8: Wrong Flutter Channel / Outdated SDK

```bash
# Check current channel and version:
flutter channel
flutter --version

# Switch to stable (recommended):
flutter channel stable
flutter upgrade

# If upgrade fails:
git -C $(flutter sdk-path) pull  # Manually pull in the Flutter git repo
flutter pub upgrade

# Verify the upgrade worked:
flutter --version
```

---

### Pitfall 9: Build Fails After Adding a New Package

**Scenario:** You added a package in `pubspec.yaml`, ran `flutter pub get`, but the build still fails.

```bash
# Step 1: Make sure pub get succeeded (no errors in output)
flutter pub get

# Step 2: For packages with native code, you may need a full restart
# (Stop the app and run again — not just hot restart)
flutter run  # Full rebuild

# Step 3: For iOS native packages — re-run pod install
cd ios && pod install && cd ..

# Step 4: If still failing — clean and rebuild from scratch
flutter clean
flutter pub get
flutter run

# Step 5: Check if the package supports your platforms
# Look at the package's pub.dev page for platform support badges
```

---

### Pitfall 10: `setState()` Called After `dispose()`

**Symptom:** `setState() called after dispose()` — a red error on screen.

**This happens when:** An async operation completes after the widget has been removed from the tree.

```dart
// ❌ WRONG — can throw setState() after dispose() error
class BadWidget extends StatefulWidget {
  const BadWidget({super.key});
  @override
  State<BadWidget> createState() => _BadWidgetState();
}

class _BadWidgetState extends State<BadWidget> {
  String _data = '';

  @override
  void initState() {
    super.initState();
    _loadData(); // Fire and forget — dangerous!
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    setState(() { // Widget might be disposed by now!
      _data = 'Loaded';
    });
  }

  @override
  Widget build(BuildContext context) => Text(_data);
}

// ✅ CORRECT — always check mounted
class GoodWidget extends StatefulWidget {
  const GoodWidget({super.key});
  @override
  State<GoodWidget> createState() => _GoodWidgetState();
}

class _GoodWidgetState extends State<GoodWidget> {
  String _data = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    // Check if widget is still in the tree before calling setState
    if (!mounted) return; // ✅ Safe guard
    setState(() {
      _data = 'Loaded';
    });
  }

  @override
  Widget build(BuildContext context) => Text(_data);
}
```

---

## 5.2 Environment Variables and PATH Issues — Deep Dive

```bash
# ─── UNDERSTANDING THE PROBLEM ────────────────────────────────────────────

# When you type 'flutter' in a terminal, the OS searches directories in PATH
# to find the flutter executable. If flutter/bin isn't there → "not found"

# ─── WINDOWS: COMMON PATH MISTAKES ────────────────────────────────────────

# ❌ WRONG: Path with spaces (will not work reliably):
# C:\Program Files\flutter\bin

# ❌ WRONG: Trailing backslash (causes issues on some systems):
# C:\flutter\bin\

# ✅ CORRECT:
# C:\flutter\bin

# Check if flutter is findable:
Get-Command flutter  # PowerShell
where flutter        # Command Prompt

# ─── MULTIPLE FLUTTER INSTALLATIONS ────────────────────────────────────────

# Problem: You have multiple Flutter SDKs installed (e.g., from different tools)
# Solution: Ensure only ONE flutter/bin is in your PATH

# List all flutter executables:
where.exe flutter  # Windows
which -a flutter   # macOS/Linux

# ─── ANDROID HOME PATH ──────────────────────────────────────────────────────

# Required for Android builds. Verify:
flutter doctor -v  # Shows the detected SDK path

# Common correct locations:
# Windows: C:\Users\<YOU>\AppData\Local\Android\Sdk
# macOS:   ~/Library/Android/sdk
# Linux:   ~/Android/Sdk

# Setting ANDROID_HOME in PowerShell permanently:
[System.Environment]::SetEnvironmentVariable(
  "ANDROID_HOME",
  "$env:LOCALAPPDATA\Android\Sdk",
  [System.EnvironmentVariableTarget]::User
)
```

---

## 5.3 Gradle Sync Deep Dive

```
FLUTTER ANDROID BUILD PROCESS:

flutter build apk
       │
       ▼
  Dart compiler (AOT for release, JIT for debug)
       │
       ▼
  Gradle build system
       │
       ▼
  Android Gradle Plugin (AGP)
       │
       ▼
  Android SDK (aapt, d8/r8, apkbuilder)
       │
       ▼
  Output: .apk or .aab
```

**Key version compatibility table:**

| Flutter Version | Gradle Wrapper | Android Gradle Plugin (AGP) | Java |
|----------------|----------------|------------------------------|------|
| 3.10+ | 7.5+ | 7.3+ | 11+ |
| 3.13+ | 7.6+ | 7.4+ | 17 (bundled) |
| 3.16+ | 8.0+ | 8.0+ | 17 (bundled) |
| 3.19+ | 8.3+ | 8.1+ | 17 (bundled) |

**Key Gradle configuration files:**

```groovy
// android/build.gradle — Project-level (controls Gradle plugins)
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ⚠️ This version must match your Gradle wrapper version
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

```groovy
// android/app/build.gradle — App-level (controls your app's build settings)
android {
    namespace 'com.example.myapp'
    compileSdk 34  // API level to compile against (should be latest)

    defaultConfig {
        applicationId 'com.example.myapp'  // Unique app identifier
        minSdk 21       // Minimum Android version (API 21 = Android 5.0)
        targetSdk 34    // Target Android version
        versionCode 1   // Integer, increment for each release
        versionName '1.0.0'  // Human-readable version
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug  // Use real signing for production!
            minifyEnabled true  // Code shrinking with R8
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 5.4 CocoaPods Issues — Deep Dive

```
FLUTTER iOS BUILD PROCESS:

flutter build ios
       │
       ▼
  Dart compiler (AOT)
       │
       ▼
  CocoaPods (pod install)
       │
       ▼
  Xcode Build System (xcodebuild)
       │
       ▼
  Output: .ipa or .app
```

```ruby
# ios/Podfile — Annotated example

# Minimum iOS version (Flutter 3.x requires iOS 12+)
platform :ios, '12.0'

# CocoaPods analytics (disable for privacy)
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(
    File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__
  )
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist."
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Add iOS-specific pods here:
  # pod 'Firebase/Core'
  # pod 'GoogleMaps'

  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # Fix for pods with higher deployment target than the project
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

**Common CocoaPods fix sequence:**

```bash
# Nuclear clean for iOS:
cd ios
rm -rf Pods/
rm -rf .symlinks/
rm Podfile.lock
pod cache clean --all
pod install
cd ..
flutter run
```

---

## 5.5 Module 1 Concept Recap

Let's summarize everything we've covered, organized as a quick-reference diagram:

```
MODULE 1 KNOWLEDGE MAP
═══════════════════════════════════════════════════════════════════

FLUTTER OVERVIEW
├── What it is: Cross-platform UI toolkit by Google (Dart language)
├── History: Sky (2015) → Flutter 1.0 (2018) → Flutter 3.0 (2022)
├── vs React Native: Own rendering engine vs native components + bridge
└── vs Native: One codebase vs two (iOS + Android)

ARCHITECTURE
├── Platform Embedder → Engine (Skia/Impeller + Dart VM) → Framework
├── Widget Tree: Immutable configuration (cheap)
├── Element Tree: Persistent lifecycle managers (stable)
└── Render Tree: Layout + painting (expensive, reused)

SETUP
├── Install Flutter SDK (PATH configuration critical!)
├── Android Studio + Android SDK + Licenses accepted
├── VS Code + Flutter/Dart extension
└── flutter doctor → diagnose all issues

PROJECT STRUCTURE
├── lib/ → your Dart code
├── android/, ios/ → platform files (rarely touch directly)
├── pubspec.yaml → dependencies, assets, fonts
└── main.dart → entry point (main() → runApp())

HOT RELOAD / RESTART
├── Hot Reload (r): Fast, keeps state, only build() changes
├── Hot Restart (R): Resets state, applies initState() changes
└── Full Restart: Native code changes, new packages

WIDGET TYPES
├── StatelessWidget: No internal state, pure function of inputs
└── StatefulWidget: Internal mutable state + lifecycle methods

SCAFFOLD ANATOMY
├── AppBar: Title, actions, leading icon
├── body: Main content
├── drawer: Side navigation
├── floatingActionButton: Primary action button
└── bottomNavigationBar: Tab navigation

BASIC UI WIDGETS
├── Container: Size + padding + margin + decoration
├── Column/Row: Vertical/horizontal layout
├── Text: Content + TextStyle
├── Image.asset() / Image.network(): Display images
└── Padding / Center / SizedBox / Align: Positioning helpers
```

---

# Module Summary

Congratulations on completing Module 1! You've covered an enormous amount of ground. Let's recap the core learning outcomes:

**Session 1 — Flutter Overview & Setup:**
You now understand what Flutter is and why it was created. You can articulate the key architectural difference (own rendering engine) that separates Flutter from React Native and other frameworks. You can install Flutter on any platform and use `flutter doctor` to diagnose and fix environment issues. You understand the three-tree architecture (widget, element, render) and the difference between Skia and Impeller.

**Session 2 — Project Structure & Tooling:**
You know every file in a Flutter project and why it exists. You can configure `pubspec.yaml` like a professional — adding dependencies, assets, and fonts with correct version constraints. You understand build environments and can use `--dart-define` to configure your app for dev/staging/production. You have a complete reference for the Flutter CLI.

**Session 3 — Hot Reload & Widget Tree:**
You understand the three reload modes and when to use each one — this knowledge directly translates to a faster development workflow. You understand the StatelessWidget vs StatefulWidget distinction and the complete StatefulWidget lifecycle. You can use Flutter DevTools to inspect the widget tree and diagnose performance issues.

**Session 4 — Basic UI Composition:**
You can build complete, professional-looking screens using MaterialApp, Scaffold, and the core layout widgets. You understand TextStyle, BoxDecoration, EdgeInsets, and how to compose complex UIs from simple building blocks. You built a full multi-section home screen with a PageView banner, horizontal categories list, and a product grid.

**Session 5 — Pitfalls & Troubleshooting:**
You have a battle-tested reference for the top 10 setup pitfalls. You understand the Android Gradle build pipeline and how to fix common Gradle failures. You understand the iOS CocoaPods system and can perform a complete clean rebuild. You know how to handle async widget state safely with the `mounted` check.

---

# Review Questions

Use these questions to test your understanding. Try to answer without looking back at the notes first.

### Conceptual Questions

**Q1.** Explain in your own words why Flutter doesn't use native platform UI components (like Android Views or UIKit components). What advantage does this provide? What (if any) disadvantage does this create?

**Q2.** What are the three trees Flutter maintains at runtime? What is the purpose of each tree, and which one is cheapest to recreate?

**Q3.** You have a widget where you need to load data from an API when the screen opens, and update the UI when it's done. Should this be a StatelessWidget or StatefulWidget? Which lifecycle method would you use to initiate the API call?

**Q4.** A teammate says: "I made a change to `initState()` and pressed hot reload but nothing changed!" How do you explain this and what should they do instead?

**Q5.** What is the difference between `hot reload`, `hot restart`, and a `full restart`? Give a specific scenario where each is the appropriate choice.

**Q6.** Explain why `WidgetsFlutterBinding.ensureInitialized()` is needed in `main()` when `main()` is async. What happens if you forget it?

**Q7.** What does the `mounted` property check in a StatefulWidget, and why is it important to check it before calling `setState()` after an `await`?

**Q8.** In `pubspec.yaml`, what is the difference between a `dependency` and a `dev_dependency`? Give two examples of packages that should be `dev_dependencies`.

**Q9.** What is Impeller and why was it created to replace Skia? What specific problem does it solve?

**Q10.** A user reports that the app crashes on Android with "Minimum supported Gradle version is 7.5, but was 7.2." What file do you edit to fix this, and what specifically do you change?

### Practical Questions

**Q11.** Write the `pubspec.yaml` entry to include a custom font family called "Inter" with Regular (400) and Bold (700) weights from the `assets/fonts/` directory.

**Q12.** Write a `StatefulWidget` called `ToggleSwitch` that renders a Switch widget (Material switch). It should start in the off position, toggle on tap, and print `'Switch is ON'` or `'Switch is OFF'` to the debug console when toggled.

**Q13.** What is wrong with the following code? Fix it:
```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      ListView(
        children: [Text('A'), Text('B'), Text('C')],
      ),
    ],
  );
}
```

**Q14.** You want to display a product image from the URL `https://example.com/product.jpg` with rounded corners (12px radius), 200px wide and 200px tall. Write the Flutter code to do this.

**Q15.** Write the complete `main()` function for a production Flutter app that: (a) calls `WidgetsFlutterBinding.ensureInitialized()`, (b) restricts the app to portrait mode, (c) sets the status bar to be transparent with dark icons, and (d) calls `runApp()`.

### Fill-in-the-Blank

**Q16.** To keep state in a `StatefulWidget` after a `hot ______`, but lose it after a `hot ______`.

**Q17.** The `______` method is called once when a `StatefulWidget` is first inserted into the tree, and the `______` method is called when it's permanently removed.

**Q18.** In `pubspec.yaml`, the version `^3.0.0` means "at least 3.0.0 and less than ______".

**Q19.** To add outer spacing around a widget, you use `______`. To add inner spacing inside a container, you use `______`.

**Q20.** `flutter doctor ______` will accept all Android SDK licenses in one go.

---

*End of Module 1 — Introduction to Flutter (Sessions 1–5)*

---

> **📚 Coming Up in Module 2:** Dart Language Fundamentals — Variables, Types, Functions, Classes, Mixins, Generics, Async/Await, Streams. We'll build a deep foundation in Dart so you can write professional-quality Flutter code.

> **📁 Module Files:** All code samples from this module are available in the `examples/module-01/` directory of the course repository.
