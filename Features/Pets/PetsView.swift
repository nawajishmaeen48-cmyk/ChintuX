import SwiftUI

/// Pets tab — editorial list with clear hierarchy.
/// Active pets first. Lost and memorial sections when present.
struct PetsView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var petContext: PetContextStore
    @EnvironmentObject var authService: AuthService
    @State private var showingAdd = false
    @State private var confirmSignOut = false

    private var active: [PetDTO] { dataStore.pets.filter { $0.statusRaw == "active" } }
    private var memorial: [PetDTO] { dataStore.pets.filter { $0.statusRaw == "passed" } }
    private var lost: [PetDTO] { dataStore.pets.filter { $0.statusRaw == "lost" } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your pets")
                            .font(PawlyFont.displayLarge)
                            .foregroundStyle(PawlyColors.ink)
                        Text(active.count == 0
                             ? "Add your first pet to get started."
                             : "Tap a pet to manage their care.")
                            .font(PawlyFont.bodyLarge)
                            .foregroundStyle(PawlyColors.slate)
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.m)
                    .padding(.bottom, Spacing.xl)

                    // Active pets
                    VStack(spacing: 12) {
                        ForEach(active) { pet in
                            NavigationLink(destination: PetProfileViewDTO(pet: pet)) {
                                PetListRowDTO(pet: pet, active: pet.id == petContext.activePetID)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open \(pet.name)'s profile")
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)

                    // Lost section
                    if !lost.isEmpty {
                        PetSectionHeader(title: "Lost", color: PawlyColors.alert)
                            .padding(.horizontal, Spacing.screenHorizontal)
                            .padding(.top, Spacing.xl)
                            .padding(.bottom, Spacing.m)

                        VStack(spacing: 12) {
                            ForEach(lost) { pet in
                                NavigationLink(destination: PetProfileViewDTO(pet: pet)) {
                                    PetListRowDTO(pet: pet, active: false, badge: "Lost")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Spacing.screenHorizontal)
                    }

                    // Memorial section
                    if !memorial.isEmpty {
                        PetSectionHeader(title: "In memory", color: PawlyColors.slate)
                            .padding(.horizontal, Spacing.screenHorizontal)
                            .padding(.top, Spacing.xl)
                            .padding(.bottom, Spacing.m)

                        VStack(spacing: 12) {
                            ForEach(memorial) { pet in
                                NavigationLink(destination: PetProfileViewDTO(pet: pet)) {
                                    PetListRowDTO(pet: pet, active: false, badge: "Memorial")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Spacing.screenHorizontal)
                    }

                    // Free tier indicator
                    if active.count < 5 {
                        HStack(spacing: 6) {
                            Text("\(active.count) of 5 pets on free plan")
                                .font(PawlyFont.captionSmall)
                                .foregroundStyle(PawlyColors.slate.opacity(0.7))
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.screenHorizontal)
                        .padding(.top, Spacing.xl)
                    }

                    // Sign out row
                    Button {
                        confirmSignOut = true
                    } label: {
                        HStack(spacing: Spacing.m) {
                            Image(systemName: "arrow.backward.square")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(PawlyColors.alert)
                            Text("Sign Out")
                                .font(PawlyFont.bodyMedium.weight(.semibold))
                                .foregroundStyle(PawlyColors.alert)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                                .fill(PawlyColors.alertSoft)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                                .stroke(PawlyColors.alert.opacity(0.18), lineWidth: 0.75)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.xl)

                    Color.clear.frame(height: Spacing.xxl)
                }
            }
            .scrollIndicators(.hidden)
            .background(PawlyColors.canvas.ignoresSafeArea())
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            guard active.count < 5 else { return }
                            showingAdd = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(PawlyColors.forest)
                        }
                        .disabled(active.count >= 5)

                        Menu {
                            Button(role: .destructive) {
                                confirmSignOut = true
                            } label: {
                                Label("Sign Out", systemImage: "arrow.backward.square")
                            }
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 18))
                                .foregroundStyle(PawlyColors.slate)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                OnboardingCoordinator(onComplete: { showingAdd = false })
                    .interactiveDismissDisabled(false)
            }
            .refreshable {
                await dataStore.fetchAllData()
            }
            .alert("Sign Out?", isPresented: $confirmSignOut) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task { await authService.signOut() }
                }
            } message: {
                Text("You'll need to sign in again to access your pets.")
            }
        }
    }
}

// MARK: - Section Header

private struct PetSectionHeader: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(PawlyFont.overline)
            .foregroundStyle(color)
            .textCase(.uppercase)
    }
}

// MARK: - Pet List Row

struct PetListRowDTO: View {
    let pet: PetDTO
    var active: Bool
    var badge: String? = nil
    @EnvironmentObject var petContext: PetContextStore

    var body: some View {
        HStack(spacing: Spacing.m) {
            PetAvatarDTO(pet: pet, size: 56)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(pet.name)
                        .font(PawlyFont.headingSmall)
                        .foregroundStyle(PawlyColors.ink)

                    if active {
                        Text("Active")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(PawlyColors.forest))
                            .foregroundStyle(.white)
                    }

                    if let badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(PawlyColors.slate.opacity(0.12)))
                            .foregroundStyle(PawlyColors.slate)
                    }
                }

                Text(petSubtitle)
                    .font(PawlyFont.caption)
                    .foregroundStyle(PawlyColors.slate)
            }

            Spacer()

            Button {
                Haptics.medium()
                petContext.setActive(pet)
            } label: {
                Image(systemName: active ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(active ? PawlyColors.forest : PawlyColors.slate.opacity(0.3))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(active ? "Currently active" : "Set as active")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(PawlyColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .stroke(active ? PawlyColors.forest.opacity(0.2) : PawlyColors.hairline,
                        lineWidth: active ? 1 : 0.75)
        )
    }

    private var petSubtitle: String {
        let species = Species(rawValue: pet.speciesRaw)?.displayName ?? pet.speciesRaw
        let breed = pet.breed.isEmpty ? "Mixed" : pet.breed
        return "\(species)  ·  \(breed)  ·  \(ageDescription)"
    }

    private var ageDescription: String {
        guard let dob = pet.dateOfBirth else { return "Age unknown" }
        let comps = Calendar.current.dateComponents([.year, .month], from: dob, to: .now)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        if y == 0 { return "\(max(0, m))mo" }
        if m == 0 { return "\(y)y" }
        return "\(y)y \(m)mo"
    }
}

#Preview("Pets") {
    PetsView()
        .environmentObject(PetContextStore())
        .environmentObject(DataStore.shared)
}
