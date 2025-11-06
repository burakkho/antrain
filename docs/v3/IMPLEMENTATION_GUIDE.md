# Antrain v3.0 - Implementation Guide (Quick Start)

> **Swift 6.2 + iOS 26 + AI Coach**
> **Status:** Ready for Implementation
> **Last Updated:** 2025-11-06

---

## 📋 Overview

v3.0 brings performance improvements (InlineArray, @IncrementalState) and AI Coach powered by Apple Intelligence.

**Timeline:** 2-2.5 weeks
**Prerequisites:** v2.0 released

---

## 🎯 Features

1. **Swift 6.2** - Compiler upgrade
2. **InlineArray** - 25% faster set access
3. **@IncrementalState** - 60fps list updates
4. **Approachable Concurrency** - Cleaner code
5. **AI Coach** - Foundation Models integration
6. **Liquid Glass** - Optional visual polish

---

## ⚡ Quick Start

```bash
# 1. Create branch
git checkout -b v3-development

# 2. Update Swift version
# Xcode → Build Settings → Swift Language Version → 6.2

# 3. Clean build
xcodebuild clean

# 4. Follow phase guides
```

---

## 📅 Implementation Phases

### Phase 1: Foundation (3-4 days)
**Goal:** Swift 6.2 + Performance basics

- [ ] Swift 6.2 upgrade
- [ ] InlineArray migration
- [ ] Concurrency cleanup

**Guide:** [guides/SWIFT_UPGRADE.md](./guides/SWIFT_UPGRADE.md)

---

### Phase 2: UI Performance (2 days)
**Goal:** @IncrementalState for smooth lists

- [ ] LiftingSessionViewModel
- [ ] WorkoutsViewModel
- [ ] DailyNutritionViewModel

**Guide:** [guides/INCREMENTAL_STATE.md](./guides/INCREMENTAL_STATE.md)

---

### Phase 3: AI Coach (7-10 days)
**Goal:** Foundation Models + Chat UI

**Week 1:**
- [ ] Domain models (ChatMessage, Conversation)
- [ ] ChatHistoryRepository
- [ ] FoundationModelsClient

**Week 2:**
- [ ] ContextBuilderService
- [ ] AICoachService (with Structured Outputs + Tool Calling)
- [ ] AICoachViewModel
- [ ] AICoachView + Components

**Guide:** [guides/AI_COACH_IMPL.md](./guides/AI_COACH_IMPL.md)

---

### Phase 4: Polish (3-4 hours)
**Goal:** Visual enhancements

- [ ] Liquid Glass effects (cards)
- [ ] Final testing
- [ ] Performance profiling

---

## 🔑 Critical Apple Guidelines

Before starting Phase 3, **read:**

📖 [APPLE_GUIDELINES.md](./APPLE_GUIDELINES.md)

**Key requirements:**
- ✅ Structured Outputs (type-safe AI responses)
- ✅ Tool Calling (dynamic data access)
- ✅ Battery awareness
- ✅ Streaming responses

---

## 📊 Performance Targets

| Metric | v2.0 | v3.0 Target |
|--------|------|-------------|
| Set add latency | 45ms | < 30ms |
| List scroll | 50fps | 60fps |
| Memory | 120MB | 100MB |
| AI response | N/A | < 2s |

---

## ✅ Migration Checklist

### Pre-Migration
- [ ] v2.0 stable
- [ ] Backup (`git tag v2.0.0`)
- [ ] Xcode 26 installed
- [ ] macOS 26 Tahoe (for AI features)

### Phase 1
- [ ] Swift 6.2 builds
- [ ] Tests pass
- [ ] WorkoutExercise uses InlineArray
- [ ] @MainActor removed from ViewModels

### Phase 2
- [ ] @IncrementalState added to 3 ViewModels
- [ ] 60fps verified in Instruments

### Phase 3
- [ ] ChatMessage + Conversation models
- [ ] ChatHistoryRepository works
- [ ] FoundationModelsClient integrated
- [ ] Structured Outputs implemented
- [ ] Tool Calling registered
- [ ] Chat UI complete
- [ ] Coach tab in MainTabView

### Phase 4
- [ ] Liquid Glass added
- [ ] All tests pass
- [ ] Performance benchmarks met

---

## 🗂️ File Changes

### New Files (~1,500 lines)
```
antrain/Core/Domain/Models/Coach/
├── ChatMessage.swift
├── Conversation.swift
└── CoachContext.swift

antrain/Core/Data/Repositories/
└── ChatHistoryRepository.swift

antrain/Core/Services/AI/
├── FoundationModelsClient.swift
├── ContextBuilderService.swift
└── AICoachService.swift

antrain/Features/Coach/
├── ViewModels/AICoachViewModel.swift
└── Views/
    ├── AICoachView.swift
    └── Components/
        ├── ChatBubble.swift
        └── QuickPromptButton.swift
```

