import SwiftUI

// MARK: - Color Hex Initializer

extension Color {
    /// Creates a Color from a hex string (e.g. "#ec4899" or "ec4899").
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Color Palettes

/// Default color palettes.
public enum FacehashColors {
    /// Default color palette (Tailwind 500-level colors).
    public static let `default`: [Color] = [
        Color(hex: "#ec4899"), // pink-500
        Color(hex: "#f59e0b"), // amber-500
        Color(hex: "#3b82f6"), // blue-500
        Color(hex: "#f97316"), // orange-500
        Color(hex: "#10b981"), // emerald-500
    ]

    /// Light mode background colors (Tailwind 100-level).
    public static let light: [Color] = [
        Color(hex: "#fce7f3"), // pink-100
        Color(hex: "#fef3c7"), // amber-100
        Color(hex: "#dbeafe"), // blue-100
        Color(hex: "#ffedd5"), // orange-100
        Color(hex: "#d1fae5"), // emerald-100
    ]

    /// Dark mode background colors (Tailwind 600-level).
    public static let dark: [Color] = [
        Color(hex: "#db2777"), // pink-600
        Color(hex: "#d97706"), // amber-600
        Color(hex: "#2563eb"), // blue-600
        Color(hex: "#ea580c"), // orange-600
        Color(hex: "#059669"), // emerald-600
    ]

    /// Default hex strings for the color palette.
    public static let defaultHex: [String] = [
        "#ec4899",
        "#f59e0b",
        "#3b82f6",
        "#f97316",
        "#10b981",
    ]

    /// Fallback color (pink-500).
    public static let fallback = Color(hex: "#ec4899")
}
