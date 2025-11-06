# Antrain v3.0 Documentation

> **iOS 26 + Swift 6.2 + AI Coach**
>
> Next-generation fitness tracking with Apple Intelligence

---

## 🎯 What's New in v3.0

### Performance Revolution
- **InlineArray**: 25-30% faster set access
- **@IncrementalState**: 60fps guaranteed list updates
- **Approachable Concurrency**: Cleaner, safer code

### AI Coach (Flagship Feature)
- **Foundation Models**: 100% on-device AI (Apple Intelligence)
- **Structured Outputs**: Type-safe AI responses
- **Tool Calling**: Dynamic data access
- **Context-Aware**: Knows your workouts, nutrition, PRs
- **Privacy-First**: Zero data leaves device

### Modern Design
- **Liquid Glass**: Subtle glassmorphism effects
- **Smooth Animations**: @Animatable macro

---

## 🏆 Competitive Positioning

| Feature | Antrain v3.0 | SmartGym | Apple Workout Buddy |
|---------|--------------|----------|---------------------|
| On-device AI | ✅ | ✅ | ✅ |
| Workout Generation | ✅ | ✅ | ✅ |
| Nutrition Advice | ✅ | ❌ | ❌ |
| Training Programs | ✅ | ❌ | ❌ |
| PR Tracking | ✅ | ✅ | ✅ |
| Structured Outputs | ✅ | ✅ | ✅ |
| Tool Calling | ✅ | ✅ | ❌ |
| Full History Access | ✅ | ✅ | ❌ (real-time only) |
| Privacy-First | ✅ | ✅ | ✅ |
| Free | ✅ | ❌ ($12.99/mo) | ✅ |

**Key Differentiator:** Only app with AI Coach for workouts + nutrition + programs

---

## 📚 Documentation Index

### Core Documentation

| Document | Purpose | Read Time |
|----------|---------|-----------|
| **[IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)** | Quick start + implementation phases | 10 min |
| **[APPLE_GUIDELINES.md](./APPLE_GUIDELINES.md)** | Apple's official recommendations (WWDC 2025) | 15 min |
| **[AI_COACH.md](./AI_COACH.md)** | AI Coach architecture & implementation | 30 min |
| **[SWIFT_6_2_FEATURES.md](./SWIFT_6_2_FEATURES.md)** | API reference for new features | 20 min |

### Detailed Guides (guides/)

- **[SWIFT_UPGRADE.md](./guides/SWIFT_UPGRADE.md)** - Swift 6.2 migration
- **[INLINEARRAY_GUIDE.md](./guides/INLINEARRAY_GUIDE.md)** - InlineArray deep dive
- **[INCREMENTAL_STATE.md](./guides/INCREMENTAL_STATE.md)** - @IncrementalState usage
- **[AI_COACH_IMPL.md](./guides/AI_COACH_IMPL.md)** - Step-by-step AI Coach
- **[TROUBLESHOOTING.md](./guides/TROUBLESHOOTING.md)** - Common issues

### Supporting Documentation

- [v2 Architecture](../v2/TRAINING_PROGRAMS.md) - Training Programs (prerequisite)
- [Main Architecture](../ARCHITECTURE.md) - Core app architecture

---

## 🚀 Quick Start

### Prerequisites

```bash
# Check requirements
xcodebuild -version  # Xcode 26.0+
swift --version      # Swift 6.2+
```

### Setup

```bash
# 1. Create v3 branch
git checkout -b v3-development

# 2. Update Swift version
# Xcode → Project Settings → Build Settings → Swift Language Version → 6.2

# 3. Follow implementation guide
open docs/v3/IMPLEMENTATION_GUIDE.md

# 4. Read Apple Guidelines FIRST
open docs/v3/APPLE_GUIDELINES.md
```

### Timeline

| Phase | Duration | Features |
|-------|----------|----------|
| Phase 1 | 3-4 days | Swift 6.2, InlineArray, Concurrency |
| Phase 2 | 2 days | @IncrementalState |
| Phase 3 | 7-10 days | AI Coach |
| Phase 4 | 3-4 hours | Liquid Glass (optional) |
| **Total** | **2-2.5 weeks** | Complete v3.0 |

---

## 🎨 Feature Overview

### 1. InlineArray (Performance)

Stack-allocated arrays for 25% faster access.

```swift
@Model
final class WorkoutExercise {
    var sets: InlineArray<WorkoutSet, 8> = InlineArray()
}
```

