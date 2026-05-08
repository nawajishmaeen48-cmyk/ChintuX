import SwiftUI

/// Refined, restrained motion. Soft ease-out curves — no bouncy springs.
enum Motion {
    static let micro       = Animation.timingCurve(0.32, 0.72, 0.0, 1.0, duration: 0.18)
    static let softEaseOut = Animation.timingCurve(0.32, 0.72, 0.0, 1.0, duration: 0.28)
    static let transition  = Animation.timingCurve(0.32, 0.72, 0.0, 1.0, duration: 0.32)
    static let celebration = Animation.timingCurve(0.32, 0.72, 0.0, 1.0, duration: 0.48)

    /// Subtle spring for tab/icon press feedback.
    static let snap        = Animation.spring(response: 0.32, dampingFraction: 0.85)
}

/// Shared environment object that controls visibility of the floating tab bar.
/// Sub-screens (chat, full-bleed UI) call `.hide()` in `onAppear` and `.show()`
/// in `onDisappear`.
@MainActor
final class TabBarVisibility: ObservableObject {
    @Published var isVisible = true
    func hide() { withAnimation(Motion.transition) { isVisible = false } }
    func show() { withAnimation(Motion.transition) { isVisible = true } }
}
