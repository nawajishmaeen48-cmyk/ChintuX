import SwiftUI

/// Floating tab bar. Restrained glass effect. Center action for Quick Log.
struct MainTabView: View {
    enum Tab: Hashable { case home, calendar, discover, pets }

    @State private var selected: Tab = .home
    @State private var showingQuickLog = false
    @StateObject private var tabBarVisibility = TabBarVisibility()

    var body: some View {
        ZStack {
            PawlyColors.canvas.ignoresSafeArea()

            Group {
                switch selected {
                case .home:     NavigationStack { HomeView() }
                case .calendar: NavigationStack { CalendarView() }
                case .discover: DiscoverView()
                case .pets:     PetsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating tab bar at bottom
            VStack {
                Spacer()
                if tabBarVisibility.isVisible {
                    PawlyTabBar(selected: $selected,
                                onAddTap: { showingQuickLog = true })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .environmentObject(tabBarVisibility)
        .sheet(isPresented: $showingQuickLog) {
            QuickLogSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Tab Bar

struct PawlyTabBar: View {
    @Binding var selected: MainTabView.Tab
    var onAddTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tab(.home,     symbol: "house",          label: "Home")
            tab(.calendar, symbol: "calendar",       label: "Calendar")
            addButton
            tab(.discover, symbol: "sparkles",       label: "Discover")
            tab(.pets,     symbol: "pawprint",       label: "Pets")
        }
        .padding(.horizontal, 6)
        .frame(height: 60)
        .background(
            ZStack {
                // Deep blur + subtle tint
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(PawlyColors.surface.opacity(0.4))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(PawlyColors.hairline.opacity(0.6), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func tab(_ tab: MainTabView.Tab,
                     symbol: String,
                     label: String) -> some View {
        let isSelected = selected == tab
        Button {
            Haptics.light()
            withAnimation(Motion.snap) { selected = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: isSelected ? symbol + ".fill" : symbol)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? PawlyColors.forest : PawlyColors.slate.opacity(0.6))
                    .symbolRenderingMode(.hierarchical)
                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? PawlyColors.forest : PawlyColors.slate.opacity(0.5))
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var addButton: some View {
        Button {
            Haptics.medium()
            onAddTap()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [PawlyColors.navy, PawlyColors.navy.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: PawlyColors.forest.opacity(0.3), radius: 10, x: 0, y: 5)
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 56, height: 56)
            .offset(y: -10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Quick log")
    }
}

#Preview("Main") {
    MainTabView()
        .environmentObject(PreviewSupport.previewPetContext)
        .modelContainer(PreviewSupport.container)
}
