import SwiftUI

/// Simplified, focused home screen.
/// The pet's identity is the anchor. Everything else is just quick access.
struct HomeView: View {
    @EnvironmentObject var petContext: PetContextStore
    @EnvironmentObject var dataStore: DataStore

    var activePet: PetDTO? {
        dataStore.pets.first(where: { $0.id == petContext.activePetID }) ?? dataStore.pets.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.m)
                    .padding(.bottom, Spacing.l)

                if let pet = activePet {
                    // 1. Pet Hero
                    PetHeroSection(pet: pet)
                        .padding(.horizontal, Spacing.screenHorizontal)
                        .padding(.bottom, Spacing.xl)

                    // 2. Today's Activity (what's already logged today)
                    TodayActivitySection(pet: pet)
                        .padding(.horizontal, Spacing.screenHorizontal)
                        .padding(.bottom, Spacing.xl)

                    // 3. Quick Actions (one-tap to log common things)
                    QuickActionsSection(pet: pet)
                        .padding(.horizontal, Spacing.screenHorizontal)
                        .padding(.bottom, Spacing.xl)

                    // 4. Upcoming Reminders (next 3)
                    UpcomingRemindersSection(pet: pet)
                        .padding(.horizontal, Spacing.screenHorizontal)
                        .padding(.bottom, Spacing.xl)

                } else {
                    EmptyState()
                        .padding(.top, Spacing.xxl)
                        .frame(maxWidth: .infinity)
                }

                Color.clear.frame(height: Spacing.xxl)
            }
        }
        .background(PawlyColors.canvas.ignoresSafeArea())
        .scrollIndicators(.hidden)
        .refreshable { await dataStore.fetchAllData() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(PawlyFont.overline)
                    .foregroundStyle(PawlyColors.slate)
                    .textCase(.uppercase)
                Text(activePet?.name ?? "Welcome")
                    .font(PawlyFont.displaySmall)
                    .foregroundStyle(PawlyColors.ink)
            }
            Spacer()
            PetSwitcherCarousel(pets: dataStore.pets)
        }
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Good night"
        }
    }
}

// MARK: - Pet Hero Section

private struct PetHeroSection: View {
    let pet: PetDTO
    @EnvironmentObject var dataStore: DataStore

    private var latestMood: Mood? {
        guard let raw = dataStore.moodEntries(forPetId: pet.id).first?.moodRaw else { return nil }
        return Mood(rawValue: raw)
    }

    var body: some View {
        HStack(spacing: Spacing.m) {
            PetAvatarDTO(pet: pet, size: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(PawlyFont.headingLarge)
                    .foregroundStyle(PawlyColors.ink)

                Text(petSubtitle)
                    .font(PawlyFont.bodyMedium)
                    .foregroundStyle(PawlyColors.slate)

                HStack(spacing: 6) {
                    if let mood = latestMood {
                        Text("\(mood.emoji) \(mood.label)")
                            .font(PawlyFont.caption)
                            .foregroundStyle(PawlyColors.inkMuted)
                    }
                    if let weight = pet.weightKg {
                        Text("· \(String(format: "%.1f", weight)) kg")
                            .font(PawlyFont.caption)
                            .foregroundStyle(PawlyColors.slate)
                    }
                }
            }

            Spacer()

            MoodPicker(pet: pet, current: latestMood)
        }
        .padding(Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(PawlyColors.surface)
        )
        .shadow(color: PawlyColors.shadowWarm, radius: 12, x: 0, y: 4)
    }

    private var petSubtitle: String {
        let species = Species(rawValue: pet.speciesRaw)?.displayName ?? pet.speciesRaw
        let breed = pet.breed.isEmpty ? "Mixed" : pet.breed
        return "\(species) · \(breed)"
    }
}

// MARK: - Mood Picker

private struct MoodPicker: View {
    let pet: PetDTO
    let current: Mood?

    var body: some View {
        Menu {
            ForEach(Mood.allCases) { m in
                Button {
                    Haptics.light()
                    Task { await DataStore.shared.createMoodEntry(forPetId: pet.id, mood: m) }
                } label: {
                    Text("\(m.emoji)  \(m.label)")
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(PawlyColors.navySoft)
                    .frame(width: 44, height: 44)
                Text(current?.emoji ?? "🙂")
                    .font(.system(size: 22))
            }
        }
    }
}

// MARK: - Today's Activity

private struct TodayActivitySection: View {
    let pet: PetDTO
    @EnvironmentObject var dataStore: DataStore

