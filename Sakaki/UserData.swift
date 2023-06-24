import SwiftUI

let UserLevelMap: [Int: String] = [
    0: "Beginner",
    5: "Intermediate",
    10: "Advanced",
    15: "Expert",
    20: "Master"
]

let UserLevelDescription: [String: String] = [
    "Beginner": "Congratulations on starting your journey to a cleaner environment! Keep using the app to make a small but significant difference.",
    "Intermediate": "You're making great progress in maintaining cleanliness. Keep using the app to develop a habit that benefits both you and your furry friend.",
    "Advanced": "You're becoming an expert in managing dog waste responsibly! Stay committed to the app and continue setting an example for others.",
    "Expert": "You've reached an impressive level of expertise in maintaining cleanliness and promoting a healthy environment. Your efforts truly make a difference!",
    "Master": "You're a true master at keeping the environment clean and safe for everyone. Your dedication to using the app inspires others to follow your lead. Keep up the fantastic work!"
]

struct UserData {
    let email: String
    let username: String
    let level: String
    let reportCount: Int
}
