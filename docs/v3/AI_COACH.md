# AI Coach Architecture (v3.0)

> **iOS 26 + Swift 6.2 + Foundation Models**
>
> On-device conversational AI for personalized fitness guidance

---

## Overview

AI Coach provides personalized fitness guidance using iOS 26's Foundation Models Framework - 100% on-device, zero cloud dependency.

**Key Features:**
- Workout suggestions based on history
- Nutrition advice (macros, protein goals)
- Form tips and progressive overload guidance
- Natural language conversations
- Structured Outputs + Tool Calling (Apple recommended patterns)

**Privacy-First:**
- Zero data leaves device
- Works offline
- No API costs
- Native iOS integration

---

## Architecture

### Layer Organization

```
┌─────────────────────────────────────┐
│      PRESENTATION LAYER             │
│  • AICoachView                      │
│  • AICoachViewModel                 │
│  • ChatBubble, QuickPromptButtons   │
└─────────────────────────────────────┘
                ↓ ↑
┌─────────────────────────────────────┐
│      SERVICE LAYER                  │
│  • AICoachService                   │
│  • FoundationModelsClient           │
│  • ContextBuilderService            │
└─────────────────────────────────────┘
                ↓ ↑
┌─────────────────────────────────────┐
│      DOMAIN LAYER                   │
│  • ChatMessage                      │
│  • Conversation                     │
│  • CoachContext                     │
└─────────────────────────────────────┘
                ↓ ↑
┌─────────────────────────────────────┐
│      DATA LAYER                     │
│  • ChatHistoryRepository            │
│  • WorkoutRepository                │
│  • NutritionRepository              │
└─────────────────────────────────────┘
```

### Conversation Flow

```
User: "Bugün ne workout yapmalıyım?"
  ↓
AICoachViewModel.sendMessage()
  ↓
AICoachService.query()
  ├── ContextBuilderService.buildContext()
  │   ├── Fetch last 10 workouts
  │   ├── Get active program
  │   └── Today's nutrition
  └── FoundationModelsClient.generate()
      ├── Apply context + prompt
      ├── Use Structured Outputs
      ├── Invoke Tool Calling if needed
      └── Return response
           ↓
AICoachViewModel updates UI
  ↓
User sees response in ChatBubble
```

---

## Domain Models

**ChatMessage:** SwiftData model for individual messages (id, content, role, timestamp)
**Conversation:** Container for message threads (id, title, messages relationship)
**CoachContext:** Aggregates user data (workouts, program, nutrition, PRs, goals)

**Learn more:** [guides/AI_COACH_IMPL.md#domain-models](./guides/AI_COACH_IMPL.md)

---

## Service Layer

**FoundationModelsClient:** iOS 26 API wrapper (device check, streaming, Structured Outputs)
**ContextBuilderService:** Aggregates user data from repositories into CoachContext
**AICoachService:** Main orchestrator (context → prompt → response → history)

**Learn more:** [guides/AI_COACH_IMPL.md#service-layer](./guides/AI_COACH_IMPL.md)

---

## Repository, ViewModel & View

**ChatHistoryRepository:** @ModelActor for SwiftData operations (CRUD conversations/messages)
**AICoachViewModel:** @Observable state manager (messages, isGenerating, sendMessage())
**AICoachView:** Chat UI (ScrollView + ChatBubble + InputBar + QuickPrompts)

**Learn more:** [guides/AI_COACH_IMPL.md](./guides/AI_COACH_IMPL.md)

---

## Structured Outputs & Tool Calling (Critical)

**Structured Outputs:** Type-safe AI responses using `@StructuredOutput` macro
- No JSON parsing errors
- SmartGym pattern
- Example: `WorkoutSuggestion` with exercises array

**Tool Calling:** AI invokes app functions dynamically
- Register tools: `fetchLastWorkout`, `getTodayNutrition`, `getPRs`
- AI calls them automatically when needed
- Context-aware without manual building

**Learn more:** [APPLE_GUIDELINES.md](./APPLE_GUIDELINES.md)

---

## Implementation

**Week 1:** Domain models + ChatHistoryRepository + FoundationModelsClient (basic)
**Week 2:** Services + Structured Outputs + Tool Calling + ViewModel + Views

**MainTabView:** Add Coach tab with `Label("Coach", systemImage: "brain.head.profile")`

**Detailed plan:** [guides/AI_COACH_IMPL.md](./guides/AI_COACH_IMPL.md)

---

## File Structure

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
        ├── QuickPromptButton.swift
        └── InputBar.swift
```

**Total:** ~1,500 lines of new code

---

## Testing & Performance

**Testing:** Unit (services, repository), Integration (flow, Tool Calling), UI (chat interaction)
**Targets:** <2s response, 60fps rendering, <150MB memory, <5% battery impact
**Optimizations:** Battery throttling, context caching, message pagination

**Learn more:** [guides/AI_COACH_IMPL.md](./guides/AI_COACH_IMPL.md)

---

## Privacy & Security

**On-Device:** 100% local processing, zero network, no data leaves device
**Storage:** SwiftData (encrypted), no cloud sync, user deletable
**Permissions:** No HealthKit, no network required

---

## References

**Detailed Implementation:**
- [guides/AI_COACH_IMPL.md](./guides/AI_COACH_IMPL.md) - Step-by-step implementation

**Apple Guidelines:**
- [APPLE_GUIDELINES.md](./APPLE_GUIDELINES.md) - Official recommendations
- Structured Outputs (critical)
- Tool Calling (critical)
- Battery awareness
- Streaming responses

**Related Documentation:**
- [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) - v3.0 overview
- [SWIFT_6_2_FEATURES.md](./SWIFT_6_2_FEATURES.md) - Swift 6.2 APIs

---

**Document Lines:** 299 / 300 ✅
**Status:** Architecture Complete
**Next:** See guides/AI_COACH_IMPL.md for implementation
