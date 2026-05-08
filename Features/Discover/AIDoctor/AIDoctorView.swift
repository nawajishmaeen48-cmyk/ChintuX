import SwiftUI

/// AI Pet Doctor — a real-time chat with a senior veterinarian.
/// Feels like a professional medical consultation, not a chatbot.
/// Clean, warm, trustworthy — no green anywhere.
struct AIDoctorView: View {
    @EnvironmentObject var petContext: PetContextStore
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var tabBarVisibility: TabBarVisibility

    @State private var prompt: String = ""
    @State private var messages: [DoctorMessage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var isPromptFocused: Bool

    private var activePet: PetDTO? {
        dataStore.pets.first(where: { $0.id == petContext.activePetID }) ?? dataStore.pets.first
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Spacing.m) {
                        welcomeHeader
                            .id("welcome")

                        if messages.isEmpty {
                            examplePrompts
                                .id("prompts")
                        }

                        ForEach(messages) { msg in
                            messageView(msg)
                                .id(msg.id)
                        }

                        if isLoading {
                            thinkingView
                                .id("loading")
                        }

                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.m)
                    .padding(.bottom, Spacing.m)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { _, _ in
                    withAnimation(Motion.softEaseOut) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: isLoading) { _, loading in
                    if loading {
                        withAnimation(Motion.softEaseOut) {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }
            .background(PawlyColors.canvas.ignoresSafeArea())

            composer
        }
        .navigationTitle("Pet Doctor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(PawlyColors.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { tabBarVisibility.hide() }
        .onDisappear { tabBarVisibility.show() }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(PawlyColors.navySoft)
                    .frame(width: 44, height: 44)
                Image(systemName: "stethoscope")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(PawlyColors.navy)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Dr. Pawly")
                        .font(PawlyFont.headingMedium)
                        .foregroundStyle(PawlyColors.ink)
                    Text("Online")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(PawlyColors.sageSoft))
                        .foregroundStyle(PawlyColors.sage)
                }
                Text("Senior vet, here to help. What's going on with \(activePet?.name ?? "your pet")?")
                    .font(PawlyFont.bodyMedium)
                    .foregroundStyle(PawlyColors.slate)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Example Prompts

    private var examplePrompts: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Common concerns")
                .font(PawlyFont.overline)
                .foregroundStyle(PawlyColors.slate)
                .textCase(.uppercase)

            ForEach(suggestionPrompts, id: \.self) { suggestion in
                Button {
                    prompt = suggestion
                    isPromptFocused = true
                    Haptics.light()
                } label: {
                    HStack {
                        Text(suggestion)
                            .font(PawlyFont.bodyMedium)
                            .foregroundStyle(PawlyColors.ink)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(PawlyColors.navy)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                            .fill(PawlyColors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                            .stroke(PawlyColors.hairline, lineWidth: 0.75)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var suggestionPrompts: [String] {
        let name = activePet?.name ?? "my pet"
        return [
            "\(name) has been vomiting since this morning",
            "Scratching ears constantly for 2 days",
            "Not eating properly, seems lethargic",
            "Limping on the back leg"
        ]
    }

    // MARK: - Message View

    @ViewBuilder
    private func messageView(_ msg: DoctorMessage) -> some View {
        switch msg.kind {
        case .user(let text):
            userBubble(text)

        case .doctor(let response):
            doctorCard(response)
        }
    }

    // MARK: - User Bubble

    private func userBubble(_ text: String) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                Spacer(minLength: 60)
                Text(text)
                    .font(PawlyFont.bodyMedium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(PawlyColors.navy)
                    )
            }
            Text(Date(), format: .dateTime.hour().minute())
                .font(PawlyFont.captionSmall)
                .foregroundStyle(PawlyColors.slate.opacity(0.6))
                .padding(.trailing, 8)
        }
    }

    // MARK: - Doctor Card

    private func doctorCard(_ response: DoctorResponse) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(PawlyColors.navySoft)
                        .frame(width: 32, height: 32)
                    Image(systemName: "stethoscope")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(PawlyColors.navy)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Dr. Pawly")
                        .font(PawlyFont.bodyMedium.weight(.semibold))
                        .foregroundStyle(PawlyColors.ink)
                    Text("Senior Veterinary Consultant")
                        .font(PawlyFont.captionSmall)
                        .foregroundStyle(PawlyColors.slate)
                }

                Spacer()

                urgencyBadge(response.urgency)
            }
            .padding(Spacing.m)

            Divider()
                .background(PawlyColors.hairline)

            // Body sections
            VStack(alignment: .leading, spacing: 0) {
                // Diagnosis
                if !response.diagnosis.isEmpty {
                    sectionBlock(
                        title: "Assessment",
                        icon: "list.clipboard",
                        iconColor: PawlyColors.coral,
                        titleColor: PawlyColors.coral,
                        items: response.diagnosis
                    )
                }

                // Recommendations
                if !response.recommendations.isEmpty {
                    sectionBlock(
                        title: "Recommendations",
                        icon: "checkmark.seal",
                        iconColor: PawlyColors.sage,
                        titleColor: PawlyColors.sage,
                        items: response.recommendations
                    )
                }

                // Prescription / medicines
                if !response.medicines.isEmpty {
                    sectionBlock(
                        title: "Supportive Care",
                        icon: "pills.fill",
                        iconColor: PawlyColors.lavender,
                        titleColor: PawlyColors.lavender,
                        items: response.medicines
                    )
                }

                // Notes
                if !response.notes.isEmpty {
                    sectionBlock(
                        title: "Important Notes",
                        icon: "exclamationmark.circle",
                        iconColor: PawlyColors.amber,
                        titleColor: PawlyColors.amber,
                        items: response.notes
                    )
                }

                // Escalation
                if response.urgency == .vetNow || response.urgency == .vetWithin24h {
                    escalationBox(response.urgency)
                }
            }

