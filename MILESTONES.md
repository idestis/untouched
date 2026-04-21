# Milestones & Coin Progression

Reference for validating the coin schedule. Numbers come from `Milestone.allCases` and the dynamic yearly generator in `CounterEngine`.

Day 0 is the start date. Day 1 is "24 hours". Every milestone is inclusive — crossing into day N means the coin for N unlocks.

---

## Coin schedule

Month and year milestones are **calendar-based** — a counter starting Jan 15
earns `month1` on Feb 15, `month3` on Apr 15, `year1` on Jan 15 next year.
Day and week milestones are exact offsets from `startDate`.

`dayValue` below is the stable integer key persisted on `EarnedCoin` (nominal
day count used as an identifier only — the actual unlock date varies with the
user's start date and the calendar).

| Coin | Unlocks at | Nominal day | Enum case | Title copy | Short label |
|---|---|---|---|---|---|
| Day 1 | start + 1 day | 1 | `.day1` | "Twenty-four hours." | "24h" |
| Week 1 | start + 7 days | 7 | `.week1` | "One week." | "7d" |
| Month 1 | start + 1 month | 30 | `.month1` | "One month." | "1mo" |
| Month 2 | start + 2 months | 60 | `.month2` | "Two months." | "2mo" |
| Month 3 | start + 3 months | 90 | `.month3` | "Three months." | "3mo" |
| Month 6 | start + 6 months | 180 | `.month6` | "Six months." | "6mo" |
| Month 9 | start + 9 months | 270 | `.month9` | "Nine months." | "9mo" |
| Year 1 | start + 1 year | 365 | `.year1` | "One year." | "1y" |
| Year 2 | start + 2 years | 730 | `.yearly(2)` | "2 years." | "2y" |
| Year 3 | start + 3 years | 1095 | `.yearly(3)` | "3 years." | "3y" |

**Horizon cap.** After `yearly(3)` the shelf stops issuing coins and shows a
"keep going" card instead. The day count continues, the running streak is
still honored, but there are no further celebrations — the user has passed
the shelf.

Edge case: a counter starting on Jan 31 earns `month1` on Feb 28/29 (calendar
clamps to the last valid day of the target month).

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
- [ ] Yearly coins (`year2`, `year3`) generate at the correct calendar-year boundary past `year1`.
- [ ] No new coins awarded after `yearly(3)` — shelf shows "keep going" instead.
- [ ] Widget timeline emits refresh entries at midnight of next day + next milestone day (whichever is sooner).
- [ ] Silent milestone notifications fire at midnight of the coin day with `.passive` interruption level only.

---

## Copy source

All milestone titles are stored in `Resources/Copy.swift` under `Copy.Milestone`. Never inline them in views — the enum is the single source of truth and the path to future localization.
