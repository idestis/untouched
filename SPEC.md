# Untouched — App Specification

> "Name one thing. Step away from it. Start over if you slip.
> We won't check. You will. The count is just for you."

A single-abstention tracker for iOS. No verification. No community feed. No AI sponsor. No ads. The count is the feature — and it belongs to the user alone.

Sibling app to [Unbroken](https://getunbroken.app). Same house, same voice, same non-negotiables. Unbroken asks you to **do** one thing every day. Untouched asks you to **not touch** one thing for as long as you can.

---

## 1. Philosophy (non-negotiable)

These rules override any feature idea. If a feature contradicts them, it does not ship.

- **One abstention at a time** on the free tier. Premium unlocks up to three. The user names the thing privately. The app never tells them what to pick.
- **Days counted up, never down.** No countdown timers, no pressure framing. We display the count, nothing more.
- **No verification.** The app never asks for proof. It trusts the user completely. If they lie, they lie to themselves — and they know it.
- **Coins earned are never taken away.** A relapse resets the running count to zero. The coins on the shelf stay. They record something that actually happened.
- **Reset requires typing**, not tapping. One sentence, stored locally, never shown again unless the user asks. This is the friction that protects honest self-reporting.
- **No social features. Ever.** No feed, no leaderboard, no friends, no anonymous community. The share card is a one-way private export.
- **No moralizing copy.** The app never says "relapse," "fall," "failure," "ashamed," "disappointed." The user chooses what the thing is. The app only counts days.
- **No dark patterns.** No streak-recovery purchase, no "you're about to lose your progress" notifications, no scary red animations on reset.
- **Dark-first and dark-only** is the primary theme. Light mode is available but secondary. True OLED black (`#000000`). Single amber accent (`#EF9F27`).
- **Austere aesthetic.** Oversized typography, generous negative space, minimal chrome. The coin is the only decorative element, and it is earned.
- **Widget-first.** The home screen and lock screen widgets are the main surface. Opening the app should be optional.
- **Private by default.** The word the user types to name the thing never leaves the device. The App Store description never names conditions.

---

## 2. Target platform

- **iOS 17+** (iPhone only for v1; no iPad layout optimization in v1)
- **Swift 5.9+ / SwiftUI**
- **Xcode 15+**
- **Device targets:** iPhone 12 and newer (OLED screens matter for the aesthetic)
- **WidgetKit** is required — widgets are a first-class surface, not an afterthought.

---

## 3. Core user flow

```
Onboarding (Manifesto)
        ↓
Name it → Pick start date → Begin
        ↓
Today ←──────────────────────┐
   ↓                          │
  (every day, count ticks)    │
   ↓                          │
  (on milestone day)          │
   ↓                          │
Coin earned → Shelf → Today ──┘
   ↓
  (if user slips)
   ↓
Reset → typed confession → Day 0 → Today (coins still on shelf)
```

The user's typical daily interaction is **looking at the widget**. Opening the app is for earning a coin, reading the shelf, or reporting a reset.

---

## 4. Data model

### Counter
```swift
struct Counter {
    let id: UUID
    var name: String              // user-typed, e.g. "Cigarettes", "Him", "The bottle"
    var startDate: Date           // current run began
    var resets: [Reset]           // history of all resets for this counter
    var earnedCoins: [EarnedCoin] // permanent — never removed
    var allTimeLongest: Int       // longest single run, in days
    var state: CounterState
}

enum CounterState {
    case active
    case archived(Date)           // user stopped tracking this thing
}
```

### Reset
```swift
struct Reset {
    let id: UUID
    let date: Date
    let confession: String        // one sentence, typed by user, 5–280 chars
    let runLengthDays: Int        // how long this run lasted
}
```

### EarnedCoin
```swift
struct EarnedCoin {
    let id: UUID
    let milestone: Milestone      // .day1, .week1, .month1, ...
    let earnedDate: Date          // when the coin was unlocked
    var engraving: String?        // optional user note, shown on the coin
    let runStartDate: Date        // which run earned this coin
}

enum Milestone: Int, CaseIterable {
    case day1      = 1            // 24 hours
    case week1     = 7
    case month1    = 30
    case month2    = 60
    case month3    = 90
    case month6    = 180
    case month9    = 270
    case year1     = 365
    // after year1, every 365 days: year2, year3, ... (generated dynamically)
}
```

### UserProfile (local)
```swift
struct UserProfile {
    var hasCompletedOnboarding: Bool
    var counters: [Counter]              // 1 free, up to 3 premium
    var isPremiumUnlocked: Bool          // lifetime, set by StoreKit
    var dailyCheckInTime: DateComponents?  // optional single notification time
    var notificationsEnabled: Bool
    var hapticsEnabled: Bool
    var reduceAmberGlow: Bool            // accessibility — dims the coin animations
}
```

### Persistence
- Use **SwiftData** (iOS 17+). Single source of truth is the local store.
- **No iCloud sync in v1.** Deliberate — the counter is private, and sync creates failure modes (lost data, conflict resolution) that are worse than the limitation.
- The `confession` text is stored encrypted at rest (CryptoKit + Keychain-stored key). Even a local backup can't read it without the device.
- Coins and resets are **append-only**. No edit UI, no delete UI. History is a record, not a document.

---

## 5. Screen inventory

Each screen maps to a SwiftUI `View`. Reference mockups in the companion PDF.

| # | Screen | View name | Appears when |
|---|---|---|---|
| 01 | Manifesto (onboarding) | `ManifestoView` | First launch only |
| 02 | Name it | `NameItView` | No active counter exists, or adding a new one |
| 03 | Today | `TodayView` | Active counter exists — the default home screen |
| 04 | Coin earned | `CoinEarnedView` | Day count crosses a milestone threshold |
| 05 | Shelf | `ShelfView` | User taps "Open shelf" from Today |
| 06 | Reset | `ResetView` | User taps "Reset" — typed confirmation required |
| 07 | Settings (bottom sheet) | `SettingsSheet` | Gear icon tapped from Today |
| 08 | Paywall | `PaywallView` | Attempting to add a 2nd counter without unlock |

**Widgets** (first-class surface, not a screen):
- Lock Screen inline — single day number (`47`)
- Lock Screen rectangular — day count + next milestone countdown
- Home Screen small — name + day count
- Home Screen medium — name, day count, next coin progress bar, last earned coin

---

## 6. Design tokens

These values are final. Do not improvise. Wherever possible, **share tokens with Unbroken** via a common `Theme` Swift package — the two apps are siblings and should be visually identical at the primitive level.

### Colors (single source)
```swift
extension Color {
    // Primary surfaces
    static let utBackground = Color(hex: "000000")           // true black (dark)
    static let utBackgroundLight = Color(hex: "f7f3ea")      // cream (light)
    static let utSurface    = Color.white.opacity(0.04)      // cards/bento (dark)
    static let utSurfaceLight = Color.black.opacity(0.035)   // cards/bento (light)
    static let utBorder     = Color.white.opacity(0.08)      // hairlines (dark)
    static let utBorderLight = Color.black.opacity(0.08)     // hairlines (light)
    
    // Text
    static let utTextPrimary    = Color.white                // 100%
    static let utTextSecondary  = Color.white.opacity(0.5)   // body dim
    static let utTextTertiary   = Color.white.opacity(0.4)   // labels
    
    // Accent (single, used surgically — only for earned coins and active state)
    static let utAmber          = Color(hex: "EF9F27")
    static let utAmberDim       = Color(hex: "b8782f")       // darker amber for light-mode labels
    static let utAmberSoft      = Color(hex: "EF9F27").opacity(0.15)
    
    // Semantic
    static let utDanger         = Color(hex: "E24B4A")       // reset screen only
    static let utSuccess        = Color(hex: "97C459")       // reserved — not used in v1
}
```

### Typography
- Font: **SF Pro** (system default). No custom fonts in v1. Identical to Unbroken.
- Two weights only: **regular (400)** and **medium (500)**. Never bold/semibold.
- Scale:
  - Mega number: `120pt` medium (Today screen — the count)
  - Screen title: `48pt` medium ("Thirty days." on coin-earned, "Tell the truth." on reset)
  - H1: `34pt` medium (manifesto)
  - Name display: `40pt` medium, `letter-spacing: -1.5pt` (the user-typed noun, e.g. "Cigarettes.")
  - Body: `14–16pt` regular
  - Label: `10pt` medium, `letter-spacing: 2pt`, `UPPERCASE`
  - Coin number: `44pt` medium (large coin, milestone screen)
  - Small coin number: `18pt` medium (shelf)
- Tracking: negative on large type (`-1pt` at 34+, `-6pt` at 120+)

### Spacing
- Base unit: `4pt`. Prefer multiples (`8, 12, 16, 24, 32, 48`).
- Screen padding: `22pt` horizontal, `22pt` vertical.

### Corners
- Cards/bento: `16pt`
- Small elements (chips, list items): `12pt`
- Buttons: **pill** (`Capsule()` in SwiftUI)
- Coin rings: perfect circle (`Circle()`)

### Coin rendering
- **Earned coin:** `Circle().stroke(Color.utAmber, lineWidth: 1.5)` with `Color.utAmberSoft` fill
- **Locked coin:** `Circle().stroke(Color.white.opacity(0.18), lineWidth: 1, dash: [4, 4])` with no fill
- **Coin-earned moment glow:** radial gradient from `Color.utAmber.opacity(0.12)` at 32% to background, plus `shadow(color: .utAmber.opacity(0.25), radius: 50)` on the ring
- Never animate the coin on normal display. It earns its visibility by being still.

### Motion
- Default transition: `.easeInOut(duration: 0.25)`
- Counter tick (day rollover): `.spring(response: 0.3, dampingFraction: 0.7)`
- Coin-earned screen entry: `.easeOut(duration: 0.6)` for the ring stroke draw; text fades in at 0.3s
- Screen transitions: `.asymmetric(insertion: .opacity.combined(with: .offset(y: 12)), removal: .opacity)`
- **If `reduceAmberGlow` is on** (user toggle in Settings, defaults to off), all coin animations become instant opacity fades. No glows.

### Haptics
- Day rollover (if user opens app at the moment a new day increments): `.selection`
- Coin earned: `.success` (UINotificationFeedbackGenerator) + delayed `.medium` impact after 200ms
- Reset committed: single `.heavy` impact. No celebration. No error sound.
- Cancel reset: `.selection`

---

## 7. Feature list — v1 scope

### Must-have (ships in v1)

- **Onboarding manifesto** — static screen, one button, one-time
- **Name it flow** — user types the noun (1–40 chars), picks start date (now or backfill), sees milestone preview
- **Today screen** — the big number, next-coin progress bar, two bento stats, Open shelf / Reset buttons
- **Coin earned interrupt** — appears on launch if a milestone was just crossed, optional engraving field
- **Shelf** — all earned coins (amber), all locked coins (dashed), previous-runs summary
- **Reset screen** — typed confession (required, min 5 chars), preview of what stays on the shelf, danger-styled confirmation
- **Daily check-in notification** — optional, one per day, user-set time, zero pressure copy
- **Silent coin-earned notification** — fires at midnight of the milestone day, wakes the lock-screen widget
- **Widgets** — lock screen inline, lock screen rectangular, home screen small, home screen medium
- **Local persistence** — SwiftData + CryptoKit for confession encryption
- **Settings bottom sheet** — notification time, notifications toggle, haptics toggle, reduce amber glow, restore purchase, about, crisis resources link
- **Paywall** — triggers on 2nd counter add, $4.99 one-time, StoreKit 2, lifetime unlock
- **Share card** — private screenshot-style image ("47 days. Untouched.") with no identifying info, opt-in only
- **Crisis resources screen** — SAMHSA / 988 / Samaritans links in settings, behind a "support when you need it" ghost link. Never pushed, always available.

### Explicitly NOT in v1

- Android
- iPad layout
- iCloud sync (planned for v1.1 behind an explicit opt-in)
- Apple Watch app (planned for v1.2)
- Multiple simultaneous counters on free tier
- Any form of community, sponsor matching, or chat
- AI "sponsor" or chatbot
- Streak freezes, grace days, or relapse forgiveness
- Money-saved calculator (moralizes the thing, implies a category)
- Health app integration (implies a medical category we don't want)
- Social / friends / leaderboards
- Category presets ("Alcohol," "Nicotine," etc.) — the user names it themselves, always
- Analytics beyond App Store defaults
- Localization (English-only in v1)

---

## 8. Monetization

- **Free tier:** 1 active counter, all widget types, all coins, all features
- **Premium tier:** $4.99 one-time in-app purchase, lifetime access
  - Product ID: `com.getuntouched.lifetime`
  - Non-consumable
  - Apple Small Business Program enrolled (15% fee tier)
  - Family Sharing: **enabled**
  - Restore Purchases: **required** (settings)

**What premium unlocks:**
- Up to **3 simultaneous counters**
- Optional iCloud sync (when it ships in v1.1)
- Coin shelf backgrounds (3 muted options — no loud colors)
- Tip jar (separate, not required for any feature)

**No subscription. Ever.** Many users of this app will be in financial recovery. Recurring charges on a recovery tool are predatory.

**Paywall trigger logic:**
```
if userProfile.counters.count >= 1 && !userProfile.isPremiumUnlocked && userWantsToAddAnother {
    showPaywall()
}
```

**Paywall copy (use exactly):**
> One counter is free, forever.
> If you want to hold more than one thing at a time —
> three counters, always yours, no subscription:
>
> Unlock Untouched — $4.99
>
> One payment. No renewal. No upsell.

---

## 9. Permissions

Requested contextually, never upfront at launch.

| Permission | When requested | Info.plist key | Reason copy |
|---|---|---|---|
| Notifications | After first counter started, only if user enables the daily check-in | `UNUserNotificationCenter` | "One check-in a day, at a time you pick. Silent coin notifications on milestone days. Never more than that." |

**Untouched requests no other permissions.** No microphone, no camera, no contacts, no location, no health data, no photo library (share card is rendered in-app and saved via the standard share sheet, which handles permission).

This is intentional. The minimal permission surface is part of the trust contract.

---

## 10. Notification behavior

- **One visible notification per day, maximum** — the optional daily check-in.
- **Zero "panic" notifications.** The app never sends "you're about to lose your streak," "don't break your streak," or any variant.
- **Silent milestone notifications** fire at midnight on coin days to refresh the lock-screen widget. These are `.passive` interruption level — they don't light up the screen or ping.
- Scheduled via `UNCalendarNotificationTrigger`.
- Daily check-in content: neutral. *"Day 47 of untouched. Still here."* No exclamation. No verb. Just the state.
- **No notification on reset.** The user already knows. Silence is respect.
- Coin-earned screen appears on next app open after the milestone — not via a pushy notification.

---

## 11. Project structure

```
Untouched/
├── UntouchedApp.swift              // @main entry, app lifecycle
├── Models/
│   ├── Counter.swift
│   ├── Reset.swift
│   ├── EarnedCoin.swift
│   ├── Milestone.swift
│   ├── UserProfile.swift
│   └── CounterEngine.swift         // state transitions, day-rollover, milestone detection
├── Views/
│   ├── ManifestoView.swift
│   ├── NameItView.swift
│   ├── TodayView.swift
│   ├── CoinEarnedView.swift
│   ├── ShelfView.swift
│   ├── ResetView.swift
│   ├── SettingsSheet.swift
│   ├── PaywallView.swift
│   ├── CrisisResourcesView.swift
│   └── Components/
│       ├── CoinRing.swift          // earned + locked variants
│       ├── BentoCard.swift
│       ├── PillButton.swift
│       ├── Chip.swift
│       ├── LabelText.swift         // the tracked uppercase labels
│       └── MilestoneProgressBar.swift
├── Widgets/
│   ├── UntouchedWidgetBundle.swift
│   ├── LockScreenInlineWidget.swift
│   ├── LockScreenRectangularWidget.swift
│   ├── HomeSmallWidget.swift
│   └── HomeMediumWidget.swift
├── Services/
│   ├── NotificationService.swift   // UNUserNotificationCenter wrapper
│   ├── StoreService.swift          // StoreKit 2 wrapper
│   ├── HapticsService.swift
│   ├── WidgetTimelineService.swift // schedules timeline entries through next milestone
│   └── CryptoService.swift         // CryptoKit wrapper for confession text
├── Theme/
│   ├── Color+Untouched.swift       // identical palette to Unbroken; shared if feasible
│   ├── Font+Untouched.swift
│   └── Motion.swift
├── Persistence/
│   └── SwiftDataSchema.swift
└── Resources/
    ├── Assets.xcassets
    ├── Copy.swift                  // all user-facing strings, enum-based
    └── Info.plist
```

---

## 12. Engine rules (the core logic)

The `CounterEngine` handles all state transitions and milestone detection. This is the part that cannot have bugs.

### Day calculation

Days untouched is always computed from two dates — never stored as a mutable integer:

```swift
func daysUntouched(for counter: Counter) -> Int {
    let start = counter.startDate
    let today = Calendar.current.startOfDay(for: Date())
    let startOfStart = Calendar.current.startOfDay(for: start)
    return Calendar.current.dateComponents([.day], from: startOfStart, to: today).day ?? 0
}
```

Storing a counter value and incrementing it nightly is **forbidden**. That approach drifts across timezones, DST, and device-asleep gaps.

### Milestone detection

On every app foreground and on every widget timeline refresh:

```swift
func checkForNewCoin(counter: Counter) -> EarnedCoin? {
    let days = daysUntouched(for: counter)
    let earnedDays = Set(counter.earnedCoins.map(\.milestone.rawValue))
    
    for milestone in Milestone.allCases {
        if days >= milestone.rawValue && !earnedDays.contains(milestone.rawValue) {
            return EarnedCoin(
                id: UUID(),
                milestone: milestone,
                earnedDate: Date(),
                engraving: nil,
                runStartDate: counter.startDate
            )
        }
    }
    return nil
}
```

If multiple milestones are unlocked in a single session (e.g. user opens app after a week-long gap and has crossed both `.day1` and `.week1`), present them **one at a time**, oldest first. The user earns each moment.

### Reset logic

```swift
func reset(counter: inout Counter, confession: String) {
    let run = Reset(
        id: UUID(),
        date: Date(),
        confession: confession,
        runLengthDays: daysUntouched(for: counter)
    )
    counter.resets.append(run)
    counter.allTimeLongest = max(counter.allTimeLongest, run.runLengthDays)
    counter.startDate = Date()
    // counter.earnedCoins is NOT cleared. Coins already on the shelf stay.
}
```

### No undo
- Once a coin is earned, it cannot be removed from the shelf.
- Once a reset is committed, it cannot be reverted. (The "never mind" button is before commit, not after.)
- The `startDate` can never be moved forward by the user — only backward, and only during the Name it flow before any coin is earned. After the first coin, `startDate` is immutable until a reset.
- This is intentional. Editable history invites self-deception.

---

## 13. Testing priorities

- Day-count math across timezone changes, DST boundaries, device-asleep gaps of 2+ days
- Milestone detection when multiple milestones are crossed in one session
- Widget timeline correctness — widget must show the right day count even if the app hasn't been opened in weeks
- Reset flow: confession minimum length enforcement, coins-stay-on-shelf invariant
- Premium gating: free user adds counter #2 → paywall; premium user adds counter #4 → refused (hard cap at 3)
- StoreKit paywall trigger (fresh install → 1 counter → attempt 2nd → paywall appears)
- Encryption round-trip for confession text (write, kill app, relaunch, decrypt)
- Widget deep-link: tap widget on lock screen → opens Today → shows correct counter

---

## 14. Non-goals (things we choose to not do well)

- **Accessibility beyond baseline VoiceOver support.** v1 is a visually-dominant experience; proper a11y audit comes in v1.1. `reduceAmberGlow` is the one a11y-adjacent feature shipping in v1.
- **Localization.** English only in v1. Copy strings are in `Resources/Copy.swift` ready for future translation.
- **Onboarding analytics / funnel tracking.** We're not optimizing a funnel. Untouched ships with zero first-party analytics.
- **A/B testing.** The design is opinionated, not experimental.
- **Categorizing the thing for the user.** Untouched never asks "what are you trying to stop?" with a dropdown. The user types a word. The app counts days. It does not need to know more.

---

## 15. Tone of voice

When writing in-app copy, use these:

- **Direct.** "Reset." not "Would you like to reset?"
- **Lowercase where possible.** "30 days" not "30 DAYS!"
- **Neutral.** No "amazing job," no "you got this," no "keep going!" The number speaks. The count is the message.
- **No recovery-industry vocabulary.** Never write "relapse," "fall," "failure," "sober," "clean," "addict," "struggle." The user types the noun; we don't know what they're doing.
- **Present tense, second person — sparingly.** Prefer bare statements. "30 days." not "You've gone 30 days." The latter centers the app; the former centers the day.
- **Short sentences.** One clause, one point. Stop.
- **No exclamation marks. No emojis. No emoticons.**

The voice is **a calm witness who respects your agency and has seen people do hard things quietly.** Not a coach. Not a cheerleader. Not a sponsor. A witness.

Sample copy reference:
- Coin earned: "Thirty days."
- Reset screen heading: "Tell the truth."
- Reset confirmation callout: "You kept 47 days. That happened. The 3 coins on your shelf are yours to keep."
- Daily notification: "Day 47 of untouched. Still here."
- Widget label: "UNTOUCHED" (tracked uppercase)

---

## 16. For the AI coding assistant

When implementing, follow these rules:

1. **Match the mockups exactly.** Spacing, colors, weights, corner radii — all in the Theme files. The mockup HTML and PDF are the source of truth for visual decisions.
2. **Reuse Unbroken's theme primitives.** If Unbroken has a `BentoCard.swift` or `PillButton.swift` component, lift it into a shared Swift package before building Untouched's version. The two apps should be binary-identical at the component level.
3. **Use `@Observable` (iOS 17) over `@ObservableObject`** for state.
4. **Prefer SwiftData over Core Data.** Schema in `Persistence/SwiftDataSchema.swift`.
5. **Never call `UIApplication.shared` from a View.** Use environment or services.
6. **All strings live in `Resources/Copy.swift`** as a single enum for future localization, even though we're English-only in v1.
7. **No third-party dependencies in v1** unless absolutely necessary. SwiftUI + Apple frameworks only.
8. **Encrypt every confession.** The `confession` field on `Reset` is never written to SwiftData as plaintext. Use `CryptoService.seal` before write, `CryptoService.open` on read. The key lives in Keychain, access group shared with the widget extension.
9. **Widgets must be self-sufficient.** The widget computes day count from the stored `startDate` and reads `earnedCoins` directly from SwiftData through an App Group. Do not route widget rendering through the main app.
10. **Write a unit test for every branch of `CounterEngine`.** Day math, milestone detection, reset logic, timezone edges. UI tests are optional.
11. **Commits** use Conventional Commits (`feat:`, `fix:`, `chore:`). Keep them small.

When in doubt about a design choice, ask: *does this help the user be honest with themselves, or does it help the app keep their attention?* If it's the latter, don't do it.

---

## Appendix: Relationship to Unbroken

Untouched and Unbroken are deliberate siblings. They share:

- Visual tokens (colors, typography, spacing, corner radii, motion curves)
- Voice (direct, lowercase, present tense, no exclamation)
- Commercial model ($4.99 one-time, no subscription, no ads, family-sharing enabled)
- Privacy posture (local-first, no analytics, minimal permissions)
- `Theme` Swift package (shared, versioned)

They differ in one axis: **Unbroken counts doing. Untouched counts not-doing.** Both are private commitments between the user and their day. Neither app performs for anyone else.

A user who owns both should see them as the same object used for different grips.