    private var todayEntries: [LogEntryDTO] {
        let s = Date().startOfDay, e = Date().endOfDay
        return dataStore.logEntries(forPetId: pet.id)
            .filter { $0.at >= s && $0.at <= e }
            .sorted { $0.at > $1.at }
    }

    private var summaryItems: [(icon: String, color: Color, label: String, count: Int)] {
        let meals   = todayEntries.filter { $0.kindRaw == LogKind.meal.rawValue }.count
        let walks   = todayEntries.filter { $0.kindRaw == LogKind.walk.rawValue }.count
        let meds    = todayEntries.filter { $0.kindRaw == LogKind.medication.rawValue }.count
        let hygiene = todayEntries.filter { $0.kindRaw == LogKind.hygiene.rawValue }.count
        return [
            ("fork.knife",   PawlyColors.coral,  "Meals",      meals),
            ("figure.walk",  PawlyColors.sky,    "Walks",      walks),
            ("pills.fill",   PawlyColors.lavender, "Meds",   meds),
            ("drop.fill",    PawlyColors.sage,   "Care",       hygiene),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Today")
                .font(PawlyFont.overline)
                .foregroundStyle(PawlyColors.slate)
                .textCase(.uppercase)

            HStack(spacing: Spacing.s) {
                ForEach(summaryItems, id: \.label) { item in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(item.color.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: item.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(item.color)
                        }
                        Text("\(item.count)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(PawlyColors.ink)
                        Text(item.label)
                            .font(PawlyFont.captionSmall)
                            .foregroundStyle(PawlyColors.slate)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.s)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                            .fill(PawlyColors.surface)
                    )
                }
            }
        }
    }
}

// MARK: - Quick Actions (Chat Style)

private struct QuickActionsSection: View {
    let pet: PetDTO
    @EnvironmentObject var dataStore: DataStore

    private let tasks: [CareTaskType] = [
        .morningMeal, .eveningMeal, .walk, .freshWater, .medication, .playTime
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Quick log")
                .font(PawlyFont.overline)
                .foregroundStyle(PawlyColors.slate)
                .textCase(.uppercase)

            VStack(spacing: 8) {
                ForEach(tasks) { task in
                    ChatActionTile(task: task, pet: pet)
                }
            }
        }
    }
}

private struct ChatActionTile: View {
    let task: CareTaskType
    let pet: PetDTO
    @EnvironmentObject var dataStore: DataStore

    private var countToday: Int {
        let s = Date().startOfDay, e = Date().endOfDay
        return dataStore.logEntries(forPetId: pet.id)
            .filter {
                $0.kindRaw == task.logKind.rawValue &&
                $0.at >= s && $0.at <= e &&
                $0.detail == task.displayName
            }
            .count
    }

    private var done: Bool { countToday > 0 }

