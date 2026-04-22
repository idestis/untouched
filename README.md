# Untouched — Name One. Step Away.

> Name one thing. Step away from it. Start over if you slip.
> We won't check. You will. The count is just for you.

A private, single-abstention tracker for iOS. No verification. No community feed. No AI sponsor. No ads.

Sibling app to [Unbroken](https://getunbroken.app). Same house, same voice, same non-negotiables. Unbroken asks you to **do** one thing every day. Untouched asks you to **not touch** one thing for as long as you can.

The full product spec lives in [`SPEC.md`](./SPEC.md). The non-negotiables live in [`CLAUDE.md`](./CLAUDE.md). The coin progression reference lives in [`MILESTONES.md`](./MILESTONES.md). The design reference lives in [`Untouched-mockups.pdf`](./Untouched-mockups.pdf) and [`untouched_app_screens.html`](./untouched_app_screens.html). The marketing site lives in [`landing/`](./landing).

## Requirements

To build and run locally:

- macOS 14 Sonoma or newer
- Xcode 15 or newer
- iOS 17.0+ simulator or device
- Apple Developer Program membership (for TestFlight / App Store)

The app itself has zero third-party dependencies — SwiftUI and Apple frameworks only. No package manager, no CocoaPods, no Carthage.

To publish a release with one command (`task release -- x.y.z`):

```sh
brew install go-task git-cliff gh
gh auth login
```

- [`go-task`](https://taskfile.dev) — task runner (wraps the whole release flow in `Taskfile.yml`)
- [`git-cliff`](https://git-cliff.org) — generates `CHANGELOG.md` + GitHub release notes from Conventional Commits
- [`gh`](https://cli.github.com) — creates the GitHub release and attaches the changelog section

You'll also need an App Store Connect API key for the upload step — see §2 below.

## Run it in the simulator

```sh
cd /Users/destis/Documents/Personal/untouched
open Untouched.xcodeproj
```

In Xcode:

1. Pick an **iPhone 15** (or newer) simulator from the scheme toolbar.
2. Press **⌘R**.
3. First launch shows the Manifesto. Tap **I understand** → Name it.
4. To test purchases, run with the bundled StoreKit configuration at `Untouched/Products.storekit` (Scheme → Run → Options → StoreKit Configuration).
5. To see widgets, press **Home** (⌘+Shift+H), long-press a blank area, add an **Untouched** widget.

Build from the command line:

```sh
xcodebuild -project Untouched.xcodeproj -scheme Untouched \
  -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## What's built

| Area | Status |
| --- | --- |
| App entry + SwiftData container (with App Group) | ⏳ `UntouchedApp.swift`, `Persistence/SwiftDataSchema.swift` |
| Design tokens (colors, fonts, motion) | ⏳ `Theme/` |
| Copy enum (single source for strings) | ⏳ `Resources/Copy.swift` |
| Manifesto + Name-it | ⏳ `ManifestoView`, `NameItView` |
| Today (counter home) | ⏳ `TodayView` |
| Coin-earned interrupt | ⏳ `CoinEarnedView` |
| Shelf (earned + locked coins) | ⏳ `ShelfView` |
| Reset (typed confession) | ⏳ `ResetView` |
| Settings sheet + Crisis resources | ⏳ `SettingsSheet`, `CrisisResourcesView` |
| Paywall ($4.99 lifetime non-consumable) | ⏳ `PaywallView` |
| Reusable components (`CoinRing`, `BentoCard`, `PillButton`, `Chip`, `LabelText`, `MilestoneProgressBar`) | ⏳ `Views/Components/` |
| SwiftData models (`Counter`, `Reset`, `EarnedCoin`, `UserProfile`) | ⏳ `Models/` |
| `CounterEngine` — day math, milestone detection, reset logic | ⏳ `Models/CounterEngine.swift` |
| `CryptoService` — CryptoKit seal/open for confessions | ⏳ `Services/CryptoService.swift` |
| `NotificationService` — optional daily check-in + silent milestone refresh | ⏳ `Services/NotificationService.swift` |
| `StoreService` — `com.getuntouched.lifetime` $4.99 non-consumable | ⏳ `Services/StoreService.swift` |
| `WidgetTimelineService`, `HapticsService` | ⏳ |
| Widgets (inline, rectangular, small, medium) | ⏳ `Widgets/` |
| StoreKit configuration for local testing | ⏳ `Untouched/Products.storekit` |
| Accent color asset + AppIcon | ⏳ `Resources/Assets.xcassets/` |
| Release automation (Taskfile + git-cliff + gh) | ✅ `Taskfile.yml`, `cliff.toml`, `ExportOptions.plist` |
| Landing site | ✅ `landing/` |

## Project structure

Mirrors `SPEC.md` §11.

```
Untouched/
├── UntouchedApp.swift
├── Untouched.entitlements
├── Products.storekit
├── Models/         Counter · Reset · EarnedCoin · Milestone · UserProfile · CounterEngine
├── Views/          Manifesto · NameIt · Today · CoinEarned · Shelf · Reset
│   │              Settings · Paywall · CrisisResources
│   └── Components/ CoinRing · BentoCard · PillButton · Chip · LabelText · MilestoneProgressBar
├── Widgets/        UntouchedWidgetBundle · LockScreenInline · LockScreenRectangular
│                   HomeSmall · HomeMedium
├── Services/       NotificationService · StoreService · HapticsService
│                   WidgetTimelineService · CryptoService
├── Theme/          Color+Untouched · Font+Untouched · Motion
├── Persistence/    SwiftDataSchema
└── Resources/      Copy · Assets.xcassets · Info.plist
```

The project uses Xcode 16+ **synchronized folder groups** — every file you drop into `Untouched/` is picked up automatically. No manual `project.pbxproj` editing required when you add files.

### Adding the Widget extension target

Widget sources live in `UntouchedWidgets/` (bundle, timeline provider, four widgets). They are **not yet wired into `Untouched.xcodeproj`** — Xcode's widget wizard generates all the target, App Group, and code-signing plumbing correctly, so adding this via the UI is safer than hand-authoring.

1. Open `Untouched.xcodeproj` in Xcode.
2. File → New → Target → **Widget Extension**.
3. Product Name: `UntouchedWidgets`. Bundle ID: `app.getuntouched.widgets`. Team: same as the app. Language: Swift. Include Configuration Intent: **no**.
4. When Xcode creates the template files, replace them with the files already on disk under `UntouchedWidgets/` — delete the generated sources and drag the existing `UntouchedWidgets/` folder into the project as a synchronized group (assign it to the widget target only).
5. In **Signing & Capabilities** for the widget target, add the **App Groups** capability with `group.app.getuntouched`.
6. Add the shared model files (Models/, Theme/, Persistence/SwiftDataSchema.swift) to the widget target via **Target Membership** in the File Inspector (or via per-file exceptions on the synced group). The widget needs `Counter`, `Milestone`, `CounterEngine`, `UntouchedSchema`, and `Color+Untouched`.
7. Copy `UntouchedWidgets/UntouchedWidgets.entitlements` into the widget target's **Code Signing Entitlements** build setting.

### Adding the test target

Unit tests for `CounterEngine` and `CryptoService` live in `UntouchedTests/`. Same rationale as widgets — add via Xcode UI:

1. File → New → Target → **Unit Testing Bundle**.
2. Product Name: `UntouchedTests`. Target to be tested: `Untouched`.
3. Delete the generated placeholder tests.
4. Drag `UntouchedTests/` into the project as a synchronized group (assign to the test target only).
5. Run with `⌘U` or `xcodebuild test -project Untouched.xcodeproj -scheme Untouched -destination 'platform=iOS Simulator,name=iPhone 15'`.

## Shipping to TestFlight & App Store

Version and identifiers baked into the project:

- Bundle ID: `app.getuntouched`
- Widget bundle ID: `app.getuntouched.widgets`
- App Group: `group.app.getuntouched`
- IAP Product ID: `com.getuntouched.lifetime` ($4.99, non-consumable, Family Sharing enabled)
- Team ID: `59M4W3VDQT` (edit `ExportOptions.plist` if different)
- Marketing version: `0.1.0` · build: `1` (bump `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` before each upload)

### 1. One-time App Store Connect setup

In [App Store Connect](https://appstoreconnect.apple.com):

1. **Create the app record.** My Apps → + → New App. Platform: iOS. Bundle ID: `app.getuntouched`. SKU: `untouched-ios`. Primary language: English (U.S.).
2. **Create the in-app purchase.** App → Monetization → In-App Purchases → + → **Non-Consumable**. Product ID: `com.getuntouched.lifetime`. Reference name: *Lifetime Unlock*. Price tier: **$4.99**. Family Sharing: **enabled**. Fill localizations (display name, description). Add a review screenshot of the paywall.
3. **Small Business Program.** Apply for the [App Store Small Business Program](https://developer.apple.com/app-store/small-business-program/) for the 15% fee tier. Once approved, it applies automatically.
4. **Export compliance is baked in.** The Info.plist key `ITSAppUsesNonExemptEncryption = NO` ships with every build (set via `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption` in the target's build settings). We do use CryptoKit locally for confession encryption, but it's standard Apple cryptography — non-exempt. App Store Connect will no longer ask the encryption question per-build. Nothing to click.

In the [Apple Developer portal](https://developer.apple.com/account):

- **App ID** `app.getuntouched` must have capabilities for **App Groups** (`group.app.getuntouched`) and **Keychain Sharing** (`app.getuntouched`). Regenerate the provisioning profile if you toggle either.
- **App ID** `app.getuntouched.widgets` must be in the same App Group and Keychain group.

### 2. One-command release (recommended)

Everything below is wrapped in a `Taskfile.yml` at the repo root. If you have [Task](https://taskfile.dev), [git-cliff](https://git-cliff.org), and [gh](https://cli.github.com) installed (`brew install go-task git-cliff gh`), a full publish is:

```sh
export ASC_KEY_ID="…"        # App Store Connect API key id
export ASC_ISSUER_ID="…"     # issuer id
# Place AuthKey_<KEY_ID>.p8 under ~/.appstoreconnect/private_keys/

task release                 # auto-bumps from Conventional Commits
# or pin the version explicitly:
task release -- 0.2.0
```

**Auto-bump.** With no argument, `task release` asks `git-cliff` what semver bump your commits since the last tag imply (`fix:` → patch, `feat:` → minor, `feat!:`/`BREAKING CHANGE` → major) and uses that. Preview it first with `task bump:preview`. The *first* release still needs an explicit version — there's no prior tag to bump from — so use `task release -- 0.1.0` once, then subsequent releases can run bare.

#### Setting up the App Store Connect API key (one-time)

The upload step uses an App Store Connect API key instead of an Apple ID + app-specific password. Do this once per machine.

1. **Generate the key.** [App Store Connect](https://appstoreconnect.apple.com) → *Users and Access* → *Integrations* tab → **Keys** (team keys, not individual) → **Generate API Key**.
   - **Name:** anything descriptive, e.g. `Untouched CI Upload`.
   - **Access:** *Developer* is enough for `xcrun altool` uploads. Don't grant *Admin* unless you need it.
2. **Download the `.p8` file.** You can only download it *once* — App Store Connect will not let you re-download. If you lose it, revoke the key and generate a new one.
3. **Copy the Key ID and Issuer ID** from the Keys page:
   - **Key ID** — the 10-character identifier next to your new key (e.g. `ABCD123XYZ`).
   - **Issuer ID** — the UUID shown at the top of the Keys page (same for every key in the team).
4. **Move the `.p8` to the location `xcrun altool` expects:**

   ```sh
   mkdir -p ~/.appstoreconnect/private_keys
   mv ~/Downloads/AuthKey_ABCD123XYZ.p8 ~/.appstoreconnect/private_keys/
   chmod 600 ~/.appstoreconnect/private_keys/AuthKey_ABCD123XYZ.p8
   ```

   The filename **must** stay `AuthKey_<KEY_ID>.p8` — `altool` discovers the key by that exact pattern.
5. **Export the two IDs in your shell rc** (`~/.zshrc` or `~/.bashrc`) so every new shell has them:

   ```sh
   export ASC_KEY_ID="ABCD123XYZ"
   export ASC_ISSUER_ID="69a6de70-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   ```

   Reload with `source ~/.zshrc` (or open a new terminal).
6. **Verify it works** before running a real release:

   ```sh
   xcrun altool --list-apps \
     --apiKey "$ASC_KEY_ID" \
     --apiIssuer "$ASC_ISSUER_ID"
   ```

   A list of your App Store Connect apps means auth is wired up.

Security notes: the `.p8` is equivalent to a password — don't commit it, don't put it in the repo, don't share it. If it leaks, revoke it immediately in App Store Connect. `~/.appstoreconnect/private_keys/` is outside the repo on purpose.

`task release` in order:

1. Checks you're on `main`, clean, in sync with `origin`, tag doesn't exist, ASC creds present, `gh` logged in.
2. Bumps `MARKETING_VERSION` and auto-increments `CURRENT_PROJECT_VERSION`.
3. Updates `CHANGELOG.md` via `git-cliff` (Conventional Commits grouped by type).
4. Commits `chore(release): v0.2.0` and tags `v0.2.0`.
5. Archives, exports, uploads to App Store Connect via `xcrun altool`.
6. Pushes `main` and the tag.
7. Creates a GitHub release with the latest changelog section as the body.

Useful sub-tasks:

| Command | Purpose |
| --- | --- |
| `task --list-all` | Show every task |
| `task version` | Print current marketing + build number |
| `task bump` / `task bump -- 0.2.0` | Bump versions only (auto from commits, or explicit) |
| `task bump:preview` | Show the next version git-cliff would pick |
| `task changelog:preview` | Preview what the next release section will look like |
| `task changelog` | Regenerate full `CHANGELOG.md` |
| `task archive` / `task export` | Build + export without uploading |
| `task upload` | Archive + export + upload to App Store Connect |
| `task release:notes -- 0.2.0` | Rebuild GH release body for an existing tag |

`ExportOptions.plist` is checked in at the repo root (team id + automatic signing, no secrets).

#### Shipping another build under the same version

You already released `0.1.0`, shipped it to TestFlight, then spotted one more fix. You want to upload a new binary under the *same* `0.1.0` — no new tag, no second GitHub release, just a fresh build number for App Store Connect.

Don't run `task release` again — it would try to re-tag `v0.1.0` and fail the precondition. Instead:

```sh
# 1. commit the fix
git commit -am "fix: …"

# 2. keep MARKETING_VERSION pinned, auto-increment CURRENT_PROJECT_VERSION
task bump -- 0.1.0

# 3. commit the build bump
git commit -am "chore: bump build"

# 4. archive → export → upload to App Store Connect
task upload
```

`task upload` depends on `task export` (which depends on `task archive`), so it always archives fresh before uploading — you can't accidentally ship a stale IPA built with the old build number.

### 3. Manual fallback (Xcode / raw xcodebuild)

If you don't want Task, the equivalent commands:

```sh
# Archive
xcodebuild -project Untouched.xcodeproj \
  -scheme Untouched \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/Untouched.xcarchive \
  archive

# Export + upload
xcodebuild -exportArchive \
  -archivePath build/Untouched.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/export

xcrun altool --upload-app \
  --type ios \
  --file build/export/Untouched.ipa \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"
```

Or via the GUI: Xcode → **Any iOS Device (arm64)** → Product → Archive → Organizer → *Distribute App* → *App Store Connect* → *Upload*. Automatic signing manages the distribution profile.

Bump versions manually by editing `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in the target's Build Settings (App Store Connect rejects duplicate build numbers).

### 4. TestFlight

Once the build finishes processing (email notification, ~5–30 min):

1. App Store Connect → TestFlight → pick the new build → fill **Test Information** (feedback email, marketing URL, privacy URL).
2. Because `ITSAppUsesNonExemptEncryption = NO` is embedded, TestFlight skips the export-compliance prompt.
3. **Internal testing** (up to 100 App Store Connect users): add testers, no review needed, available immediately.
4. **External testing** (up to 10,000): create a group, add testers or a public link. First external build requires a short Beta App Review (usually <24h).

Testers install via the **TestFlight** app on iOS.

### 5. App Store submission

When you're ready to ship publicly:

1. App Store Connect → App → **+ Version** (e.g. `0.1.0`).
2. Fill: **promotional text**, **description**, **keywords**, **support URL**, **marketing URL**, **category** (*Health & Fitness* primary).
   - The description and keywords never name conditions. Untouched is a general-purpose counter. This is deliberate — see SPEC §1.
3. Upload **screenshots** — 6.7" iPhone set is mandatory; 6.1" recommended. Use real app captures (OLED black backgrounds, amber accent coins).
4. **App Privacy** → Data Types: only what actually leaves the device. Declare: *Purchases* (via StoreKit). Not linked to identity, not used for tracking. No other data collected.
5. **Age rating**: complete the questionnaire. Expected **17+** given the context users will self-select into, even though the app itself names nothing.
6. **Build**: select the TestFlight build you want to ship.
7. **In-App Purchases**: attach `com.getuntouched.lifetime` to this version.
8. **App Review Information**: contact email + phone, notes (mention the app is a private day counter with typed reset confirmation; no health data, no location, no account), no demo account required.
9. **Version Release**: *Manually release* is safer for the first submission.
10. Submit for review. Typical turnaround is 24–48h.

### 6. Post-release checklist

- `task release` already tags (`v<version>`), pushes, and creates a GitHub release with the changelog. If you used the manual fallback, run `git tag -a v0.1.0 -m v0.1.0 && git push --tags` yourself.
- Keep `Untouched/Products.storekit` in sync with what you change in App Store Connect; it's only used for local simulator testing but drift is confusing.
- Increment `CURRENT_PROJECT_VERSION` on every upload, even if `MARKETING_VERSION` is unchanged — App Store Connect rejects duplicate build numbers. `task bump` does this automatically.

## House rules

- Swift 5.9+ / SwiftUI / iOS 17+. No UIKit except for haptics.
- SwiftData only (no Core Data). All persistence through the container in `Persistence/SwiftDataSchema.swift`.
- `@Observable` (iOS 17) over `@ObservableObject`.
- Strings live in `Resources/Copy.swift` only.
- Design tokens live in `Theme/`. Don't hardcode colors/sizes elsewhere.
- No third-party dependencies.
- Every `Reset.confession` is encrypted via `CryptoService.seal` before writing. Plaintext never touches disk.
- Widgets read SwiftData through the App Group and compute day count themselves. Never route widget rendering through the main app.
- Copy is austere: no exclamation marks, no emoji, no cheerleading, no moralizing vocabulary. See `CLAUDE.md` and SPEC §15 for the banned word list.

If a proposed feature makes the app more *sticky* rather than the user more *honest*, it does not ship.
