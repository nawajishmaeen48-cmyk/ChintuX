import SwiftUI

// MARK: - App Card

/// Standard card: white surface, warm shadow, no borders.
/// Used as the base card for most content sections.
struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(PawlyColors.surface)
                    .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
            )
    }
}

// MARK: - App Badge

/// Compact pill badge with colored tint.
struct AppBadge: View {
    let text: String
    let color: Color
    var textColor: Color? = nil

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(textColor ?? color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.14)))
    }
}

// MARK: - App Tag (smaller)

/// Small colored tag/chip — for inline labels.
struct AppTag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.12)))
    }
}

// MARK: - App Stat Tile

/// Stat display: icon + value + label. Used in grids.
struct AppStatTile: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: action ?? {}) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(iconColor)
                }

                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(PawlyColors.ink)

                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(PawlyColors.slate)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(PawlyColors.surface)
            )
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

// MARK: - App Section Header

/// Section title with optional right-side action.
struct AppSectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String? = nil
    var icon: String? = nil
    var iconColor: Color = PawlyColors.forest

    var body: some View {
        HStack(spacing: 0) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .padding(.trailing, 6)
            }

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(PawlyColors.ink)

            Spacer()

            if let action, let actionLabel {
                Button(action: action) {
                    HStack(spacing: 2) {
                        Text(actionLabel)
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(PawlyColors.forest)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - App Icon Button

/// Circle button with SF Symbol — for actions in headers.
struct AppIconButton: View {
    let icon: String
    var color: Color = PawlyColors.forest
    var size: CGFloat = 36
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.10))
                    .frame(width: size, height: size)
                Image(systemName: icon)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Empty State

/// Centered empty state with icon + title + subtitle + optional CTA.
struct AppEmptyState: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.10))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(PawlyColors.ink)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(PawlyColors.slate)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(PawlyColors.forest))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - App Avatar

/// Pet avatar with optional accent color ring.
struct AppAvatar: View {
    let name: String
    let accentHex: String
    var photoURL: String? = nil
    var size: CGFloat = 48
    var showRing: Bool = true

    var body: some View {
        ZStack {
            if let photoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(hex: accentHex)
                        .overlay(
                            Text(name.prefix(1).uppercased())
                                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        )
                }
            } else {
                Color(hex: accentHex)
                    .overlay(
                        Text(name.prefix(1).uppercased())
                            .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
        .overlay(
            Group {
                if showRing {
                    RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                        .stroke(Color.white, lineWidth: 2)
                }
            }
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

// MARK: - App Tappable Tile

/// Large tappable tile with icon, label, and optional count.
struct AppTile: View {
    let icon: String
    let iconColor: Color
    let label: String
    var count: Int? = nil
    var isActive: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isActive ? iconColor : iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isActive ? .white : iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PawlyColors.ink)

                    if let count, count > 0 {
                        Text("\(count)\u{D7} logged")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(PawlyColors.slate)
                    }
                }

                Spacer()

                if let count, count > 0 {
                    AppBadge(text: "\(count)", color: iconColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(isActive ? iconColor.opacity(0.08) : PawlyColors.surface)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dot Grid Pattern

/// Subtle dot grid background pattern.
struct DotGridPattern: View {
    var spacing: CGFloat = 24
    var dotSize: CGFloat = 1.5
    var opacity: CGFloat = 0.06

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let cols = Int(size.width / spacing) + 1
                let rows = Int(size.height / spacing) + 1

                for col in 0..<cols {
                    for row in 0..<rows {
                        let x = CGFloat(col) * spacing
                        let y = CGFloat(row) * spacing
                        context.fill(
                            Circle().path(in: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                            with: .color(Color.black.opacity(opacity))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - App Primary Button

/// Primary CTA button with forest green fill.
struct AppPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: Radius.button)
                    .fill(isDisabled ? PawlyColors.forest.opacity(0.45) : PawlyColors.forest)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - App Secondary Button

/// Secondary button with soft fill.
struct AppSecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(PawlyColors.forest)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: Radius.button)
                    .fill(PawlyColors.forestSoft)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Info Row

/// Label + value row for settings/info displays.
struct AppInfoRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    var iconColor: Color = PawlyColors.forest

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.10))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(iconColor)
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PawlyColors.slate)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(PawlyColors.ink)
            }

            Spacer()
        }
    }
}

// MARK: - App Divider

struct AppDivider: View {
    var body: some View {
        Rectangle()
            .fill(PawlyColors.divider)
            .frame(height: 0.5)
    }
}
