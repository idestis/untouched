# Milestones & Coin Progression

Reference for validating the coin schedule. Numbers come from `Milestone.allCases` and the dynamic yearly generator in `CounterEngine`.

Day 0 is the start date. Day 1 is "24 hours". Every milestone is inclusive — crossing into day N means the coin for N unlocks.

---

## Coin schedule (fixed milestones)

| Coin | Day | Enum case | Title copy | Short label |
|---|---|---|---|---|
| Day 1 | 1 | `.day1` | "Twenty-four hours." | "1 day" |
| Week 1 | 7 | `.week1` | "One week." | "7 days" |
| Month 1 | 30 | `.month1` | "Thirty days." | "30 days" |
| Month 2 | 60 | `.month2` | "Sixty days." | "60 days" |
| Month 3 | 90 | `.month3` | "Ninety days." | "90 days" |
| Month 6 | 180 | `.month6` | "Six months." | "180 days" |
| Month 9 | 270 | `.month9` | "Nine months." | "270 days" |
| Year 1 | 365 | `.year1` | "One year." | "365 days" |

After year 1, yearly coins generate dynamically: `year2` at day 730, `year3` at day 1095, and so on — one per 365 days with no upper bound.

---

## Core invariants

1. **Append-only.** Once an `EarnedCoin` is written, it is never removed. Not on reset. Not on counter deletion (we soft-archive counters instead).
2. **One-shot per milestone per run.** The engine stores `earnedCoins: [EarnedCoin]` on the counter; `checkForNewCoins` filters out any milestone already present (by `.rawValue`), so re-running the check never double-earns.
3. **Multiple milestones can unlock in a single session.** If the user opens the app on day 8 without having opened since day 0, both `.day1` and `.week1` unlock in one pass. Present them oldest-first, one interrupt at a time.
4. **Reset preserves coins.** `CounterEngine.reset` clears the running count (sets a new `startDate`) but does **not** touch `earnedCoins`. Previous-run coins stay on the shelf.
5. **`startDate` is immutable after the first coin.** The user can backfill `startDate` during the Name-it flow before any coin is earned. After that, only a reset moves it — and a reset moves it forward (to now), never backward.

---

## Day-count math

Day count is always derived from two dates — never stored as a mutable integer:

```swift
func daysUntouched(for counter: Counter) -> Int {
    let cal = Calendar.current
    let start = cal.startOfDay(for: counter.startDate)
    let today = cal.startOfDay(for: Date())
    return cal.dateComponents([.day], from: start, to: today).day ?? 0
}
```

This is the whole point of the SPEC's "never store an incremented integer" rule. Storing an integer drifts across timezones, DST, and device-asleep gaps.

---

## Validation checklist

- [ ] Every milestone fires exactly once per run (no double-coins).
- [ ] Multi-milestone sessions (e.g. first app open on day 10) unlock all crossed milestones, oldest first.
- [ ] Reset preserves all previously earned coins on the shelf.
- [ ] Day count rolls over correctly across DST forward and DST back.
- [ ] Yearly coins (`year2`, `year3`, ...) generate at the correct day boundary past 365.
- [ ] Widget timeline emits refresh entries at midnight of next day + next milestone day (whichever is sooner).
- [ ] Silent milestone notifications fire at midnight of the coin day with `.passive` interruption level only.

---

## Copy source

All milestone titles are stored in `Resources/Copy.swift` under `Copy.Milestone`. Never inline them in views — the enum is the single source of truth and the path to future localization.
