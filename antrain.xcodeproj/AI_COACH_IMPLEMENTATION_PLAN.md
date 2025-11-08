# 🤖 AI Coach Implementation Plan

> **Project:** Antrain Fitness App  
> **Feature:** AI Coach with Apple Intelligence  
> **Architecture:** Clean Architecture + MVVM Hybrid  
> **Started:** 2025-01-XX  
> **Status:** 🟡 In Progress

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [File Structure](#file-structure)
3. [Implementation Phases](#implementation-phases)
4. [Current Progress](#current-progress)
5. [Dependencies](#dependencies)
6. [Testing Strategy](#testing-strategy)
7. [Future Enhancements](#future-enhancements)

---

## 🏗️ Architecture Overview

### Layer Structure

```
┌─────────────────────────────────────────────────┐
│  PRESENTATION LAYER                             │
│  - SwiftUI Views                                │
│  - @Observable ViewModels (@MainActor)          │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│  APPLICATION LAYER                              │
│  - Coordinators                                 │
│  - Services (Actor)                             │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│  DOMAIN LAYER                                   │
│  - Protocols (Service contracts)                │
│  - Models (Domain entities)                     │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│  DATA LAYER                                     │
│  - AI Services (Concrete implementations)       │
│  - Repositories (@ModelActor)                   │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│  PERSISTENCE LAYER                              │
│  - SwiftData ModelContainer                     │
└─────────────────────────────────────────────────┘
```

---

## 📂 File Structure

### New Files to Create

```
antrain/
├── Domain/
│   ├── Models/
│   │   └── ChatMessage.swift                    ⬜ TODO
│   │
│   └── Protocols/
│       └── AIServiceProtocol.swift              ⬜ TODO
│
├── Data/
│   └── AI/                                      ⬜ TODO (new folder)
│       ├── Models/
│       │   └── AppleIntelligence/
│       │       └── (WorkoutActivityAttributes exists) ✅
│       │
│       ├── Services/
│       │   ├── AppleIntelligenceService.swift   ⬜ TODO
│       │   └── RuleBasedCoachService.swift      ⬜ TODO
│       │
│       └── Tools/
│           ├── GetRecentWorkoutsTool.swift      ⬜ TODO
│           ├── GetPRsTool.swift                 ⬜ TODO
│           └── AnalyzeProgressTool.swift        ⬜ TODO
│
├── Application/
│   ├── Services/
│   │   └── AICoachCoordinator.swift             ⬜ TODO
│   │
│   └── ViewModels/
│       └── AICoachViewModel.swift               ⬜ TODO
│
├── Presentation/
│   └── Views/
│       └── AICoach/                             ⬜ TODO (new folder)
│           ├── AICoachView.swift                ⬜ TODO
│           ├── MessageBubble.swift              ⬜ TODO
│           ├── TypingIndicator.swift            ⬜ TODO
│           └── SuggestionButton.swift           ⬜ TODO
│
└── Core/
    └── DependencyInjection/
        └── AppDependencies.swift                🔄 UPDATE
```

**Legend:**
- ✅ Exists / Complete
- ⬜ TODO (Not started)
- 🟡 In Progress
- 🔄 Needs Update
- ❌ Blocked

---

## 🎯 Implementation Phases

### Phase 1: Foundation (Domain + Protocols)
**Duration:** 1-2 hours  
**Status:** ⬜ Not Started

#### Tasks:
- [ ] **1.1** Create `Domain/Models/ChatMessage.swift`
  - Properties: id, role, content, timestamp
  - Conformance: Identifiable, Equatable, Codable
  - Enum for role: user, assistant, system
  
- [ ] **1.2** Create `Domain/Protocols/AIServiceProtocol.swift`
  - Define base protocol
  - Method signatures:
    - `sendMessage(_:) async throws -> String`
    - `streamResponse(_:) async throws -> AsyncThrowingStream<String, Error>`
  
- [ ] **1.3** Documentation
  - Add inline comments
  - Document data flow
  - Protocol usage examples

#### Acceptance Criteria:
- ✅ ChatMessage compiles
- ✅ Protocol defines clear contract
- ✅ No external dependencies yet

---

### Phase 2: Data Layer - Apple Intelligence
**Duration:** 3-4 hours  
**Status:** ⬜ Not Started  
**Depends On:** Phase 1

#### Tasks:
- [ ] **2.1** Create `Data/AI/Services/AppleIntelligenceService.swift`
  - Import FoundationModels
  - Implement AIServiceProtocol
  - Check SystemLanguageModel availability
  - Create LanguageModelSession
  - Handle system instructions
  
- [ ] **2.2** Create `Data/AI/Tools/GetRecentWorkoutsTool.swift`
  - Conform to Tool protocol (FoundationModels)
  - Define Arguments struct
  - Implement call() method
  - Inject WorkoutRepositoryProtocol
  - Format workout data for AI
  
- [ ] **2.3** Create `Data/AI/Tools/GetPRsTool.swift`
  - Conform to Tool protocol
  - Fetch PRs via repository
  - Format PR data
  
- [ ] **2.4** Create `Data/AI/Tools/AnalyzeProgressTool.swift`
  - Conform to Tool protocol
  - Calculate progress metrics
  - Trend analysis
  
- [ ] **2.5** Integration
  - Register tools in AppleIntelligenceService
  - Test tool calling
  - Error handling

#### Acceptance Criteria:
- ✅ Service compiles without errors
- ✅ Model availability check works
- ✅ Tools can access repositories
- ✅ Responses are formatted correctly
- ✅ Simulator testing successful

---

### Phase 3: ~~Fallback Service~~ REMOVED ✅
**Decision:** Apple Intelligence only (no fallback)  
**Reason:** Simpler implementation, premium positioning, future-proof

For unsupported devices, we show `UnavailableView` with device requirements.

**Benefits:**
- ✅ 2 hours saved
- ✅ Less code complexity
- ✅ Cleaner architecture
- ✅ Premium feature positioning

---

### Phase 4: ~~Coordination~~ Simplified Availability Handling ✅
**Duration:** 15 minutes  
**Status:** ✅ Complete  
**Depends On:** Phase 2

**Changes:**
- Removed AICoachCoordinator (not needed)
- Simple availability check in ViewModel
- UnavailableView for unsupported devices

#### Tasks:
- [x] **4.1** Create `UnavailableView.swift` ✅
  - Show device requirements
  - List supported devices
  - "Enable in Settings" button (if applicable)
  - Clean, simple design

#### Acceptance Criteria:
- ✅ Clear messaging for users
- ✅ Shows supported devices
- ✅ Action button when applicable
- ✅ Professional appearance

---

### Phase 5: Application Layer - ViewModel
**Duration:** 2-3 hours  
**Status:** ⬜ Not Started  
**Depends On:** Phase 4

#### Tasks:
- [ ] **5.1** Create `Application/ViewModels/AICoachViewModel.swift`
  - @Observable @MainActor class
  - Published properties:
    - messages: [ChatMessage]
    - isTyping: Bool
  - Inject AICoachCoordinator
  - Implement sendMessage()
  - Implement sendMessageWithStreaming()
  - Clear conversation
  
- [ ] **5.2** State Management
  - Conversation history
  - Loading states
  - Error states
  
- [ ] **5.3** Testing
  - Unit tests with mock coordinator
  - State transitions
  - Error handling

#### Acceptance Criteria:
- ✅ Compiles without errors
- ✅ State updates on main thread
- ✅ Coordinator calls work
- ✅ Messages update UI

---

### Phase 6: Presentation Layer - Views
**Duration:** 3-4 hours  
**Status:** ⬜ Not Started  
**Depends On:** Phase 5

#### Tasks:
- [ ] **6.1** Create `Presentation/Views/AICoach/MessageBubble.swift`
  - User message style
  - Assistant message style
  - System message style
  - Timestamp display
  
- [ ] **6.2** Create `Presentation/Views/AICoach/TypingIndicator.swift`
  - Animated dots
  - Smooth animation
  
- [ ] **6.3** Create `Presentation/Views/AICoach/SuggestionButton.swift`
  - Quick suggestion chips
  - Tap action
  
- [ ] **6.4** Create `Presentation/Views/AICoach/AICoachView.swift`
  - ScrollView for messages
  - TextField for input
  - Send button
  - Suggestion row
  - Navigation bar
  - Clear conversation button
  
- [ ] **6.5** UI Polish
  - Animations
  - Keyboard handling
  - Scroll to bottom
  - Dark mode support

#### Acceptance Criteria:
- ✅ Chat interface works
- ✅ Messages render correctly
- ✅ Input field functional
- ✅ Keyboard behavior correct
- ✅ Looks professional

---

### Phase 7: Dependency Injection
**Duration:** 1 hour  
**Status:** ⬜ Not Started  
**Depends On:** All previous phases

#### Tasks:
- [ ] **7.1** Update `AppDependencies.swift`
  - Add AICoachCoordinator property
  - Add AppleIntelligenceService (optional)
  - Add RuleBasedCoachService
  - Initialize services with repositories
  
- [ ] **7.2** Create ViewModel Factory
  - Add makeAICoachViewModel() method
  - Inject coordinator
  
- [ ] **7.3** Testing
  - Test initialization order
  - Test dependency graph
  - Test preview dependencies

#### Acceptance Criteria:
- ✅ No circular dependencies
- ✅ Proper initialization order
- ✅ Preview support works

---

### Phase 8: Integration & Tab Navigation
**Duration:** 1 hour  
**Status:** ⬜ Not Started  
**Depends On:** Phase 6, Phase 7

#### Tasks:
- [ ] **8.1** Update `MainTabView.swift`
  - Add AI Coach tab
  - Tab icon and label
  - Pass dependencies
  
- [ ] **8.2** Testing
  - Test tab switching
  - Test state persistence
  - Test navigation

#### Acceptance Criteria:
- ✅ Tab appears in tab bar
- ✅ Navigation works
- ✅ Dependencies injected correctly

---

### Phase 9: Testing & Polish
**Duration:** 2-3 hours  
**Status:** ⬜ Not Started  
**Depends On:** Phase 8

#### Tasks:
- [ ] **9.1** Simulator Testing
  - Test on iPhone 15 Pro+ simulator (Apple Intelligence)
  - Test on iPhone 14 simulator (fallback)
  - Test various messages
  - Test tool calling
  
- [ ] **9.2** Edge Cases
  - Empty messages
  - Very long messages
  - Network errors
  - Model unavailable
  
- [ ] **9.3** Performance
  - Response time
  - Memory usage
  - Smooth scrolling
  
- [ ] **9.4** Polish
  - Loading states
  - Error messages
  - Empty state
  - Accessibility

#### Acceptance Criteria:
- ✅ Works on simulator
- ✅ Graceful error handling
- ✅ Performance acceptable
- ✅ No crashes

---

### Phase 10: Documentation & Future Prep
**Duration:** 1 hour  
**Status:** ⬜ Not Started  
**Depends On:** Phase 9

#### Tasks:
- [ ] **10.1** Code Documentation
  - Add inline comments
  - Document architecture decisions
  - Add usage examples
  
- [ ] **10.2** Update this document
  - Mark completed tasks
  - Document learnings
  - Note gotchas
  
- [ ] **10.3** Future Enhancement Prep
  - Document Gemini integration plan
  - Document Claude integration plan
  - Document premium tier plan

#### Acceptance Criteria:
- ✅ Code is well-documented
- ✅ Plan is updated
- ✅ Future path is clear

---

## 📊 Current Progress

### Overall Status: 🟡 In Progress (30%)

#### Phase Completion:
- [x] Phase 1: Foundation (100%) ✅
- [x] Phase 2: Apple Intelligence (100%) ✅
- [x] Phase 3: ~~Fallback Service~~ REMOVED ✅
- [x] Phase 4: Availability Handling (100%) ✅
- [ ] Phase 5: ViewModel (0%)
- [ ] Phase 6: Views (0%)
- [ ] Phase 7: DI (0%)
- [ ] Phase 8: Integration (0%)
- [ ] Phase 9: Testing (0%)
- [ ] Phase 10: Documentation (0%)

#### Estimated Total Time: 16-22 hours (reduced from 18-24)
#### Time Spent: 5.5 hours
#### Time Remaining: 10.5-16.5 hours

---

## 🔗 Dependencies

### System Requirements:
- iOS 18.1+ (Apple Intelligence)
- Xcode 16.1+
- Swift 6.0+

### Frameworks:
- FoundationModels (Apple Intelligence)
- SwiftUI
- SwiftData
- Foundation

### Internal Dependencies:
- WorkoutRepositoryProtocol ✅
- PersonalRecordRepositoryProtocol ✅
- ExerciseRepositoryProtocol ✅
- PRDetectionService ✅
- ProgressiveOverloadService ✅

---

## 🧪 Testing Strategy

### Unit Tests:
```
Domain/
├── ChatMessageTests.swift
└── AIServiceProtocolTests.swift (contract tests)

Data/
├── AppleIntelligenceServiceTests.swift (with mocks)
├── RuleBasedCoachServiceTests.swift
└── ToolTests.swift (GetWorkouts, GetPRs, etc.)

Application/
├── AICoachCoordinatorTests.swift
└── AICoachViewModelTests.swift
```

### Integration Tests:
```
- End-to-end message flow
- Tool calling with real repositories
- Provider selection logic
- Fallback behavior
```

### UI Tests:
```
- Chat interface interactions
- Message rendering
- Keyboard behavior
- Navigation
```

### Manual Testing Checklist:
- [ ] Send simple message
- [ ] Ask about progress
- [ ] Request workout suggestions
- [ ] Ask about PRs
- [ ] Test on device without Apple Intelligence
- [ ] Test on simulator with Apple Intelligence
- [ ] Test offline (rule-based fallback)
- [ ] Test with empty workout history
- [ ] Test with 100+ messages (performance)

---

## 🚀 Future Enhancements

### Phase 11: Gemini Integration (Optional)
- Add GeminiService.swift
- Implement Gemini API models
- Add to coordinator priority list
- Free tier for all users

### Phase 12: Premium Tier (Optional)
- Add Claude/GPT-4o-mini service
- Implement StoreKit subscription
- Paywall UI
- Tier management in coordinator

### Phase 13: Advanced Features (Optional)
- Chat history persistence (SwiftData)
- Export conversations
- Favorite messages
- Voice input
- Image analysis (form checking)

### Phase 14: Performance Optimization (Optional)
- Message pagination
- Lazy loading
- Response caching
- Background pre-loading

---

## 📝 Notes & Learnings

### Gotchas:
- Apple Intelligence only works on iPhone 15 Pro+, M1+ iPad/Mac
- Simulator requires macOS Sequoia 15.1+
- FoundationModels has 4096 token context limit
- Tool calling requires proper JSON formatting
- @ModelActor must be used for SwiftData access

### Architecture Decisions:
1. **Why Protocol-based?**
   - Testability (mock implementations)
   - Flexibility (swap providers)
   - Dependency inversion principle

2. **Why Actor for Coordinator?**
   - Thread safety
   - Background processing
   - No blocking main thread

3. **Why separate tools?**
   - Single responsibility
   - Reusability
   - Testability
   - Clear boundaries

4. **Why ViewModel factory?**
   - Centralized dependency injection
   - Consistent initialization
   - Easy testing

### Best Practices:
- Always check Apple Intelligence availability
- Provide fallback for older devices
- Use streaming for better UX
- Format tool responses clearly
- Handle errors gracefully
- Log important events
- Keep context window in mind (4096 tokens)

---

## 🎓 Resources

### Apple Documentation:
- [FoundationModels Framework](https://developer.apple.com/documentation/FoundationModels)
- [LanguageModelSession](https://developer.apple.com/documentation/FoundationModels/LanguageModelSession)
- [Tool Protocol](https://developer.apple.com/documentation/FoundationModels/Tool)
- [Guided Generation](https://developer.apple.com/documentation/FoundationModels/generating-swift-data-structures-with-guided-generation)

### Internal Docs:
- Architecture document (this file)
- Clean Architecture principles
- MVVM patterns
- SwiftData best practices

---

## 📅 Timeline

### Week 1: Foundation & Core (Phases 1-5)
**Monday-Tuesday:** Domain & Data layers  
**Wednesday-Thursday:** Application layer  
**Friday:** ViewModel completion

### Week 2: UI & Integration (Phases 6-8)
**Monday-Tuesday:** Views  
**Wednesday:** Dependency injection  
**Thursday:** Tab integration  
**Friday:** Buffer/testing

### Week 3: Testing & Polish (Phases 9-10)
**Monday-Tuesday:** Comprehensive testing  
**Wednesday:** Bug fixes  
**Thursday:** Polish & optimization  
**Friday:** Documentation & demo

---

## ✅ Completion Checklist

### Pre-Launch:
- [ ] All phases completed
- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Performance acceptable
- [ ] Works on simulator
- [ ] Documentation complete
- [ ] Code reviewed

### Launch Criteria:
- [ ] Apple Intelligence works (iPhone 15 Pro+ simulator)
- [ ] Fallback works (iPhone 14 simulator)
- [ ] No crashes
- [ ] Error handling graceful
- [ ] UI polished
- [ ] Fast response times

---

## 🤝 Contributing

When working on this feature:
1. Update this document after each phase
2. Mark tasks as complete: `- [x]`
3. Update progress percentages
4. Document learnings and gotchas
5. Add notes about design decisions

---

**Last Updated:** 2025-01-XX  
**Next Review:** After Phase 1 completion

---

*This is a living document. Update it as you progress!* 📝