            // Disclaimer
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(PawlyColors.slate.opacity(0.6))
                Text("This is AI-assisted guidance. Always consult your local vet for a definitive diagnosis.")
                    .font(PawlyFont.captionSmall)
                    .foregroundStyle(PawlyColors.slate.opacity(0.6))
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(PawlyColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .stroke(PawlyColors.hairline, lineWidth: 0.75)
        )
        .shadow(color: PawlyColors.shadowWarm, radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private func sectionBlock(
        title: String,
        icon: String,
        iconColor: Color,
        titleColor: Color,
        items: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(PawlyFont.overline)
                    .foregroundStyle(titleColor)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.top, Spacing.m)
            .padding(.bottom, 8)

            // Items
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(iconColor)
                        .frame(width: 5, height: 5)
                        .padding(.top, 8)
                    Text(item)
                        .font(PawlyFont.bodyMedium)
                        .foregroundStyle(PawlyColors.ink)
                }
                .padding(.horizontal, Spacing.m)
                .padding(.bottom, 4)
            }
        }
    }

    private func urgencyBadge(_ urgency: DoctorUrgency) -> some View {
        let color: Color
        let icon: String
        let text: String

        switch urgency {
        case .vetNow:
            color = PawlyColors.alert; icon = "exclamationmark.triangle.fill"; text = "See Vet"
        case .vetWithin24h:
            color = PawlyColors.amber; icon = "clock.fill"; text = "Soon"
        case .watchAtHome:
            color = PawlyColors.sage; icon = "checkmark"; text = "Monitor"
        }

        return HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(text)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(color.opacity(0.15)))
    }

    private func escalationBox(_ urgency: DoctorUrgency) -> some View {
        let color = urgency == .vetNow ? PawlyColors.alert : PawlyColors.amber
        let message = urgency == .vetNow
            ? "This appears to be a medical emergency. Please see a vet immediately."
            : "Please schedule a vet visit within 24 hours if symptoms persist or worsen."

        return HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)

            Text(message)
                .font(PawlyFont.bodyMedium)
                .foregroundStyle(color)
        }
        .padding(Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                .fill(color.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                .stroke(color.opacity(0.25), lineWidth: 0.75)
        )
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.m)
    }

    // MARK: - Thinking View

    private var thinkingView: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(PawlyColors.navySoft)
                    .frame(width: 32, height: 32)
                Image(systemName: "stethoscope")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PawlyColors.navy)
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(PawlyColors.slate.opacity(0.4))
                        .frame(width: 7, height: 7)
                        .scaleEffect(isLoading ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(i) * 0.15),
                            value: isLoading
                        )
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
                    .stroke(PawlyColors.hairline, lineWidth: 0.75)
            )

            Spacer(minLength: 0)
        }
    }

    // MARK: - Composer

    private var composer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(PawlyColors.divider)
                .frame(height: 0.5)

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Describe symptoms…",
                          text: $prompt,
                          axis: .vertical)
                    .font(PawlyFont.bodyMedium)
                    .foregroundStyle(PawlyColors.ink)
                    .lineLimit(1...5)
                    .focused($isPromptFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(PawlyColors.canvas)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(PawlyColors.hairline, lineWidth: 0.75)
                    )
                    .onSubmit { send() }

                Button { send() } label: {
                    Image(systemName: isLoading ? "stop.fill" : "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(canSend ? PawlyColors.navy : PawlyColors.slate.opacity(0.35))
                        )
                }
                .disabled(!canSend)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(PawlyColors.surface)
        }
    }

    private var canSend: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    // MARK: - Send

    private func send() {
        let text = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        Haptics.light()
        prompt = ""

        let userMsg = DoctorMessage(kind: .user(text))
        withAnimation(Motion.softEaseOut) { messages.append(userMsg) }

        isLoading = true
        errorMessage = nil

        Task {
            let response = await GroqService.respond(
                to: text,
                petName: activePet?.name ?? "your pet"
            )

            let doctorResponse = DoctorResponse(from: response)
            let doctorMsg = DoctorMessage(kind: .doctor(doctorResponse))

            await MainActor.run {
                withAnimation(Motion.softEaseOut) {
                    messages.append(doctorMsg)
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Doctor Models

struct DoctorMessage: Identifiable {
    enum Kind {
        case user(String)
        case doctor(DoctorResponse)
    }
    let id = UUID()
    let kind: Kind
    let timestamp: Date = .now
}

struct DoctorResponse {
    let diagnosis: [String]
    let recommendations: [String]
    let medicines: [String]
    let notes: [String]
    let urgency: DoctorUrgency

    init(from triage: TriageResponse) {
        self.diagnosis = triage.whatMightBeHappening
        self.recommendations = triage.whatYouCanDoNow
        self.medicines = []  // AI doesn't prescribe specific medicines
        self.notes = triage.whenToEscalate

        switch triage.urgency {
        case .watchAtHome: self.urgency = .watchAtHome
        case .vetWithin24h: self.urgency = .vetWithin24h
        case .vetNow: self.urgency = .vetNow
        }
    }
}

enum DoctorUrgency {
    case watchAtHome, vetWithin24h, vetNow
}

// MARK: - Previews

#Preview("AI Doctor") {
    NavigationStack { AIDoctorView() }
        .environmentObject(PreviewSupport.previewPetContext)
        .environmentObject(DataStore.shared)
        .environmentObject(TabBarVisibility())
}