### Modified Files
```
antrain.xcodeproj/project.pbxproj (Swift 6.2)
antrain/Core/Domain/Models/Workout/WorkoutExercise.swift (InlineArray)
antrain/App/MainTabView.swift (Coach tab)
antrain/App/AppDependencies.swift (AI services)
antrain/Features/*/ViewModels/*.swift (@MainActor removal)
antrain/Resources/Localizable.xcstrings (Coach strings)
```

---

## 🐛 Common Issues

### InlineArray capacity exceeded
```swift
// Check before append
if !exercise.sets.isFull {
    exercise.sets.append(newSet)
}
```

### @IncrementalState not updating
```swift
// Add explicit .id()
ForEach(viewModel.exercises) { exercise in
    ExerciseCard(exercise: exercise)
        .id(exercise.id)
}
```

### Foundation Models unavailable
```swift
guard FoundationModelsClient.isAvailable else {
    return "Requires iOS 26+"
}
```

**Full troubleshooting:** [guides/TROUBLESHOOTING.md](./guides/TROUBLESHOOTING.md)

---

## 📚 Detailed Guides

### Core Implementation
- [Swift 6.2 Upgrade](./guides/SWIFT_UPGRADE.md) - Compiler, InlineArray, Concurrency
- [InlineArray Deep Dive](./guides/INLINEARRAY_GUIDE.md) - API, migration, testing
- [@IncrementalState Guide](./guides/INCREMENTAL_STATE.md) - Fine-grained UI updates

### AI Coach
- [AI Coach Implementation](./guides/AI_COACH_IMPL.md) - Complete architecture
- [Apple Guidelines](./APPLE_GUIDELINES.md) - Official recommendations

### Reference
- [Swift 6.2 Features](./SWIFT_6_2_FEATURES.md) - API reference
- [AI Coach Architecture](./AI_COACH.md) - Original detailed spec
- [Troubleshooting](./guides/TROUBLESHOOTING.md) - Solutions

---

## 🧪 Testing

### Unit Tests
```bash
xcodebuild test -scheme antrain \
  -only-testing:antrainTests/PerformanceTests
```

### Integration Tests
1. Lifting session with InlineArray
2. AI Coach conversation flow
3. @IncrementalState list updates

### Performance
```bash
instruments -t "Time Profiler" antrain.app
```

**Check:**
- Frame rate: 60fps
- Memory: < 100MB
- InlineArray: < 10ms (1000 iterations)

---

## 🎓 Learning Path

**Day 1:**
1. Read APPLE_GUIDELINES.md (15 min)
2. Read guides/SWIFT_UPGRADE.md (20 min)
3. Start Swift 6.2 upgrade

**Day 2-4:**
4. Complete Phase 1 (Swift + InlineArray)
5. Read guides/INCREMENTAL_STATE.md

**Day 5-6:**
6. Complete Phase 2 (@IncrementalState)

**Day 7:**
7. Read guides/AI_COACH_IMPL.md (30 min)
8. Read APPLE_GUIDELINES.md again (focus on Structured Outputs)

**Day 8-16:**
9. Complete Phase 3 (AI Coach)

**Day 17-18:**
10. Phase 4 polish + testing

---

## 🚀 Post-Implementation

### Update Docs
- [ ] CHANGELOG.md
- [ ] App Store description
- [ ] Screenshots (AI Coach)

### Marketing
- [ ] "Powered by Apple Intelligence" badge
- [ ] Press release
- [ ] Social media posts

### App Store
- [ ] v3.0.0 build
- [ ] TestFlight beta
- [ ] Submit for review

---

## 💬 Support

### Issues
- Check [TROUBLESHOOTING.md](./guides/TROUBLESHOOTING.md)
- Search GitHub Issues
- Create new issue with `[v3.0]` prefix

### Questions
- Review detailed guides in `docs/v3/guides/`
- Check Apple documentation
- WWDC 2025 sessions

---

## 📝 Git Workflow

```bash
# Feature branches
git checkout -b v3/swift-upgrade
git checkout -b v3/inlinearray
git checkout -b v3/incremental-state
git checkout -b v3/ai-coach

# Merge to v3-development
git checkout v3-development
git merge v3/swift-upgrade
git merge v3/inlinearray
git merge v3/incremental-state
git merge v3/ai-coach

# Final merge to main
git checkout main
git merge v3-development
git tag v3.0.0
git push --tags
```

---

## 🎉 Success Criteria

- [ ] All 25 warnings fixed (17 auto + 8 manual)
- [ ] Performance targets met
- [ ] AI Coach works offline
- [ ] Structured Outputs implemented
- [ ] Tool Calling functional
- [ ] 60fps in all lists
- [ ] Memory < 100MB
- [ ] All tests pass (80%+ coverage)
- [ ] App Store guidelines compliant

---

**Document Lines:** 248 / 300 ✅
**Status:** Complete Quick Start Guide
**Next:** See guides/ for detailed implementation