    var body: some View {
        Button {
            Haptics.light()
            Task {
                await dataStore.createLogEntry(
                    forPetId: pet.id,
                    kind: task.logKind,
                    detail: task.displayName
                )
            }
        } label: {
            HStack(spacing: 10) {
                // Avatar (assistant = paw)
                ZStack {
                    Circle().fill(PawlyColors.navySoft).frame(width: 36, height: 36)
                    Image(systemName: done ? "checkmark" : task.sfSymbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(done ? PawlyColors.sage : PawlyColors.navy)
                }
                .frame(width: 36, height: 36)

                // Message content
                VStack(alignment: .leading, spacing: 2) {
                    if done {
                        Text("\(task.displayName) logged")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(PawlyColors.ink)
                        Text("\(countToday)x today")
                            .font(PawlyFont.caption)
                            .foregroundStyle(PawlyColors.sage)
                    } else {
                        Text(task.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(PawlyColors.ink)
                        Text("Tap to log")
                            .font(PawlyFont.caption)
                            .foregroundStyle(PawlyColors.slate.opacity(0.5))
                    }
                }

                Spacer()

                // Status indicator
                if done {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(PawlyColors.sage)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(PawlyColors.slate.opacity(0.25))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PawlyColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(PawlyColors.hairline, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Today's To-Do List

private struct UpcomingRemindersSection: View {
    let pet: PetDTO
    @EnvironmentObject var dataStore: DataStore

    private var todolist: [ReminderInstanceDTO] {
        dataStore.reminderInstancesToday(forPetId: pet.id)
    }

    private var overdue: [ReminderInstanceDTO] {
        todolist.filter { $0.statusRaw == "upcoming" && $0.scheduledAt < .now }
    }

    private var upcoming: [ReminderInstanceDTO] {
        todolist.filter { $0.statusRaw == "upcoming" && $0.scheduledAt >= .now }
    }

    private var completed: [ReminderInstanceDTO] {
        todolist.filter { $0.statusRaw == "completed" }
    }

    private var isEmpty: Bool {
        todolist.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                Text("Today")
                    .font(PawlyFont.overline)
                    .foregroundStyle(PawlyColors.slate)
                    .textCase(.uppercase)
                Spacer()
                if !isEmpty {
                    Text("\(completed.count)/\(todolist.count) done")
                        .font(PawlyFont.caption)
                        .foregroundStyle(PawlyColors.slate)
                }
            }

            if isEmpty {
                // Empty state
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(PawlyColors.sageSoft).frame(width: 44, height: 44)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(PawlyColors.sage)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("All clear for today!")
                            .font(PawlyFont.bodyMedium)
                            .foregroundStyle(PawlyColors.ink)
                        Text("Add reminders in the Calendar tab")
                            .font(PawlyFont.caption)
                            .foregroundStyle(PawlyColors.slate)
                    }
                    Spacer()
                }
                .padding(Spacing.m)
                .background(
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .fill(PawlyColors.surface)
                )
            } else {
                VStack(spacing: 6) {
                    // Overdue section
                    if !overdue.isEmpty {
                        TodoSectionHeader(title: "Overdue", count: overdue.count, color: PawlyColors.alert)
                        ForEach(overdue) { inst in
                            TodoItemRow(instance: inst, style: .overdue) {
                                toggle(inst)
                            }
                        }
                    }

                    // To-do section
                    if !upcoming.isEmpty {
                        TodoSectionHeader(title: "To do", count: upcoming.count, color: PawlyColors.forest)
                        ForEach(upcoming) { inst in
                            TodoItemRow(instance: inst, style: .pending) {
                                toggle(inst)
                            }
                        }
                    }

                    // Done section (collapsible)
                    if !completed.isEmpty {
                        CollapsibleDoneSection(instances: completed) {
                            for inst in completed { toggle(inst) }
                        }
                    }
                }
            }
        }
    }

    private func toggle(_ inst: ReminderInstanceDTO) {
        Haptics.success()
        Task { await dataStore.toggleReminderInstance(inst) }
    }
}

private struct TodoSectionHeader: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(PawlyColors.slate)
                .textCase(.uppercase)
            Text("\(count)")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule().fill(color.opacity(0.12))
                )
        }
        .padding(.top, Spacing.xs)
    }
}

private enum TodoItemStyle {
    case overdue, pending, completed
}

private struct TodoItemRow: View {
    let instance: ReminderInstanceDTO
    let style: TodoItemStyle
    let onToggle: () -> Void

    @EnvironmentObject var dataStore: DataStore

    private var reminder: ReminderDTO? {
        dataStore.reminders.first { $0.id == instance.reminderId }
    }

    private var type: ReminderType? {
        guard let r = reminder else { return nil }
        return ReminderType(rawValue: r.typeRaw)
    }

    private var timeStr: String {
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        return f.string(from: instance.scheduledAt)
    }

    private var bgColor: Color {
        switch style {
        case .overdue: return PawlyColors.alertSoft.opacity(0.4)
        case .pending: return PawlyColors.surface
        case .completed: return PawlyColors.surface
        }
    }

    private var iconBgColor: Color {
        switch style {
        case .overdue: return PawlyColors.alertSoft
        case .pending: return PawlyColors.navySoft
        case .completed: return PawlyColors.sage.opacity(0.12)
        }
    }

    private var iconColor: Color {
        switch style {
        case .overdue: return PawlyColors.alert
        case .pending: return PawlyColors.navy
        case .completed: return PawlyColors.sage
        }
    }

