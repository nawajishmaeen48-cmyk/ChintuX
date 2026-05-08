import SwiftUI

/// Type system. SF Pro everywhere — rounded for hero/display, default for body.
enum PawlyFont {
    // Display — large hero text, screen titles
    static let displayLarge   = Font.system(size: 32, weight: .bold,    design: .rounded)
    static let displayMedium  = Font.system(size: 26, weight: .semibold, design: .rounded)
    static let displaySmall   = Font.system(size: 22, weight: .semibold, design: .rounded)

    // Heading — section titles
    static let headingLarge   = Font.system(size: 20, weight: .semibold, design: .default)
    static let headingMedium  = Font.system(size: 17, weight: .semibold, design: .default)
    static let headingSmall   = Font.system(size: 15, weight: .semibold, design: .default)

    // Body
    static let bodyLarge      = Font.system(size: 16, weight: .regular,  design: .default)
    static let bodyMedium     = Font.system(size: 14, weight: .regular,  design: .default)
    static let bodySmall      = Font.system(size: 13, weight: .regular,  design: .default)

    // Labels / metadata
    static let label          = Font.system(size: 13, weight: .medium,   design: .default)
    static let caption        = Font.system(size: 12, weight: .medium,   design: .default)
    static let captionSmall   = Font.system(size: 11, weight: .medium,   design: .default)
    static let overline       = Font.system(size: 10, weight: .semibold, design: .default)

    // Tabular numbers (counters, times)
    static let tabular        = Font.system(size: 16, weight: .medium,   design: .monospaced)
    static let tabularSmall   = Font.system(size: 13, weight: .medium,   design: .monospaced)
}
