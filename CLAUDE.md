# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# List available schemes/targets
xcodebuild -project StickyBloom.xcodeproj -list

# Build (Debug)
xcodebuild -project StickyBloom.xcodeproj -scheme StickyBloom -configuration Debug build

# Build (Release)
xcodebuild -project StickyBloom.xcodeproj -scheme StickyBloom -configuration Release build

# Regenerate Xcode project from project.yml
python3 generate_xcodeproj.py
```

There are no unit tests in this project.

## Architecture

The app is a macOS SwiftUI/AppKit hybrid (macOS 13.0+) using MVVM + service-oriented architecture.

### Central State Flow

```
AppDelegate
    └── AppState (ObservableObject, Combine @Published)
            ├── auto-save via 500ms debounce → PersistenceService → ~/Library/Application Support/StickyBloom/{stickies,dashboard}.json
            └── WindowManager (singleton) ← reads AppState, manages all NSWindow/NSPanel lifecycle
```

### Window Architecture

All windows are borderless `NSPanel` subclasses with full-size content views:
- **StickyPanel** — `.nonactivatingPanel` style, so sticky notes don't steal focus from other apps
- **DashboardPanel** — standard panel, movable by background
- **StickyWindowController** — persists frame (position + size) back to `StickyNoteModel` on every move/resize via `NSWindow` notifications
- **WindowManager** — singleton accessed everywhere; maps UUID → `StickyWindowController`

### Rich Text Editor Stack

```
RichTextEditor (NSViewRepresentable)
    └── NSScrollView → MentionAwareTextView (custom NSTextView)
            └── RichTextCoordinator (NSTextViewDelegate + NSTextStorageDelegate)
                    ├── detects @mentions via regex, applies blue underline styling
                    ├── manages MentionPopoverView (autocomplete, top 8 matches)
                    └── stores MentionLink (UUID + text range) in StickyNoteModel
```

Content is stored as RTF `Data` in `StickyNoteModel.contentData` and serialized via `AttributedString+RTF.swift`.

### @Mention System

- Pattern: `@([A-Za-z0-9 _\-]{1,50})` — case-insensitive title matching
- Clicking a mention in `MentionAwareTextView` opens the referenced sticky
- `MentionParser.swift` handles regex detection; `MentionPopoverView.swift` renders the autocomplete dropdown

### Plant Animation

`PlantShape.swift` defines 5 growth stages (seedling → bloomed) using Bezier path interpolation. `PlantAnimationView.swift` on the dashboard drives the animation and determines the current stage from `AppState`.

## Key Directories

| Path | Purpose |
|------|---------|
| `StickyBloom/App/` | `@main` app struct + `AppDelegate` |
| `StickyBloom/Models/` | `AppState`, `StickyNoteModel`, `DashboardSettingsModel`, `MentionLink` |
| `StickyBloom/Services/` | `WindowManager`, `PersistenceService`, `LocationService` |
| `StickyBloom/StickyNote/` | All sticky note UI (view, window controller, panel, toolbar, rich text) |
| `StickyBloom/Dashboard/` | Dashboard panel, clock, plant view, settings, timezone picker |
| `StickyBloom/Linking/` | @mention parser and autocomplete popover |
| `StickyBloom/PlantAnimation/` | `PlantShape` Bezier growth stages |
| `StickyBloom/Utilities/` | Extensions: `NSColor+Hex`, `TimeZone+Display`, `AttributedString+RTF` |

## Project Generation

`project.yml` is the source of truth for the Xcode project configuration (targets, files, build settings). Run `python3 generate_xcodeproj.py` after modifying `project.yml` to regenerate `StickyBloom.xcodeproj`.