    var body: some View {
        HStack(spacing: Spacing.s) {
            ZStack {
                Circle()
                    .fill(iconBgColor)
                    .frame(width: 36, height: 36)
                if style == .completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(iconColor)
                } else {
                    Image(systemName: type?.sfSymbol ?? "bell.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(iconColor)
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(reminder?.title ?? "Reminder")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style == .completed ? PawlyColors.slate : PawlyColors.ink)
                    .strikethrough(style == .completed, color: PawlyColors.slate)
                HStack(spacing: 4) {
                    Text(timeStr)
                        .font(PawlyFont.caption)
                        .foregroundStyle(PawlyColors.slate)
                    if style == .overdue {
                        Text("Overdue")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(PawlyColors.alert)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(
                                Capsule().fill(PawlyColors.alertSoft)
                            )
                    }
                }
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: style == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(style == .completed ? PawlyColors.sage : PawlyColors.slate.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                .stroke(style == .overdue ? PawlyColors.alert.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

private struct CollapsibleDoneSection: View {
    let instances: [ReminderInstanceDTO]
    let onUncheckAll: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(Motion.snap) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Circle().fill(PawlyColors.sage).frame(width: 6, height: 6)
                    Text("Done")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(PawlyColors.slate)
                        .textCase(.uppercase)
                    Text("\(instances.count)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(PawlyColors.sage)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(PawlyColors.sage.opacity(0.12))
                        )
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(PawlyColors.slate.opacity(0.5))
                }
                .padding(.top, Spacing.xs)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(instances) { inst in
                        TodoItemRow(instance: inst, style: .completed) {
                            onUncheckAll()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Empty State

private struct EmptyState: View {
    var body: some View {
        VStack(spacing: Spacing.m) {
            ZStack {
                Circle()
                    .fill(PawlyColors.navySoft)
                    .frame(width: 80, height: 80)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(PawlyColors.navy)
            }
            VStack(spacing: 6) {
                Text("No pets yet")
                    .font(PawlyFont.headingLarge)
                    .foregroundStyle(PawlyColors.ink)
                Text("Add your first pet to get started.")
                    .font(PawlyFont.bodyMedium)
                    .foregroundStyle(PawlyColors.slate)
            }
        }
        .padding(.vertical, Spacing.xxl)
    }
}

// MARK: - Shared Components

struct PetAvatarDTO: View {
    let pet: PetDTO
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            if let photoURL = pet.photoURL,
               let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(hex: pet.accentHex)
                }
            } else {
                Color(hex: pet.accentHex)
                    .overlay(
                        Text(Species(rawValue: pet.speciesRaw)?.emoji ?? "🐾")
                            .font(.system(size: size * 0.4))
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: PawlyColors.shadowWarm, radius: 6, x: 0, y: 3)
    }
}

// MARK: - Care Task Type

/// Unique task types — each maps to a LogKind but has its own identity.
enum CareTaskType: String, Codable, CaseIterable, Identifiable {
    case morningMeal   = "morningMeal"
    case eveningMeal   = "eveningMeal"
    case walk          = "walk"
    case freshWater    = "freshWater"
    case medication    = "medication"
    case playTime      = "playTime"
    case brush         = "brush"
    case bathroom      = "bathroom"

    var id: String { rawValue }

    var logKind: LogKind {
        switch self {
        case .morningMeal, .eveningMeal, .playTime: return .meal
        case .walk:               return .walk
        case .medication:        return .medication
        case .freshWater, .brush, .bathroom: return .hygiene
        }
    }

    var displayName: String {
        switch self {
        case .morningMeal: return "Morning meal"
        case .eveningMeal: return "Evening meal"
        case .walk:        return "Walk"
        case .freshWater: return "Fresh water"
        case .medication:  return "Medication"
        case .playTime:    return "Play time"
        case .brush:       return "Brush"
        case .bathroom:    return "Bathroom"
        }
    }

    var sfSymbol: String {
        switch self {
        case .morningMeal: return "sunrise.fill"
        case .eveningMeal: return "moon.fill"
        case .walk:        return "figure.walk"
        case .freshWater:  return "drop.fill"
        case .medication:  return "pills.fill"
        case .playTime:    return "tennisball.fill"
        case .brush:       return "sparkles"
        case .bathroom:    return "leaf.fill"
        }
    }
}

// MARK: - Previews

#Preview("Home") {
    NavigationStack { HomeView() }
        .environmentObject(PetContextStore())
        .environmentObject(DataStore.shared)
}