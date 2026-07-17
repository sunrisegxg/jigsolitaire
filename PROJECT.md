# Jigsolitaire Project Overview

## Project purpose

Jigsolitaire is a Flutter puzzle game that combines a jigsaw image with solitaire-style card dealing and group movement. A campaign presents 25 levels at a time. The player starts the current unlocked level, watches its shuffled image pieces deal and flip, then drags pieces (or already-connected groups) around the board until every piece returns to its original position. Completing the current campaign level awards coins and advances persistent progress.

The repository is an in-progress game prototype rather than a production-ready release. Campaign play, persistence, audiovisual settings, completion effects, a collection screen, and a Master Challenge screen are present. Daily Challenge, purchasing/unlocking Master levels, help, cloud progress, and notifications are placeholders or UI-only. See [Current limitations](#current-limitations-and-known-issues).

## Technology and supported targets

- Flutter application, package name `jigsolitaire`, version `1.0.0+1`.
- Dart SDK constraint: `^3.10.0`.
- Material UI with `google_fonts` (Poppins is used throughout the home UI).
- BLoC state management via `flutter_bloc`.
- Local persistence via `shared_preferences`.
- Background music via `just_audio` and `audio_session`.
- Click effects via `flutter_soloud`; vibration via `vibration`.
- Completion particles via `flutter_confetti`.
- Flutter runner projects exist for Android, iOS, web, Windows, macOS, and Linux.

No backend, account system, network API, database, analytics, or environment-specific secret configuration is implemented. All gameplay content is bundled as local assets.

## Main features

### Campaign and progression

- The campaign catalog is built from Flutter's asset manifest at startup. Numbered campaign, collection, and Master images become content without editing UI code; campaign availability stops at the first missing sequential level.
- The home screen displays the active collection as a fixed 5 x 5 grid. Completed cards reveal aligned slices of the collection image; incomplete cards retain their backs.
- Completed campaign cards can be replayed after confirmation. Explicit replay sessions never grant coins or change progress.
- `GameProgress` stores sequential campaign progress, a shared coin balance, purchased Master IDs, and completed Master IDs in the versioned `game_progress.v2` aggregate. Legacy level/coin keys migrate automatically.
- Each campaign page contains 25 levels. Hard-level positions are 10, 20, and 25 on page 1; 8, 16, 24, and 25 on page 2; and every fifth position on later pages.
- The current implementation assigns both Normal and Hard modes a 2 x 2 board. Their configured rewards differ: 16 and 36 coins respectively.
- At the end of the contiguous campaign assets, Home displays an all-available-levels-completed state and cannot construct a route past a missing level.

### Puzzle gameplay

- A board is created with one piece per image segment, shuffled, reindexed, and immediately grouped where shuffled neighbors already have the correct original relationship.
- The board is dealt piece by piece with card-back and flip animations before interaction is enabled.
- Dragging a connected group translates the whole group. Moves that would leave the board are rejected. Pieces displaced by the group fill the positions it vacated.
- After a valid move, adjacent pieces with correct original relationships are merged using a union-find grouping algorithm and newly merged groups pulse.
- A puzzle is complete when every piece ID equals its current board index.
- Reset reshuffles the same level and preserves its level configuration.
- A root gesture recognizer suppresses additional simultaneous pointers, making gameplay effectively single-touch.

### Completion and rewards

- Completion shows a level-clear banner, confetti, a reward panel, animated flying coins, and a pulsing wallet.
- Pressing Next completes the coin animation, waits for persistence, and returns a typed result to the calling screen.
- Reward sizes configured by campaign mode are Normal 16 and Hard 36. Master progress and all replay sessions grant zero coins.

### Settings and interaction feedback

- Music, sound effects, vibration, and a notification preference default to enabled and persist under `settings_*` keys.
- Music loops `assets/audio/background.mp3`; taps can play `assets/audio/click.mp3` and vibrate for 50 ms.
- The global settings dialog exposes all four toggles. Notification scheduling is not implemented; the notification toggle only persists a preference.
- Help Center and Save your progress controls currently trigger feedback but have no associated workflow.
- The in-game dialog provides Home and Restart actions plus the same setting controls.

### Secondary screens

- Collection is a catalog-driven, progress-aware gallery with locked, in-progress, completed, and coming-soon states. Completed images open in a read-only full-screen preview.
- Master Challenge exposes 12 configured levels. Its grid size comes from `PuzzleMode.masterChallenge`, alongside the Normal, Hard, and Daily grid sizes. Levels cost 1,000 coins by default, unlock sequentially, persist purchase/completion state, and remain replayable without rewards.
- Daily Challenge currently opens a Coming Soon dialog. Calendar/dialog code exists under `features/home`, but it is not connected to the active bottom bar.

## Architecture

The Dart code uses a feature-first structure with Clean Architecture-inspired presentation, domain, and data layers. The separation is strongest in Puzzle, Settings, and Game Progress; Home, Collection, and Challenge are primarily presentation prototypes.

```text
main.dart
  -> initializes audio/interaction services and the global BLoC observer
  -> OnlyOnePointerRecognizerWidget
  -> App
       -> global InteractionService repository provider
       -> global SettingsBloc and GameProgressBloc
       -> HomePage / feature-local HomeBloc
            -> PuzzleGamePage / feature-local PuzzleBloc
```

`InjectionContainer` is a manual service locator and factory, not a generated dependency-injection system. Audio, sound, and vibration are singleton services. Repositories are long-lived static instances. Each Home or Puzzle route gets a newly created BLoC.

### Puzzle data flow

1. `PuzzleLevelConfigService` derives mode, grid size, reward, pagination metadata, and asset path.
2. `PuzzleGamePage` precaches the image and sends `PuzzleStarted`.
3. `PuzzleBloc` calls use cases backed by `PuzzleEngine` and emits loading, dealing, flipping, playing, and completed phases.
4. Domain services shuffle pieces, apply group moves, recompute groups, and test completion.
5. Presentation widgets render slices of the configured image and translate BLoC state into drag, flip, swap, pulse, snap-back, and completion animations.
6. On completion, `GameProgressBloc` validates the sequential level and persists progress and coins.

### State ownership

- `SettingsBloc`: persistent preferences and music start/stop side effects.
- `GameProgressBloc`: authoritative campaign completion count, shared coins, Master purchases/completions, and serialized persistence operations.
- `PuzzleBloc`: one puzzle session and its animation/gameplay phases.
- `HomeBloc`: derives catalog-aware Home progress from `GameProgressBloc` and coordinates collection-flight, interaction-lock, collection-switch, and staggered dealing phases.
- `CollectionBloc`: derives locked, in-progress, completed, and coming-soon gallery entries from the catalog and persistent progress.
- `MasterChallengeBloc`: derives sequential Master card states and coordinates purchase locking, persistence outcomes, dialogs, and typed puzzle navigation commands.
- Stateful presentation widgets own short-lived animation controllers and completion-display counters.

## Folder structure

```text
assets/
  audio/                         Background music and click effect
  images/                        Home, card, settings, collection, challenge assets
    puzzles/campaign/            Numbered campaign level images (currently 1-34)
  level_clear_banner.png
  puzzle_image.jpg               Fallback/default puzzle image constant
lib/
  main.dart                      Startup, global BLoC observer
  app.dart                       Root providers and MaterialApp
  injection_container.dart       Manual composition root
  only_one_point_widget.dart     Multi-pointer suppression recognizer
  core/
    constants/                   Gameplay timing, dimensions, colors, fallback assets
    services/                    Music, sound, vibration, combined tap feedback
    utils/                       Generic shuffle helper
    widgets/                     Shared button (currently unused by main flows)
  features/
    puzzle/
      domain/entities/           Board, pieces, positions, modes, level config
      domain/services/           Engine, movement, shuffle, grouping, config mapping
      domain/usecases/           Start, reset, move, completion check
      presentation/bloc/         Puzzle session state machine
      presentation/pages/        Route setup and game screen
      presentation/widgets/      Board, pieces, app bar, settings, reward effects
    game_progress/               Persistent progress repository, entity, and BLoC
    settings/                    Persistent/in-memory repositories, entity, BLoC, UI
    home/                        Campaign home, calendar prototype, navigation
    collection/                  Hard-coded collection prototype
    challenge/                   Hard-coded Master Challenge prototype
test/
  widget_test.dart               Stale generated counter test (currently invalid)
android/, ios/, web/, windows/,
macos/, linux/                   Standard Flutter platform runner projects
```

Generated plugin registrants inside platform folders should be regenerated by Flutter rather than manually edited.

## Setup

### Prerequisites

1. Install a Flutter SDK whose bundled Dart satisfies `^3.10.0`.
2. Run `flutter doctor` and install the toolchain for the desired target (Android Studio/SDK, Xcode on macOS, a supported browser, Visual Studio Desktop C++ for Windows, or Linux desktop dependencies).
3. From the repository root, fetch packages:

```sh
flutter pub get
```

Before attempting web, iOS, or macOS builds, resolve the merge conflicts described below. With the repository in its present state, those targets are not valid release candidates.

### Run locally

List available targets and run one:

```sh
flutter devices
flutter run -d <device-id>
```

The app has no command-line arguments, flavors, `.env` file, or runtime server configuration. On first launch, progress starts at level 1 with zero coins, and all settings default to enabled.

## Configuration and content changes

### Gameplay

- Adjust animation timings, the fallback puzzle image, board aspect ratio, and background color in `lib/core/constants/app_constants.dart`.
- Change mode grid sizes and rewards in `lib/features/puzzle/domain/entities/puzzle_mode.dart`.
- Change campaign paging, hard-level distribution, or image naming in `lib/features/puzzle/domain/services/puzzle_level_config_service.dart`.

When adding a campaign level, add its numbered JPG to `assets/images/puzzles/campaign/`. That directory is already declared in `pubspec.yaml`; no individual asset entry is needed.

### Persistence

Settings and progress are device-local SharedPreferences values. Progress uses a versioned JSON aggregate under `game_progress.v2`; the previous completed-level and coin keys are retained as migration inputs. `MemorySettingsRepository` exists for transient use but is not selected by the production composition root.

### Platform identity and release metadata

- Package version comes from `pubspec.yaml` and can be overridden with Flutter's `--build-name` and `--build-number` flags.
- Android currently uses `com.example.jigsolitaire` for both namespace and application ID.
- iOS/macOS project files contain conflicting `com.example.jigsolitaire` and `com.example.test` variants that must be resolved.
- Web metadata also contains conflicting `jigsolitaire` and `test` names.
- Replace example identifiers, titles/descriptions, icons as needed, and configure production signing before publishing.

## Usage

1. Launch the app; music starts automatically when its saved setting is enabled.
2. Use the top-left card icon for Collection and the top-right icon for Settings.
3. Press PLAY to open the current campaign level.
4. After dealing/flipping finishes, drag a tile or connected group onto another board position. Correct neighboring segments merge and move as one thereafter.
5. Use the game settings button to return Home or restart. The separate lower settings-shaped button directly restarts the puzzle in the current UI.
6. On completion, wait for the reward UI and press Next to credit coins, save progress, and return Home.

## Testing and quality checks

The intended local checks are:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

At present, `test/widget_test.dart` is the untouched Flutter counter template: it imports a nonexistent `MyApp`, expects counter text, and therefore does not compile against this application. There are no working unit, widget, integration, golden, or gameplay tests. In particular, the puzzle movement/grouping engine and persistence rules currently lack automated regression coverage.

Recommended first tests are deterministic `PuzzleShuffleService` tests with an injected `Random`, domain tests for group displacement/out-of-bounds moves and union-find merges, BLoC tests for phase/reward rules, repository tests for persistence keys, and widget tests for the Home-to-Puzzle flow.

The repository has no CI workflow or automated release checks.

## Build and deployment

After resolving the current source/project issues and validating a target, standard Flutter commands apply:

```sh
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
flutter build web --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

Deployment is not automated. Publish the generated artifact using the target platform's normal store or hosting process. Additional production work is required:

- Android release currently uses the debug signing configuration; create a protected release keystore and signing configuration.
- Resolve all merge markers, settle final bundle/application IDs, and configure Apple signing/team/capabilities.
- Choose final web name/metadata and deploy `build/web` to static hosting, setting `--base-href` when hosted below a domain root.
- Confirm audio, vibration, and SharedPreferences plugin behavior on every claimed target; these capabilities are platform-dependent.
- Add store metadata, privacy disclosures, release icons/splash assets, versioning policy, and CI/CD as appropriate.

## Important technical decisions

- **Feature-first layering:** game rules live outside widgets, allowing the puzzle engine to be tested independently once tests are added.
- **BLoC-driven gameplay phases:** interaction is disabled during deal, flip, move, pulse, and completion transitions, reducing overlapping operations.
- **Group identity from original adjacency:** connected components are recalculated from correct right/bottom neighbors using union-find rather than maintained through ad-hoc UI state.
- **Group translation with displacement:** a move is not a simple two-tile swap; the group keeps its shape and displaced pieces fill its vacated cells.
- **Sequential progress invariant:** persistent rewards only accept the next uncompleted campaign level, preventing duplicate/out-of-order coin grants.
- **Local-first persistence:** SharedPreferences keeps the prototype self-contained, at the cost of no cloud sync, authentication, transactional storage, or schema migrations.
- **Manual dependency composition:** `InjectionContainer` keeps setup explicit and small, but relies on static lifetime management and does not dispose global audio services during normal app shutdown.
- **Asset-driven content:** campaign expansion is simple, but the numeric filename convention is a runtime contract and there is no manifest-based validation.

## Current limitations and known issues

- Unresolved Git merge markers are present in `web/index.html`, `web/manifest.json`, and Apple Xcode project configuration. They can prevent parsing/building and leave application identity ambiguous.
- The only test is stale and invalid; `flutter test` is expected to fail until it is replaced.
- Only campaign images 1-34 are bundled. Collection 2 therefore remains in progress and the catalog prevents launching later levels.
- Daily Challenge is Coming Soon; its existing calendar/dialog code is disconnected.
- Campaign collection images currently use mixed source aspect ratios; Home applies one consistent whole-grid center crop so its 25 slices remain aligned.
- Help Center, Save your progress, and notification functionality are not implemented beyond UI/feedback or a stored toggle.
- Normal, Hard, Daily, and Master grid sizes are configured centrally by `PuzzleMode.gridSize`.
- No error UI is wired for settings/progress loading failures, and missing campaign assets are not recovered with an alternate level.
- Debug logging includes all BLoC changes and a few direct `print` calls.
- There is no localization, accessibility audit, save synchronization, telemetry, crash reporting, CI, or automated deployment.
