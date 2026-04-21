import Foundation

/// Single source of truth for user-facing strings. Never inline copy in views.
/// Ready for future localization — every string gets a distinct key path.
enum Copy {
    enum Manifesto {
        static let label = "MANIFESTO"
        static let title = "Name one thing.\nStep away from it.\nStart over if you slip."
        static let body = "We won't check. You will. The count is just for you."
        static let cta = "I understand"
    }

    enum NameIt {
        static let prompt = "What are you stepping away from?"
        static let placeholder = "Name it"
        static let startLabel = "Since"
        static let startNow = "Right now"
        static let startPast = "A past date"
        static let milestonesLabel = "MILESTONES"
        static let cta = "Begin"
    }

    enum Today {
        static let daysLabel = "DAYS UNTOUCHED"
        static let coinsLabel = "COINS EARNED"
        static let longestLabel = "LONGEST RUN"
        static let openShelf = "Open shelf"
        static let reset = "Reset"
        static let since = "Since"
    }

    enum CoinEarned {
        static let engravingPrompt = "Engraving (optional)"
        static let engravingPlaceholder = "Something to mark the day"
        static let keep = "Keep it"
        static let share = "Share (private card)"
    }

    enum Shelf {
        static let title = "SHELF"
        static let earnedLabel = "EARNED"
        static let lockedLabel = "LOCKED"
        static let previousRunsLabel = "PREVIOUS RUNS"
    }

    enum Reset {
        static let title = "Tell the truth."
        static let placeholder = "One sentence. For you only."
        static let minCharsHint = "At least 5 characters."
        static let callout = "Coins on your shelf stay. The count goes to zero."
        static func confirmCallout(days: Int, coins: Int) -> String {
            "You kept \(days) days. That happened. The \(coins) coin\(coins == 1 ? "" : "s") on your shelf are yours to keep."
        }
        static let confirm = "Reset to day 0"
        static let cancel = "Never mind"
    }

    enum Settings {
        static let title = "Settings"
        static let notificationTimeLabel = "Daily check-in time"
        static let notificationsToggle = "Daily check-in"
        static let hapticsToggle = "Haptics"
        static let reduceGlowToggle = "Reduce amber glow"
        static let restorePurchase = "Restore purchase"
        static let about = "About"
        static let crisisResources = "Support when you need it"
        static let version = "Version"
    }

    enum Paywall {
        static let title = "Unlock Untouched"
        static let body = "One counter is free, forever.\nIf you want to hold more than one thing at a time — three counters, always yours, no subscription:"
        static let price = "$4.99"
        static let priceUnit = "one-time"
        static let cta = "Unlock — $4.99"
        static let restore = "Restore purchase"
        static let footer = "One payment. No renewal. No upsell."
    }

    enum CrisisResources {
        static let title = "Support when you need it"
        static let intro = "If you need to talk to someone, these lines are free and confidential."
        static let samhsaName = "SAMHSA National Helpline"
        static let samhsaNumber = "1-800-662-4357"
        static let suicideLineName = "988 Suicide & Crisis Lifeline"
        static let suicideLineNumber = "988"
        static let samaritansName = "Samaritans (UK & Ireland)"
        static let samaritansNumber = "116 123"
    }

    enum Notification {
        static func dailyCheckIn(day: Int) -> String {
            "Day \(day) of untouched. Still here."
        }
        static func milestone(day: Int) -> String {
            "\(day) days."
        }
    }

    enum Widget {
        static let brand = "UNTOUCHED"
        static let daysSuffix = "days untouched"
    }

    enum Milestones {
        static let day1 = "Twenty-four hours."
        static let week1 = "One week."
        static let month1 = "Thirty days."
        static let month2 = "Sixty days."
        static let month3 = "Ninety days."
        static let month6 = "Six months."
        static let month9 = "Nine months."
        static let year1 = "One year."
        static func yearly(_ n: Int) -> String { "\(n) years." }

        static func title(for milestone: Milestone) -> String {
            switch milestone {
            case .day1:   return day1
            case .week1:  return week1
            case .month1: return month1
            case .month2: return month2
            case .month3: return month3
            case .month6: return month6
            case .month9: return month9
            case .year1:  return year1
            case .yearly(let n): return yearly(n)
            }
        }

        static func shortLabel(for milestone: Milestone) -> String {
            "\(milestone.dayValue) days"
        }
    }
}
