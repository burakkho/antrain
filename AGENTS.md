# Repository Guidelines

## Project Structure & Module Organization
- `antrain/` hosts the main iOS target. `App/` wires `AppDependencies` and scene flows, `Core/` carries domain/data layers (SwiftData models, repositories, services), `Features/<FeatureName>/` bundles Views, ViewModels, and components per Clean Architecture, and `Shared/` exposes reusable UI plus design tokens. Keep assets, strings, and CSV seeds under `Resources/` and `Assets.xcassets`.
- `AntrainWidget/` contains the WidgetKit + Live Activities extension; reuse shared DTOs via `WidgetDataHelper`.
- `docs/` is canonical documentation (`ARCHITECTURE.md`, `MODELS.md`, sprint logs). Update the matching doc whenever you change a system-level concern.

## Build, Test, and Development Commands
- `open antrain.xcodeproj` — launch the workspace in Xcode 16 with the antrain scheme preselected.
- `xcodebuild -scheme antrain -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` — CI-friendly compile that surfaces concurrency warnings.
- `xcodebuild -scheme antrain -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test` — run XCTest targets once they exist; mirror simulator/device you target in your PR.
- `xcrun simctl install booted build/Release-iphonesimulator/antrain.app` — smoke-test Live Activities/widgets against a clean install.

## Coding Style & Naming Conventions
- Swift 6 strict concurrency is enforced; scope UI work to `@MainActor` and mark services `Sendable`.
- Prefer 4-space indentation, trailing commas in multi-line arrays, and `// MARK:` blocks per layer (View, ViewModel, Mapper, etc.).
- File naming: `FeatureNameView`, `FeatureNameViewModel`, `FeatureNameState`, `FeatureNameRepository`. Keep files <=200 lines like existing modules.
- Use localized strings via `Resources/Localizable.xcstrings`; never hardcode user-facing copy.

## Testing Guidelines
- There is no test target yet; create `antrainTests` with XCTest and snapshot coverage when touching risky flows.
- Follow `test_<method>_<condition>_<expected>()` naming; co-locate mocks under `Tests/Support`.
- Exercising widget timelines requires `WidgetTesting` harness plus `xcodebuild test -scheme AntrainWidget`.
- Document new manual test cases in `docs/SPRINT_LOG.md` when automation is not feasible.

## Commit & Pull Request Guidelines
- Follow the existing prefix style (`feat:`, `fix:`, `perf:`, `chore:`) with imperative summaries (e.g., `fix: Prevent nutrition wizard from reappearing`).
- Each PR should link the issue, describe user-facing impact, note doc updates, and include simulator/device + OS in the checklist.
- Attach screenshots or screen recordings for UI changes (light/dark, iPhone/iPad).
- Keep PRs focused per feature/bug; update `docs/*` alongside code for architectural changes.

## Security & Configuration Tips
- Never commit raw Gemini API keys; the current key lives in `Core/Data/Services/GeminiConfig.swift` with light obfuscation—replace via env injection before release.
- Validate entitlements (`antrain.entitlements`) and privacy strings whenever new sensors/APIs are introduced, and run `plutil -lint` before shipping.
