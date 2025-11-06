# Training Programs - Çalışma Planı

> **Hazırlandığı Tarih:** 2025-11-06
> **Mevcut Durum:** %90 Complete (Backend ✅, UI ✅, Integration Partial)
> **Kalan İş:** ~8-12 saat (Critical features + polish)

---

## 📊 MEVCUT DURUM ÖZETİ

### ✅ Tamamlanan Kısımlar (90%)

**Backend & Core (100%):**
- ✅ Domain models (TrainingProgram, ProgramWeek, ProgramDay)
- ✅ Repository layer (TrainingProgramRepository)
- ✅ ProgressiveOverloadService (RPE-based suggestions)
- ✅ Program library + seeding system
- ✅ 4 preset programs
- ✅ UserProfile integration
- ✅ Template deletion safety (backend)
- ✅ AppDependencies configuration

**UI & Navigation (100%):**
- ✅ 23 UI components (ViewModels, Views, Components)
- ✅ ProgramsListView with search/filter
- ✅ ProgramDetailView with navigation
- ✅ CreateProgramFlow (4-step wizard)
- ✅ ActiveProgramCard component
- ✅ Navigation from WorkoutsView
- ✅ Program activation flow

### ⚠️ Kalan Kısımlar (10%)

**Critical Missing Features:**
1. ❌ Home screen integration (ActiveProgramCard görünmüyor)
2. ❌ Template deletion safety UI
3. ❌ Program-based workout flow with suggestions
4. ❌ RPE prompt after workout

**Nice-to-Have:**
- ⚠️ Localization (kısmi - %20)
- ❌ Testing (unit + integration)

---

## 🎯 ÖNCELİKLENDİRİLMİŞ ÇALIŞMA PLANI

### Sprint 1: Critical User-Facing Features (Yüksek Öncelik)
**Süre:** 6-8 saat
**Hedef:** Feature'ın ana değerini kullanıcıya sunmak

---

#### Task 1.1: Template Deletion Safety UI ⏱️ 2-3 saat 🔴

**Neden Kritik:**
- Veri bütünlüğü için zorunlu
- Spec requirement
- Production'da data loss önler

**Teknik Detaylar:**
- Backend hazır: `TrainingProgramRepository.findProgramsUsingTemplate()` mevcut
- Repository hataları tanımlı: `cannotDeletePreset`, `usedInPrograms`
- Sadece UI katmanı eksik

**Yapılacaklar:**

**1.1.1: TemplatesViewModel'e kontrol ekle (30 dk)**
```swift
// antrain/Features/Workouts/Templates/ViewModels/TemplatesViewModel.swift

@MainActor
func isTemplateUsedInPrograms(_ template: WorkoutTemplate) async -> [String] {
    guard let programRepo = appDependencies.trainingProgramRepository else {
        return []
    }

    do {
        return try await programRepo.findProgramsUsingTemplate(template)
    } catch {
        return []
    }
}

@MainActor
func deleteTemplate(_ template: WorkoutTemplate) async {
    // Pre-check before deletion
    let programNames = await isTemplateUsedInPrograms(template)

    guard programNames.isEmpty else {
        errorMessage = "This template is used in \(programNames.count) program(s): \(programNames.joined(separator: ", "))"
        return
    }

    // Existing deletion logic
    do {
        try await templateRepository.delete(template)
        // ... rest of deletion
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

**1.1.2: TemplatesListView'a uyarı UI'ı ekle (45 dk)**
```swift
// antrain/Features/Workouts/Templates/Views/TemplatesListView.swift

// Swipe actions güncelle
.swipeActions(edge: .trailing) {
    Button(role: .destructive) {
        templateToDelete = template

        // Check if used in programs
        Task {
            let programs = await viewModel.isTemplateUsedInPrograms(template)
            if programs.isEmpty {
                showDeleteConfirmation = true
            } else {
                programsUsingTemplate = programs
                showUsageWarning = true
            }
        }
    } label: {
        Label("Delete", systemImage: "trash")
    }
    .disabled(template.isPreset)  // Presets can't be deleted anyway
}

// Usage warning alert
.alert("Cannot Delete Template", isPresented: $showUsageWarning) {
    Button("OK", role: .cancel) {}
} message: {
    Text("This template is used in \(programsUsingTemplate.count) training program(s):\n\n\(programsUsingTemplate.joined(separator: "\n"))\n\nRemove it from these programs first.")
}