**Learn more:** [SWIFT_6_2_FEATURES.md#inlinearray](./SWIFT_6_2_FEATURES.md)

---

### 2. @IncrementalState (UI Performance)

Only re-renders changed items in lists. 60fps guaranteed.

```swift
@Observable
final class LiftingSessionViewModel {
    @IncrementalState var exercises: [WorkoutExercise] = []
}
```

**Learn more:** [guides/INCREMENTAL_STATE.md](./guides/INCREMENTAL_STATE.md)

---

### 3. AI Coach (Flagship)

**Architecture:**
```
AICoachView (UI)
  ↓
AICoachViewModel (State)
  ↓
AICoachService (Orchestration)
  ↓
FoundationModelsClient (iOS 26 API)
```

**Example conversation:**
```
User: "Bugün ne workout yapmalıyım?"
AI: "Son 3 gündür upper body yaptın. Bugün leg day
     yapmanı öneririm. Squat, RDL, Leg Press - 12-15 set."
```

**Key Features:**
- Structured Outputs (type-safe responses)
- Tool Calling (dynamic data access)
- Context-aware (full history access)
- Battery-aware throttling

**Learn more:** [AI_COACH.md](./AI_COACH.md)

---

### 4. Approachable Concurrency

Automatic MainActor inference for ViewModels.

```swift
// Before (Swift 6.0)
@Observable @MainActor
final class HomeViewModel { }

// After (Swift 6.2)
@Observable
final class HomeViewModel { }  // Auto-inferred!
```

---

## 🔑 Critical Apple Guidelines

Before starting Phase 3, **read:**

📖 [APPLE_GUIDELINES.md](./APPLE_GUIDELINES.md)

**Key requirements:**
- ✅ Structured Outputs (type-safe AI responses)
- ✅ Tool Calling (dynamic data access)
- ✅ Battery awareness
- ✅ Streaming responses
- ✅ Device capability check
- ✅ Offline fallback

**Why Critical:** SmartGym uses these patterns and is Apple's featured fitness app.

---

## 📊 Performance Targets

| Metric | v2.0 | v3.0 Target | Method |
|--------|------|-------------|--------|
| Set add latency | 45ms | < 30ms | InlineArray |
| List scroll fps | 50fps | 60fps | @IncrementalState |
| Memory usage | 120MB | 100MB | InlineArray |
| AI response | N/A | < 2s | Foundation Models |

---

## 🔧 Implementation Checklist

**Phase 1 (3-4 days):** Swift 6.2 + InlineArray + Concurrency cleanup
**Phase 2 (2 days):** @IncrementalState for 3 ViewModels
**Phase 3 (7-10 days):** AI Coach (models, services, UI, Structured Outputs, Tool Calling)
**Phase 4 (3-4 hours):** Liquid Glass + profiling

**Detailed checklist:** [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)

---

## 🐛 Common Issues

**InlineArray errors:** Check capacity before append
**@IncrementalState not updating:** Add explicit `.id()` to ForEach
**Foundation Models unavailable:** Check iOS 26+ and device capability

**Full guide:** [guides/TROUBLESHOOTING.md](./guides/TROUBLESHOOTING.md)

---

## 📦 Release Strategy

### v2.0 → v3.0 Migration

**Backward Compatibility:**
- ✅ SwiftData auto-migrates Array → InlineArray
- ✅ @IncrementalState is transparent to SwiftUI
- ✅ No user data migration needed

**Breaking Changes:** None! v3.0 is fully backward compatible.

---

## ✅ Success Criteria

- [ ] All 25 warnings fixed • Performance targets met • 60fps + <100MB
- [ ] AI Coach: Structured Outputs + Tool Calling + offline mode
- [ ] Tests pass (80%+ coverage) • App Store compliant

---

## 💬 Support

**Issues & Questions:**
1. Check [guides/TROUBLESHOOTING.md](./guides/TROUBLESHOOTING.md)
2. Search GitHub Issues
3. Create new issue with `[v3.0]` prefix

**Contributing:**
1. Read [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)
2. Create feature branch: `v3/feature-name`
3. Submit PR to `v3-development` branch

---

**Last Updated:** 2025-11-06
**Document Version:** 2.0
**Status:** Ready for v3.0 Development

---

Happy Coding! 🚀 Let's make antrain v3.0 the best fitness app on iOS 26!
