from IPython.display import Markdown

# Prepare a clean summary of all updated files for the user's new XPLog setup
summary = """
### ✅ XPLog – Levande och enklare med Swift Codable

Här är en full överblick med **levande XP-logg** och en **minimal modell med `Codable`**.

---

## 1. 📄 XPEvent.swift (modellen)

```swift
import Foundation
import FirebaseFirestoreSwift

enum XPBonusType: String, Codable {
    case baseTask
    case streak
    case deadlineEarly
    case dailyCombo
    case surprise
    case levelUp
}

struct XPEvent: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let xp: Int
    let date: Date
    let type: XPBonusType
}
