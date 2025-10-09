# Repository Guidelines

## Project Structure & Module Organization
Prism is a SwiftUI macOS menu bar app. `Prism/App/` hosts the entry point, `ViewModels/` owns state, `Views/` + `Views/Components/` render UI, and `Services/` encapsulates sandbox + config access to `.claude/settings.json`. Shared types live in `Models/`; styling helpers stay in `Extensions/`. Assets sit under `Resources/Assets.xcassets`, and localization data resides in `Localizable.xcstrings`. Open `Prism.xcodeproj` for the `Prism` and `Prism-CN` schemes.

## Build, Test, and Development Commands
- `open Prism.xcodeproj` — opens the project in Xcode.
- `xcodebuild -scheme Prism -configuration Debug build` — builds the default menu bar app.
- `xcodebuild -scheme Prism -configuration Debug test -destination 'platform=macOS'` — runs XCTest when the `PrismTests` target is available.
- `xcodebuild -scheme Prism-CN -configuration Release archive -archivePath build/PrismCN.xcarchive` — archives the China-specific flavor.

## Coding Style & Naming Conventions
Stick to Swift 5.9 defaults: four-space indentation, trailing commas for multiline values, and `MARK:` separators (`// MARK: - Provider Actions`). Keep types `UpperCamelCase`, members `lowerCamelCase`, and make enums singular (`case main`). Prefer `@Observable` over manual publishers. Keep logs short—emoji are fine when clarifying state. Wrap UI strings with `String(localized:)` and update `Localizable.xcstrings` in Xcode.

## Testing Guidelines
Place unit tests in `PrismTests/` with filenames mirroring the type (`ConfigManagerTests.swift`). Name methods `test_<behavior>()` and focus on sandbox edge cases, provider activation flows, and config mutations. Run `xcodebuild ... test` locally; only add fixtures under `Resources/TestData/` when complex configs demand it.

## Commit & Pull Request Guidelines
Use Conventional Commits as `type(scope): summary` with an imperative subject ≤ 72 chars; scope is optional but useful (`feat(services): …`, `fix(ui): …`). Supported types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. Keep scopes lower-case and align them with folders (`services`, `viewmodels`, `views`, `build`).

When more detail is needed, insert a blank line after the subject and add brief paragraphs or bullets about rationale and tests. Avoid literal `\n`; use the editor or multiple `-m` flags for multi-line messages.

PRs must explain the change, cite manual/automated tests, link issues, and include UI screenshots when visuals shift. Highlight new localization keys, migrations, or permission flows so reviewers understand follow-up actions.

## Security & Configuration Tips
Never manipulate `.claude/settings.json` directly; go through `SandboxAccessManager.withSecureAccess` to keep security-scoped bookmarks valid. If you must reset permissions, call `SandboxAccessManager.clearBookmark()` and re-request access via the permission window. Treat tokens as secrets—mask them in logs and avoid checking real values into fixtures.
