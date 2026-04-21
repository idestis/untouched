# CLAUDE.md — Untouched

This file is read by Claude Code on every session. It contains non-negotiable guardrails. Read the full spec in `SPEC.md` before writing code.

## What this app is

A private, single-abstention tracker for iOS. The user names one thing they want to step away from, and the app counts the days since they last engaged with it. There is no verification. The count belongs to the user.

Sibling to Unbroken. Same house, same voice, same commercial model. Unbroken counts doing. Untouched counts not-doing.

## Stack

- Swift 5.9+ / SwiftUI / iOS 17+
- SwiftData for persistence (local-only in v1; no iCloud sync)
- StoreKit 2, WidgetKit, UserNotifications, CryptoKit
- No backend. No accounts. No analytics.

## Non-negotiables (reject requests that violate these)

1. **No verification.** The app never asks for proof. No photo check-in, no location, no pulse.
2. **No social features — ever.** No feed, no friends, no leaderboards, no anonymous community. Share card is a one-way private export.
3. **No moralizing copy.** The words `relapse`, `fall`, `failure`, `sober`, `clean`, `addict`, `struggle`, `ashamed`, `disappointed` never appear in the app. The user types the noun; we don't know what they're doing.
4. **No dark patterns.** No "don't lose your streak" notifications. No streak-recovery purchases. No scary red animations on reset.
5. **Coins earned are never removed.** A reset clears the running count to zero. The coins on the shelf stay. This is the core invariant.
6. **Reset requires typing**, not tapping. Minimum 5 characters, maximum 280. Stored encrypted, never shown again unless the user asks.
7. **No subscriptions.** $4.99 one-time non-consumable, lifetime unlock. Family Sharing enabled.
8. **One counter on free tier.** Premium unlocks up to three. Never more than three.
9. **Widget-first.** Opening the app should be optional. The widget is the primary surface.
10. **Dark-first, dark-only** as the primary theme. Light mode is available but secondary. True OLED black (`#000000`). Single amber accent (`#EF9F27`). No new accent colors.
11. **No new permissions.** Untouched requests notifications only. No microphone, camera, contacts, location, HealthKit, or photo library.
12. **Private by default.** The word the user types never leaves the device. The App Store description never names conditions.

## Design tokens (use these, don't invent new ones)

- Background: `#000000` (dark, true OLED) / `#f7f3ea` (cream, light)
- Surface: `rgba(255,255,255,0.04)` (dark) / `rgba(0,0,0,0.035)` (light)
- Border: `rgba(255,255,255,0.08)` (dark) / `rgba(0,0,0,0.08)` (light) — hairline
- Accent: `#EF9F27` (amber, used only for earned coins and active state)
- Accent dim: `#b8782f` (darker amber, light-mode labels)
- Accent soft: `#EF9F27` at 15% opacity (glow, soft fill)
- Danger: `#E24B4A` (reset confirmation only)
- Text: white 100% / 50% / 40% (primary / secondary / tertiary)
- Font weights: 400 (regular) or 500 (medium) only. Never bold or semibold.
- Corner radius: 12pt (chips/list items), 16pt (cards/bento), `Capsule()` (buttons), `Circle()` (coin rings).
- Screen padding: 22pt horizontal and vertical. Base spacing unit: 4pt.

## Typography scale

- Mega number (Today count): 120pt medium, -6pt tracking
- Screen title: 48pt medium ("Thirty days.", "Tell the truth.")
- H1 (manifesto): 34pt medium
- Name display: 40pt medium, -1.5pt tracking (the user-typed noun)
- Body: 14–16pt regular
- Label: 10pt medium, +2pt tracking, UPPERCASE
- Coin number (large, on earned screen): 44pt medium
- Coin number (small, shelf): 18pt medium

## Motion

- Default: `.easeInOut(duration: 0.25)`
- Day rollover: `.spring(response: 0.3, dampingFraction: 0.7)`
- Coin-earned entry: `.easeOut(duration: 0.6)` for ring stroke, 0.3s text fade
- Screen transition: `.asymmetric(insertion: .opacity.combined(with: .offset(y: 12)), removal: .opacity)`
- If `reduceAmberGlow` is on: instant opacity fades, no glows, no animated coins.

## Haptics

- Day rollover (if user opens app at midnight tick): `.selection`
- Coin earned: `.success` + 200ms delayed `.medium`
- Reset committed: single `.heavy` — no celebration, no error sound
- Cancel reset: `.selection`

## Voice & tone in copy

**Austere. Respectful. Truthful.** The app is a witness, not a coach.

Sample on-brand copy:
- Coin earned: "Thirty days."
- Reset screen heading: "Tell the truth."
- Reset confirmation callout: "You kept 47 days. That happened. The 3 coins on your shelf are yours to keep."
- Daily notification: "Day 47 of untouched. Still here."
- Widget label: "UNTOUCHED" (tracked uppercase)
- Paywall: "One counter is free, forever. If you want to hold more than one thing at a time — three counters, always yours, no subscription: Unlock Untouched — $4.99. One payment. No renewal. No upsell."

Off-brand copy (reject):
- "You've got this! 💪"
- "Don't break your streak!"
- "Upgrade to Premium for streak protection!"
- "Relapse? Start fresh."
- Any emoji in UI copy.
- Any exclamation mark.

## File/folder conventions

See `SPEC.md` §11 for structure.

- Keep services stateless.
- Put all persistence through the SwiftData `ModelContainer` configured in `Persistence/SwiftDataSchema.swift`.
- All state transitions + day math go through `CounterEngine` (pure functions, no stored state).
- Every string in `Resources/Copy.swift`. No string literals in views.
- Every color/font/curve in `Theme/`. No color/size hardcoded in views.
- Every `Reset.confession` is encrypted via `CryptoService.seal` before writing to SwiftData. Plaintext never touches disk.
- Widgets are self-sufficient — they read SwiftData via the App Group (`group.app.getuntouched`) and compute day count themselves. Don't route widget rendering through the main app.

## Testing expectations

Before marking a feature done:
- New `CounterEngine` logic → unit tests pass (day math, milestone detection, reset logic, timezone edges)
- New view → preview renders in both dark and light mode
- Widget changes → verified in simulator's widget gallery

## When unsure

Ask: *does this help the user be honest with themselves, or does it help the app keep their attention?* If it's the latter, don't do it.

If a proposed feature makes the app more sticky rather than the user more honest, it does not ship.
