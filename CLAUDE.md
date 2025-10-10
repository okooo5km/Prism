# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Prism is a macOS 14.0+ menu bar application for switching Claude Code API providers with one click. It modifies `~/.claude/settings.json` to switch between different API endpoints (e.g., Anthropic Official, Zhipu AI, z.ai, Moonshot AI) while preserving all other configuration.

## Build Commands

```bash
# Build the project
xcodebuild -project Prism.xcodeproj -scheme Prism -configuration Debug build

# Check for build errors only
xcodebuild -project Prism.xcodeproj -scheme Prism -configuration Debug build 2>&1 | grep -E "(error:|warning:|Build succeeded)"
```

## Architecture

### Core Responsibility: Only Modify `env` Key

**Critical**: ConfigManager must ONLY modify the `env` key in `~/.claude/settings.json`. All other keys in the settings file must remain untouched. The `ClaudeConfig` struct intentionally only includes the `env` field.

### Data Flow

1. **App Launch** → `AppDelegate.applicationDidFinishLaunching`
   - Uses `MenuBarExtra` (not custom NSPopover) with `.window` style
   - `ConfigImportService.shared.syncConfigurationOnStartup()` performs three-phase validation (delayed 0.5s):
     - Phase 1: Check activeProviderID, validate token consistency
     - Phase 2: If inconsistent, match token across all providers
     - Phase 3: If no match, create new provider from template
   - ConfigManager automatically creates `~/.claude/settings.json` if it doesn't exist

2. **Menu Opens** → `ContentView.onAppear`
   - `ConfigImportService.shared.syncConfigurationState()` detects external config changes
   - Updates activation state if config file was modified outside the app

3. **User Interaction** → `ContentView` with `ContentViewModel`
   - Shows "Default" row + user-added providers
   - User clicks provider row → `ContentViewModel.activateProvider()` → `ProviderStore.activateProvider()` → saves activeProviderID → `ConfigManager.updateEnvVariables()`
   - User adds provider → No auto-activation, no config file update (only saves data)
   - User edits non-active provider → Only updates data, no config file update
   - User edits active provider → Updates data AND syncs to config file immediately
   - User deletes active provider → Restores "Default" and clears config file
   - Navigation state managed by `ContentViewModel.currentView` enum (.main/.add/.edit)

4. **Token Validation** → `AddEditProviderView`
   - Before saving, checks token duplication via `ProviderStore.checkTokenDuplicate()`
   - Distinguishes between same-URL and different-URL duplicates
   - Shows warning Alert, allows user to proceed or cancel

5. **Data Persistence**
   - User providers: `ProviderStore` → UserDefaults (key: "saved_providers")
   - Active provider ID: `ProviderStore` → UserDefaults (key: "active_provider_id")
   - Claude Code config: `ConfigManager` → `~/.claude/settings.json` (only `env` key)

### Configuration File Management

**ConfigManager** directly accesses `~/.claude/settings.json` without sandbox restrictions:

1. **Automatic Initialization**:
   - Checks if `~/.claude` directory exists, creates it if needed
   - Checks if `settings.json` exists, creates empty JSON file if needed
   - Called automatically on every read/write operation via `ensureConfigExists()`

2. **Backup Strategy**:
   - Creates `.backup` file before every write operation
   - Restores from backup if write operation fails
   - Ensures data safety during configuration updates

### State Management with @Observable

**Critical Pattern**: `ProviderStore` uses macOS 14.0+ `@Observable` macro with proper UserDefaults integration:

```swift
var providers: [Provider] {
    get {
        access(keyPath: \.providers)  // Required for @Observable
        // ... load from UserDefaults
    }
    set {
        withMutation(keyPath: \.providers) {  // Required for @Observable
            // ... save to UserDefaults
        }
    }
}
```

**Do NOT use**: Traditional `didSet` pattern - it won't trigger SwiftUI updates with @Observable.

### Provider Identity and Icon Management

`Provider.id` must be encoded/decoded in Codable implementation. Each Provider has:
- `id: UUID` - Must persist across app launches (explicitly encoded/decoded)
- `name: String` - User-customizable, no automatic renaming
- `icon: String` - Asset name (ClaudeLogo, ZhipuLogo, ZaiLogo, MoonshotLogo, OtherLogo)
- `envVariables: [String: String]` - Contains 5 keys: ANTHROPIC_BASE_URL, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_DEFAULT_HAIKU_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, ANTHROPIC_DEFAULT_OPUS_MODEL
- `isActive: Bool` - Only one provider can be active at a time

**Icon Inference**: Icons are inferred from BASE_URL using `ProviderStore.inferIcon()`:
- `bigmodel.cn` → ZhipuLogo
- `z.ai` → ZaiLogo
- `moonshot.cn` → MoonshotLogo
- `anthropic.com` → ClaudeLogo
- Others → OtherLogo

**Do NOT** use provider name to determine icon or provider type. Always use BASE_URL pattern matching.

### Provider Management Logic

