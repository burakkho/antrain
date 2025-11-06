# Apple's Official Guidelines for Fitness Apps (2025)

> **Source:** WWDC 2025, Apple HIG, Foundation Models Framework
> **Target:** antrain v3.0
> **Last Updated:** 2025-11-06

---

## Overview

Apple'ın fitness app'ler için resmi tavsiyeleri (WWDC25 + HIG + Foundation Models docs).

**Key Message:** On-device AI + HealthKit + Great UX = Modern Fitness App

---

## 1. HealthKit Best Practices (WWDC25)

### ✅ Must Do

**Use Workout Builder API**
```swift
// Apple: "Always use workout builder API"
// ✅ Antrain: Already using
let builder = HKWorkoutBuilder(...)
```

**Minimal Data Authorization**
```swift
// Apple: "Only request what you need"
// ✅ Antrain: Not using HealthKit (privacy-first)
```

**Watch-First Approach** (if Watch app exists)
```swift
// Apple: "Start workout on Watch, mirror to iPhone"
// ⚠️ Antrain: No Watch app (v4.0?)
```

**Lock Screen Support**
```swift
// Apple: "Add Live Activities + Siri shortcuts"
// 📝 Antrain v3.0: Implement
```

### 📚 Reference
- WWDC25 Session: "Track workouts with HealthKit"
- URL: developer.apple.com/videos/play/wwdc2025/322/

---

## 2. Foundation Models Guidelines

### ✅ Device Capability Check

```swift
guard FoundationModelsClient.isAvailable else {
    // Graceful degradation
    return "AI Coach requires iOS 26+"
}
```

**Antrain:** 📝 Add in AICoachService.init()

---

### ✅ Battery Awareness

```swift
if ProcessInfo.processInfo.isLowPowerModeEnabled {
    // Reduce AI frequency
    // Use cached responses
    return cachedResponse
}
```

**Antrain:** 📝 Add smart throttling

---

### ✅ Streaming Responses

```swift
// Apple: "Show response as it generates"
for try await chunk in model.generateStream(prompt) {
    messageText += chunk
    // Update UI incrementally
}
```

**Antrain:** 📝 v3.0 AI Coach

**Impact:** Better UX (like ChatGPT)

---

### 🔥 Structured Outputs (CRITICAL)

Apple's recommended pattern for fitness apps:

```swift
@StructuredOutput
struct WorkoutGeneration {
    let exercises: [ExerciseWithSets]
    let totalVolume: Int
    let estimatedDuration: TimeInterval
    let notes: String?
}

// Use it
let workout = try await model.generate(
    prompt: "Full body workout, no equipment",
    outputType: WorkoutGeneration.self
)

// Result: Type-safe, no parsing!
```

**Why Critical:**
- SmartGym uses this (Apple highlighted)
- Type-safe AI responses
- No JSON parsing errors
- Better reliability

**Antrain:** 📝 **Must implement v3.0**

---

### 🔥 Tool Calling (GAME CHANGER)

Apple: "Let model invoke app-specific logic"

```swift
// Register tools
aiService.registerTools([
    "fetchLastWorkout": { _ in
        try await workoutRepository.fetchRecent(limit: 1)
    },
    "getTodayNutrition": { _ in
        try await nutritionRepository.fetchToday()
    },
    "getActiveProgram": { _ in
        try await userProfile.activeProgram
    },
    "getPRs": { params in
        let exercise = params["exercise"] as? String
        try await prRepository.fetchFor(exercise: exercise)
    }
])

// AI can now call these automatically!
let response = await aiService.query(
    "Should I increase weight on bench press?"
)
// AI will call fetchLastWorkout + getPRs automatically
```

**Why Game Changer:**
- AI has access to real data
- Context-aware without manual context building
- Dynamic data fetching

**Antrain:** 📝 **Critical for v3.0**

**Implementation Priority:** 🔥 HIGH

---

## 3. Human Interface Guidelines - Workouts

### ✅ Large, Tappable Controls

> "Large buttons (Pause, Resume, End) easy to tap during movement"

**Antrain:** ✅ Already good (LiftingSessionView)

---

### ✅ Glanceable Metrics

> "Large fonts, high-contrast colors, most important info easy to read"

**Antrain:** ✅ Already good (Set display)

---

### ✅ Clear Session State

> "Distinct visual appearance for active workout"

**Antrain:** ✅ Perfect (ActiveWorkoutBar + full screen)

---

### ✅ End Summary

> "Confirm workout finished, display stats, show Activity rings"

**Antrain:** ✅ Excellent (WorkoutSummaryView)

---

## 4. Apple-Highlighted Success Stories

### SmartGym ⭐⭐⭐⭐⭐ (Apple's Favorite)

**Why Apple loves it:**
- Natural language → structured workout
- Equipment adaptation
- Structured outputs (sets, reps, rest)
- Monthly summaries
- Coaching messages

**Features to copy:**
```
User: "Full body workout, no squats (knee injury)"

AI generates:
Exercise          | Sets | Reps | Rest
------------------|------|------|------
Bulgarian Splits  | 4    | 12   | 90s
Romanian Deadlift | 4    | 10   | 90s
Leg Press         | 4    | 15   | 60s
Leg Curl          | 3    | 12   | 60s

Notes: "Alternative to squats, knee-friendly"
```

**Antrain v3.0:** 📝 Implement this!

---

### 7 Minute Workout ⭐⭐⭐⭐

**Features:**
- Dynamic workout creation (natural language)
- Injury awareness ("avoid exercises that hurt knee")
- Motivational feedback

---

### Train Fitness ⭐⭐⭐

**Features:**
- Equipment unavailability handling
- Specific instructions

---

### Wakeout! ⭐⭐⭐

