import SwiftUI

/// Design system palette.
/// Philosophy: warm cream backgrounds, deep navy brand, terracotta coral accents.
/// Premium, trustworthy, global — like a high-end consumer app.
enum PawlyColors {
    // ── Primary brand — deep navy blue
    /// Deep navy — confident, trustworthy, premium
    static let navy       = Color(hex: "#1E3A5F")
    /// Soft navy wash for backgrounds / highlights
    static let navySoft   = Color(hex: "#1E3A5F").opacity(0.10)
    /// Mid-strength navy for subtle fills
    static let navyMid    = Color(hex: "#1E3A5F").opacity(0.18)

    // ── Accent — terracotta coral (primary CTA / energy)
    static let coral      = Color(hex: "#E07A5F")
    static let coralSoft  = Color(hex: "#E07A5F").opacity(0.14)

    // ── Secondary accent — warm amber
    static let amber      = Color(hex: "#F59E0B")
    static let amberSoft  = Color(hex: "#F59E0B").opacity(0.14)

    // ── Backgrounds
    /// Warm off-white canvas
    static let canvas     = Color(hex: "#FAF7F2")
    /// Pure white surface for cards
    static let surface    = Color.white
    /// Subtle warm surface
    static let surfaceMuted = Color(hex: "#F5F2EC")

    // ── Borders / Dividers
    static let border     = Color(hex: "#E8E0D5")
    static let divider    = Color(hex: "#E8E0D5").opacity(0.5)
    static let hairline    = Color(hex: "#E8E0D5").opacity(0.35)

    // ── Text
    static let ink        = Color(hex: "#1B1B1B")
    static let inkMuted   = Color(hex: "#1B1B1B").opacity(0.65)
    static let slate      = Color(hex: "#6B7280")
    static let slateSoft  = Color(hex: "#6B7280").opacity(0.6)

    // ── Status
    static let alert      = Color(hex: "#DC2626")
    static let alertSoft  = Color(hex: "#DC2626").opacity(0.10)
    /// Warm sage for positive / health
    static let sage       = Color(hex: "#4CAF74")
    static let sageSoft   = Color(hex: "#4CAF74").opacity(0.18)
    /// Cool sky blue for info
    static let sky        = Color(hex: "#60A5FA")
    static let skySoft    = Color(hex: "#60A5FA").opacity(0.14)
    /// Soft lavender for tags
    static let lavender   = Color(hex: "#A78BFA")
    static let lavenderSoft = Color(hex: "#A78BFA").opacity(0.14)

    // ── Shadows
    static let shadowWarm = Color.black.opacity(0.05)
    static let shadowMid  = Color.black.opacity(0.10)
    static let shadowDeep = Color.black.opacity(0.15)

    // ── Legacy aliases (for migration)
    static let forest     = navy
    static let forestSoft = navySoft
    static let forestMid  = navyMid
    static let forestLight = navySoft
    static let peach       = coral
    static let peachSoft   = coralSoft
    static let peachLight   = coralSoft
    static let cream       = canvas
    static let sand        = border
    static let sageLight   = sageSoft

    // ── Effects
    static let overlayLight = Color.white.opacity(0.7)

    /// Per-pet accent palette — vibrant, diverse, warm
    static let petAccents: [String] = [
        "#1E3A5F", // deep navy
        "#E07A5F", // terracotta
        "#4CAF74", // sage green
        "#60A5FA", // sky blue
        "#F59E0B", // amber
        "#A78BFA", // lavender
        "#E07A5F"  // coral
    ]
}

extension Color {
    init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let v = UInt64(h, radix: 16) else {
            self = PawlyColors.navy
            return
        }
        let r = Double((v >> 16) & 0xFF) / 255.0
        let g = Double((v >>  8) & 0xFF) / 255.0
        let b = Double(v & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}