**Active Provider Tracking**: The app persists `activeProviderID` (UUID string) in UserDefaults to track which provider is currently selected.

**Configuration Synchronization Strategy**:

1. **App Startup Sync** (`syncConfigurationOnStartup`):
   - Phase 1: Verify activeProviderID matches config file token
   - Phase 2: If mismatch, search all providers for matching token
   - Phase 3: If no match, create new provider from template matching config

2. **Menu Open Sync** (`syncConfigurationState`):
   - Detect external config file changes (e.g., manual edits, Claude Code updates)
   - Match config token against all providers
   - Update activation state or create new provider if needed

**Provider Operations**:

- **Add Provider**: Only saves data to UserDefaults, does NOT activate or update config file
- **Edit Non-Active Provider**: Only updates local data
- **Edit Active Provider**: Updates data AND immediately syncs to config file (user expects changes to take effect)
- **Switch Provider**: Updates activeProviderID and config file
- **Delete Active Provider**: Restores "Default" (clears config env variables)
- **Delete Non-Active Provider**: Only removes from local data

**Token Duplication Check** (`ProviderStore.checkTokenDuplicate`):

Returns `TokenCheckResult` enum:
- `.unique` - No duplicate found
- `.duplicateWithSameURL(Provider)` - Same token + same URL (likely error)
- `.duplicateWithDifferentURL(Provider)` - Same token + different URL (might be intentional for multi-endpoint setups)

UI shows appropriate warnings and allows user to proceed or cancel.

### Navigation Pattern (Not Sheet-Based)

The app uses custom navigation with `ContentViewModel.currentView`:

```swift
enum AppView {
    case main
    case add
    case edit(Provider)
}
```

When editing, `AddEditProviderView` receives a `Provider` and must preserve its `id`, `isActive`, and `icon` properties:

```swift
// Editing: preserve id, isActive, and icon
Provider(
    id: existingProvider.id,
    name: newName,
    envVariables: newEnvVariables,
    icon: existingProvider.icon,
    isActive: existingProvider.isActive
)
```

**Critical**: Provider has two init methods:
1. `init(name:envVariables:icon:isActive:)` - Creates new UUID (for adding)
2. `init(id:name:envVariables:icon:isActive:)` - Preserves UUID (for editing)

### Default Provider Logic

The "Default" row is always shown at the top. It's considered active when:
- Claude Code config has no `ANTHROPIC_BASE_URL` OR
- Claude Code config has no `ANTHROPIC_AUTH_TOKEN`

This is checked via `ContentViewModel.isDefaultActive` computed property.

## JSON Encoding Requirements

When writing to `~/.claude/settings.json`, use:

```swift
encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
```

This prevents unwanted `\/` escaping in URLs.

## Configuration Import Logic

At app launch, `ConfigImportService` checks existing Claude Code config:
1. If `ANTHROPIC_BASE_URL` matches a template (e.g., Zhipu AI's `https://open.bigmodel.cn/api/anthropic`), auto-import with template name and icon
2. If URL doesn't match any template, auto-import as "Other" with OtherLogo
3. If provider already exists (matching both URL and token), activate it instead of duplicating

Template matching includes validation beyond URL matching (e.g., token format checks for Zhipu AI).

**No Data Migration**: The app does NOT migrate or rename existing provider data. User-defined names and icons are preserved as-is.

## File Authorship

When creating new files, use author signature: `okooo5km(十里)`

## Adding New Provider Templates

To add a new provider template:

1. Add logo SVG to `Prism/Assets.xcassets/` with "template" rendering intent

2. Add to `ProviderTemplate.allTemplates` in Models.swift:
```swift
static let newProvider = ProviderTemplate(
    name: "Provider Name",
    envVariables: [
        "ANTHROPIC_BASE_URL": "https://...",
        "ANTHROPIC_AUTH_TOKEN": "",
        "ANTHROPIC_DEFAULT_HAIKU_MODEL": "model-name",
        "ANTHROPIC_DEFAULT_SONNET_MODEL": "model-name",
        "ANTHROPIC_DEFAULT_OPUS_MODEL": "model-name"
    ],
    icon: "NewProviderLogo"
)
```

3. Add URL pattern to `ProviderStore.inferIcon()` for automatic icon detection

4. (Optional) Add validation logic in `ConfigImportService.isValidProviderForTemplate()` if the provider requires special token format or URL pattern validation.

## UI Components

### DetailCardView Pattern

Form fields use custom card-based components:
- `DetailTextFieldCardView` - Standard text input with icon and label
- `DetailSecureFieldCardView` - Secure password input with icon and label

Each `EnvKey` enum case must provide:
- `displayName: String` - Human-readable label
- `systemImage: String` - SF Symbol icon name
- `placeholder: String` - Placeholder text

### Picker with Asset Images

When using Picker with custom images, use `Label` (not `HStack`):
```swift
Label {
    Text(template.name)
} icon: {
    Image(template.icon)
        .resizable()
        .aspectRatio(contentMode: .fit)
}
```

macOS Picker menu items don't support arbitrary View layouts.