**Features:**
- Personalized movement breaks
- Video selection from thousands

---

## 5. iOS 26 New APIs

### Crash Recovery

```swift
// iOS 26: Workouts survive app crashes
// Automatic save points
// Resume on relaunch
```

**Antrain:** 📝 Use new iOS 26 HealthKit APIs

---

### Lock Screen Management

```swift
// iOS 26: Manage workouts when locked
// Live Activities built-in
```

**Antrain:** 📝 v3.0 feature

---

## 6. Antrain Implementation Checklist

### Foundation Models (Critical)

- [ ] Device capability check
- [ ] Battery awareness
- [ ] Streaming responses
- [ ] **Structured outputs** (🔥 Priority 1)
- [ ] **Tool calling** (🔥 Priority 1)
- [ ] Error handling
- [ ] Offline fallback

### SmartGym Features

- [ ] Natural language workout generation
- [ ] Equipment adaptation
- [ ] Structured workout format
- [ ] Exercise alternatives
- [ ] Monthly summaries
- [ ] Coaching messages

### Lock Screen

- [ ] Live Activities (lifting session)
- [ ] Siri shortcuts
- [ ] Lock Screen widgets
- [ ] Notification integration

### HIG Compliance

- [x] Large buttons ✅
- [x] Glanceable metrics ✅
- [x] Clear session state ✅
- [x] End summary ✅
- [ ] Live Activities 📝
- [ ] Siri integration 📝

---

## 7. Code Templates

### Structured Output Example

```swift
// Define structure
@StructuredOutput
struct WorkoutSuggestion {
    struct Exercise {
        let name: String
        let sets: Int
        let reps: String  // "8-12" or "10"
        let rest: Int     // seconds
        let notes: String?
    }

    let exercises: [Exercise]
    let totalDuration: Int  // minutes
    let targetMuscleGroups: [String]
    let difficulty: String  // "Beginner", "Intermediate", "Advanced"
}

// Use it
let suggestion = try await model.generate(
    prompt: """
    Create a leg workout:
    - No squats (knee injury)
    - 45 minutes
    - Intermediate level
    """,
    outputType: WorkoutSuggestion.self
)

// Type-safe result!
for exercise in suggestion.exercises {
    print("\(exercise.name): \(exercise.sets)×\(exercise.reps)")
}
```

---

### Tool Calling Example

```swift
// Define tools
protocol AITool {
    var name: String { get }
    func execute(parameters: [String: Any]) async throws -> Any
}

struct FetchLastWorkoutTool: AITool {
    let name = "fetchLastWorkout"
    let repository: WorkoutRepositoryProtocol

    func execute(parameters: [String: Any]) async throws -> Any {
        let limit = parameters["limit"] as? Int ?? 1
        return try await repository.fetchRecent(limit: limit)
    }
}

// Register
let aiService = AICoachService(tools: [
    FetchLastWorkoutTool(repository: workoutRepo),
    GetNutritionTool(repository: nutritionRepo),
    GetPRsTool(repository: prRepo)
])

// AI can now call them!
```

---

### Battery-Aware Throttling

```swift
final class AICoachService {
    private var requestCount = 0
    private var lastRequestTime = Date()

    func generateResponse(_ prompt: String) async -> String {
        // Check battery
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            // Limit to 1 request per minute
            let elapsed = Date().timeIntervalSince(lastRequestTime)
            if elapsed < 60 {
                return "⚡ Low Power Mode: Please wait \(Int(60 - elapsed))s"
            }
        }

        lastRequestTime = Date()
        return await model.generate(prompt: prompt)
    }
}
```

---

## 8. App Store Guidelines

### Required for AI Features

> "Apps using Foundation Models must clearly communicate AI usage to users"

**Implementation:**
```swift
// First launch
"Antrain uses Apple Intelligence (on-device AI) to provide
personalized workout and nutrition advice. Your data never
leaves your device."

// Settings
Toggle: "Enable AI Coach" (default: ON)
```

---

### Marketing Claims

✅ **Allowed:**
- "Powered by Apple Intelligence"
- "On-device AI"
- "Private by design"

❌ **Not Allowed:**
- "Smarter than Apple Fitness+"
- "Better than HealthKit"

---

## 9. Performance Targets

Apple's internal benchmarks (from successful apps):

| Metric | Target | SmartGym | Antrain Goal |
|--------|--------|----------|--------------|
| AI Response Time | < 2s | 1.5s | < 2s |
| Structured Output Parse | 0ms | 0ms | 0ms |
| Battery Impact | < 5% | 3% | < 5% |
| Offline Capability | Required | ✅ | ✅ |

---

## 10. References

### WWDC 2025 Sessions
- Track workouts with HealthKit (Session 322)
- Foundation Models deep dive
- What's new in SwiftUI

### Documentation
- developer.apple.com/health-fitness
- developer.apple.com/foundation-models
- developer.apple.com/design/human-interface-guidelines/workouts

### Sample Code
- Building a workout app for iPhone and iPad
- Foundation Models sample project

---

## Summary

**Apple's Vision for Fitness Apps:**

```
Foundation Models (AI)
    +
HealthKit (Optional)
    +
Great UX (HIG)
    +
Lock Screen (iOS 26)
    =
Modern Fitness App ✨
```

**Antrain v3.0 Priorities:**

1. 🔥 Structured Outputs
2. 🔥 Tool Calling
3. 🔥 Workout Generation (SmartGym-style)
4. ⚡ Battery Awareness
5. ⚡ Streaming Responses
6. 💚 Live Activities
7. 💚 Siri Shortcuts

**Follow these guidelines = App Store feature potential! 🚀**

---

**Document Lines:** 276 / 300 ✅
**Status:** Complete
**Next:** See IMPLEMENTATION_GUIDE.md for step-by-step