// Delete confirmation (existing)
.confirmationDialog("Delete Template?", isPresented: $showDeleteConfirmation) {
    // ... existing confirmation
}
```

**1.1.3: Template card'a visual indicator ekle (30 dk)**
```swift
// Template card'da "Used in X programs" badge göster
if let usageCount = viewModel.templateUsageCount[template.id], usageCount > 0 {
    HStack {
        Image(systemName: "calendar.badge.checkmark")
            .font(.caption)
        Text("\(usageCount) program(s)")
            .font(DSTypography.caption)
    }
    .foregroundStyle(DSColors.primary)
    .padding(.horizontal, DSSpacing.xs)
    .padding(.vertical, DSSpacing.xxs)
    .background(DSColors.primary.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
}
```

**1.1.4: Test (15 dk)**
- [ ] Try to delete template used in program → Warning shown
- [ ] Try to delete unused template → Confirmation shown
- [ ] Usage count badge displayed correctly
- [ ] Error messages clear and helpful

**Dosyalar:**
- `antrain/Features/Workouts/Templates/ViewModels/TemplatesViewModel.swift`
- `antrain/Features/Workouts/Templates/Views/TemplatesListView.swift`
- `antrain/Features/Workouts/Templates/Views/Components/TemplateCard.swift` (optional)

**Acceptance Criteria:**
- ✅ Template deletion blocked if used in programs
- ✅ Warning shows program names
- ✅ Delete button disabled or warning shown before action
- ✅ User-friendly error messages
- ✅ Visual feedback on templates that are in use

---

#### Task 1.2: Home Screen Active Program Integration ⏱️ 1-1.5 saat 🔴

**Neden Kritik:**
- Feature keşfedilebilirlik için gerekli
- User engagement için kritik
- "Today's workout" önerisi değerli UX

**Teknik Detaylar:**
- ActiveProgramCard component zaten hazır
- HomeViewModel'de activeProgram property var
- Sadece HomeView'a eklenmesi gerekiyor

**Yapılacaklar:**

**1.2.1: HomeView'a ActiveProgramCard ekle (30 dk)**
```swift
// antrain/Features/Home/Views/HomeView.swift

// Quick actions'tan sonra, workout summary'den önce
if let activeProgram = viewModel.activeProgram,
   let startDate = viewModel.userProfile?.activeProgramStartDate {

    let currentWeek = viewModel.currentWeekNumber ?? 1
    let todayWorkout = viewModel.userProfile?.getTodaysWorkout()

    ActiveProgramCard(
        program: activeProgram,
        currentWeekNumber: currentWeek,
        todayWorkout: todayWorkout,
        onStartWorkout: {
            // Start workout from program
            workoutManager.startWorkoutFromProgram(
                template: todayWorkout?.template,
                programDay: todayWorkout
            )
        }
    )
    .padding(.horizontal)
}
```

**1.2.2: HomeViewModel'e computed properties ekle (15 dk)**
```swift
// antrain/Features/Home/ViewModels/HomeViewModel.swift

var activeProgram: TrainingProgram? {
    userProfile?.activeProgram
}

var currentWeekNumber: Int? {
    userProfile?.currentWeekNumber
}

var todaysWorkout: ProgramDay? {
    userProfile?.getTodaysWorkout()
}
```

**1.2.3: ActiveWorkoutManager'a program context ekle (30 dk)**
```swift
// antrain/Core/Domain/State/ActiveWorkoutManager.swift

var pendingProgramDay: ProgramDay?

func startWorkoutFromProgram(template: WorkoutTemplate?, programDay: ProgramDay?) {
    self.pendingTemplate = template
    self.pendingProgramDay = programDay
    self.showFullScreen = true
}
```

**1.2.4: Test (15 dk)**
- [ ] Active program card görünüyor
- [ ] "Today's workout" doğru gösteriliyor
- [ ] Rest day için doğru mesaj
- [ ] "Start Workout" butonu çalışıyor
- [ ] No active program durumu graceful handle ediliyor

**Dosyalar:**
- `antrain/Features/Home/Views/HomeView.swift`
- `antrain/Features/Home/ViewModels/HomeViewModel.swift`
- `antrain/Core/Domain/State/ActiveWorkoutManager.swift`

**Acceptance Criteria:**
- ✅ ActiveProgramCard HomeView'da görünüyor
- ✅ Current week/progress doğru
- ✅ Today's workout gösteriliyor
- ✅ "Start Workout" butonu functional
- ✅ No active program → Card görünmüyor

---

#### Task 1.3: Program-Based Workout Flow ⏱️ 3-4 saat 🔴

**Neden Kritik:**
- Feature'ın CORE değeri
- Progressive overload magic'i buradan geliyor
- User retention için en önemli kısım

**Yapılacaklar:**

**1.3.1: LiftingSessionViewModel - Program context (1 saat)**
```swift
// antrain/Features/Workouts/LiftingSession/ViewModels/LiftingSessionViewModel.swift

// Add properties
private var programDay: ProgramDay?
private var weekModifier: Double = 1.0
private let progressiveOverloadService: ProgressiveOverloadService

// Update init
init(
    // ... existing params
    programDay: ProgramDay? = nil,
    progressiveOverloadService: ProgressiveOverloadService
) {
    // ... existing init
    self.programDay = programDay

    // Calculate week modifier if from program
    if let programDay = programDay {
        self.weekModifier = programDay.week.intensityModifier
    }
}

// Add method to get suggestions
func getSuggestionsForExercise(_ exercise: Exercise) async -> ExerciseSuggestion? {
    guard programDay != nil else { return nil }

    // Fetch previous workouts for this exercise
    let previousWorkouts = try? await workoutRepository.fetchRecentWorkouts(
        forExercise: exercise,
        limit: 5
    )

    guard let lastWorkout = previousWorkouts?.first else {
        return nil  // No history, can't suggest
    }

    // Get suggestion from service
    return await progressiveOverloadService.suggestForExercise(
        exercise: exercise,
        lastWorkout: lastWorkout,
        weekModifier: weekModifier
    )
}
```

**1.3.2: ExerciseCard - Show suggestions (45 dk)**
```swift
// antrain/Features/Workouts/LiftingSession/Views/Components/ExerciseCard.swift

// Add suggestion display
if let suggestion = viewModel.suggestionForExercise(exercise) {
    HStack(spacing: DSSpacing.xs) {
        Image(systemName: "lightbulb.fill")
            .font(.caption)
            .foregroundStyle(.yellow)

        Text("Suggested: \(suggestion.suggestedWeight, specifier: "%.1f") kg")
            .font(DSTypography.caption)
            .foregroundStyle(DSColors.textSecondary)

        Text("(\(suggestion.reasoning))")
            .font(DSTypography.caption2)
            .foregroundStyle(DSColors.textTertiary)
    }
    .padding(.horizontal, DSSpacing.sm)
    .padding(.vertical, DSSpacing.xs)
    .background(Color.yellow.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
}
```

**1.3.3: LiftingSessionView - Program context badge (30 dk)**
```swift
// antrain/Features/Workouts/LiftingSession/Views/LiftingSessionView.swift

// Show program context in header
if let programDay = viewModel.programDay {
    HStack(spacing: DSSpacing.xs) {
        Image(systemName: "calendar.badge.checkmark")
        Text("Week \(programDay.week.weekNumber)")
        if let phase = programDay.week.phaseTag {
            Text("•")
            Text(phase.displayName)
        }
    }
    .font(DSTypography.caption)
    .foregroundStyle(DSColors.primary)
    .padding(.horizontal, DSSpacing.sm)
    .padding(.vertical, DSSpacing.xxs)
    .background(DSColors.primary.opacity(0.1))
    .clipShape(Capsule())
}
```

**1.3.4: WorkoutSummaryView - RPE prompt (45 dk)**
```swift
// antrain/Features/Workouts/LiftingSession/Views/WorkoutSummaryView.swift

// Add RPE picker (only if from program)
if viewModel.isFromProgram {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
        Text("Rate Difficulty (RPE)", comment: "Workout RPE rating prompt")
            .font(DSTypography.subheadline)
            .fontWeight(.semibold)

        Text("This helps improve future suggestions", comment: "RPE help text")
            .font(DSTypography.caption)
            .foregroundStyle(DSColors.textSecondary)

        Picker("RPE", selection: $viewModel.selectedRPE) {
            ForEach(1...10, id: \.self) { rpe in
                Text("\(rpe) - \(rpeDescription(rpe))")
            }
        }
        .pickerStyle(.menu)
    }
    .padding()
    .background(DSColors.backgroundSecondary)
    .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
}

private func rpeDescription(_ rpe: Int) -> String {
    switch rpe {
    case 1...3: return "Very Easy"
    case 4...6: return "Easy"
    case 7...8: return "Challenging"
    case 9: return "Very Hard"
    case 10: return "Maximum Effort"
    default: return ""
    }
}
```

**1.3.5: Save workout with RPE (30 dk)**
```swift
// LiftingSessionViewModel.swift

func completeWorkout() async {
    // ... existing workout save logic

    // Save RPE if provided
    if let rpe = selectedRPE, programDay != nil {
        completedWorkout.rpe = rpe
    }

    try? await workoutRepository.update(completedWorkout)

    // ... rest of completion
}
```

**1.3.6: Test (30 dk)**
- [ ] Suggestions displayed for exercises
- [ ] Suggestions accurate based on RPE algorithm
- [ ] Program context badge visible
- [ ] RPE prompt shown after program workout
- [ ] RPE saved to workout
- [ ] Non-program workouts don't show RPE prompt

**Dosyalar:**
- `antrain/Features/Workouts/LiftingSession/ViewModels/LiftingSessionViewModel.swift`
- `antrain/Features/Workouts/LiftingSession/Views/LiftingSessionView.swift`
- `antrain/Features/Workouts/LiftingSession/Views/Components/ExerciseCard.swift`
- `antrain/Features/Workouts/LiftingSession/Views/WorkoutSummaryView.swift`

**Acceptance Criteria:**
- ✅ Workout detects program context
- ✅ Suggestions displayed with reasoning
- ✅ Week/phase context visible
- ✅ RPE prompt after workout
- ✅ RPE saved to workout model
- ✅ Next workout uses RPE for suggestions

---

### Sprint 2: Polish & Localization (Orta Öncelik)
**Süre:** 2-3 saat
**Hedef:** Production-ready polish

---

#### Task 2.1: Complete Localization ⏱️ 2-3 saat 🟡

**Yapılacaklar:**

**2.1.1: Enum displayName properties (45 dk)**
```swift
// antrain/Core/Domain/Models/Program/ProgramCategory.swift
extension ProgramCategory {
    var displayName: String {
        switch self {
        case .powerlifting:
            return String(localized: "Powerlifting", comment: "Program category")
        case .bodybuilding:
            return String(localized: "Bodybuilding", comment: "Program category")
        case .strengthTraining:
            return String(localized: "Strength Training", comment: "Program category")
        case .crossfit:
            return String(localized: "CrossFit", comment: "Program category")
        case .generalFitness:
            return String(localized: "General Fitness", comment: "Program category")
        case .sportSpecific:
            return String(localized: "Sport Specific", comment: "Program category")
        }
    }
}

// Repeat for DifficultyLevel, TrainingPhase, WeekProgressionPattern
```

**2.1.2: Programs views strings (1 saat)**
- ProgramsListView: All labels, buttons, empty states
- ProgramDetailView: Section headers, buttons
- CreateProgramFlow: All steps, validation messages
- WeekDetailView, DayDetailView: Labels

**2.1.3: Add Turkish translations (45 dk)**
```json
// Localizable.xcstrings
{
  "program.category.powerlifting": {
    "en": "Powerlifting",
    "tr": "Powerlifting"
  },
  "program.create.title": {
    "en": "Create Program",
    "tr": "Program Oluştur"
  },
  // ... add all strings
}
```

**2.1.4: Test (15 dk)**
- [ ] Switch device language to Turkish
- [ ] All program strings translated
- [ ] No hardcoded English strings visible
- [ ] Plurals handled correctly

**Dosyalar:**
- `antrain/Core/Domain/Models/Program/*.swift`
- `antrain/Features/Workouts/Programs/Views/**/*.swift`
- `antrain/Resources/Localizable.xcstrings`

---

#### Task 2.2: UI Polish & Edge Cases ⏱️ 1 saat 🟡

**2.2.1: Empty states (20 dk)**
- No active program state
- No programs in list
- No workout today (rest day)

**2.2.2: Loading states (20 dk)**
- Program list loading skeleton
- Program detail loading
- Suggestions loading indicator

**2.2.3: Error states (20 dk)**
- Program creation failed
- Activation failed
- Network/persistence errors

---

### Sprint 3: Testing (Düşük Öncelik)
**Süre:** 6-8 saat
**Hedef:** Production confidence

Bu sprint optional - time budget'a bağlı.

#### Task 3.1: Unit Tests ⏱️ 3-4 saat

**3.1.1: ProgressiveOverloadService tests**
- All RPE scenarios (1-6, 7-8, 9-10)
- Week modifier application
- No history handling
- Edge cases (negative RPE, invalid data)

**3.1.2: TrainingProgram validation tests**
- Valid program creation
- Invalid data rejection
- Relationship integrity

**3.1.3: UserProfile extension tests**
- getTodaysWorkout() date calculations
- Week progression logic
- Program activation/deactivation

#### Task 3.2: Integration Tests ⏱️ 2-3 saat

**3.2.1: Repository tests**
- CRUD operations
- Template usage checks
- Cascade deletes

**3.2.2: Program flow tests**
- Create → Activate → Start Workout → Complete
- Template deletion prevention
- Program deletion safety

#### Task 3.3: UI Tests ⏱️ 2-3 saat

**3.3.1: Critical flows**
- Program creation wizard (all 4 steps)
- Program activation
- Start workout from program
- Template deletion prevention

---

## 📅 ÖNERİLEN ÇALIŞMA SIRASI

### Minimum Viable Release (MVP)
**Süre:** 6-8 saat
**Sprint 1 - Kritik Features:**
1. Template Deletion Safety UI (2-3 saat) ← Veri güvenliği
2. Home Screen Integration (1-1.5 saat) ← Keşfedilebilirlik
3. Program Workout Flow (3-4 saat) ← Ana değer

**Sonuç:** Feature %95 complete, production-ready for early adopters

---

### Production Polish
**Süre:** +2-3 saat
**Sprint 2 - Polish:**
1. Localization (2-3 saat)

**Sonuç:** Feature %98 complete, full production-ready

---

### Full Testing Suite (Optional)
**Süre:** +6-8 saat
**Sprint 3 - Testing:**
1. Unit Tests (3-4 saat)
2. Integration Tests (2-3 saat)
3. UI Tests (2-3 saat)

**Sonuç:** Feature %100 complete, enterprise-grade quality

---

## 🎯 BAŞARILI BİR SPRINT İÇİN TAVSİYELER

### Önce Template Safety
Template deletion safety'yi ilk yap çünkü:
- Data integrity kritik
- Hızlı win (2-3 saat)
- Risk azaltır

### Sonra Home Integration
Home screen integration ikinci sırada çünkü:
- User engagement için önemli
- Hızlı (1-1.5 saat)
- Feature'ı görünür kılar

### En Son Workout Flow
Workout flow en sona çünkü:
- En uzun task (3-4 saat)
- Önceki ikisi olmadan da test edilebilir
- En karmaşık entegrasyon

### Test Strategy
- Her task'tan sonra manuel test yap
- Edge case'leri kontrol et
- Dark mode'da test et
- Different device sizes test et

### Git Strategy
```bash
# Her major task için ayrı branch
git checkout -b feature/template-deletion-safety
# Task complete → commit → push → merge

git checkout -b feature/home-screen-integration
# Task complete → commit → push → merge

git checkout -b feature/program-workout-flow
# Task complete → commit → push → merge
```

---

## 📈 İLERLEME TAKIBI

### Daily Checklist

**Gün 1 (3-4 saat):**
- [ ] Template deletion safety UI complete
- [ ] Manual testing done
- [ ] Git commit & push

**Gün 2 (4-5 saat):**
- [ ] Home screen integration complete
- [ ] Program workout flow 50% (ViewModel changes)
- [ ] Manual testing done
- [ ] Git commit & push

**Gün 3 (2-3 saat):**
- [ ] Program workout flow complete
- [ ] End-to-end testing
- [ ] Git commit & push
- [ ] MVP DONE! 🎉

**Gün 4 (Optional - 2-3 saat):**
- [ ] Localization complete
- [ ] Polish complete
- [ ] Production ready! 🚀

---

## 🚀 MVP SON KONTROL LİSTESİ

Şu feature'lar çalışıyor mu?

### Core Functionality
- [ ] Browse programs (preset + custom)
- [ ] Create custom program (4-step wizard)
- [ ] View program details (week/day navigation)
- [ ] Activate/deactivate program
- [ ] See active program on home screen
- [ ] Start workout from active program
- [ ] Get progressive overload suggestions
- [ ] Rate workout with RPE
- [ ] Next workout uses RPE for suggestions

### Data Integrity
- [ ] Template deletion prevented if used in programs
- [ ] Programs cascade delete (weeks → days)
- [ ] Template references intact after program delete
- [ ] No orphaned data

### UX Polish
- [ ] Loading states smooth
- [ ] Error messages clear
- [ ] Empty states helpful
- [ ] Dark mode working
- [ ] Navigation intuitive

### Technical Health
- [ ] No crashes
- [ ] No memory leaks
- [ ] Build successful
- [ ] No compiler warnings
- [ ] SwiftData operations fast (<100ms)

---

## 📞 İLETİŞİM & DESTEK

**Documentation:**
- Architecture: `docs/v2/TRAINING_PROGRAMS.md`
- Implementation: `docs/v2/IMPLEMENTATION_PLAN.md`
- API: `docs/v2/API_DESIGN.md`
- Status: `.serena/memories/training_programs_implementation_status.md`

**Need Help?**
- Backend issues → Check TrainingProgramRepository
- UI issues → Check ProgramsListViewModel
- Integration → Check ActiveWorkoutManager
- Suggestions → Check ProgressiveOverloadService

---

**Hazırlayan:** Claude Code
**Versiyon:** 1.0
**Son Güncelleme:** 2025-11-06

**Başarılar! 🚀**
