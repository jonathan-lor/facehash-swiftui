import SwiftUI

// MARK: - Types

/// The type of face (eyes) to render.
public enum FaceType: String, CaseIterable, Sendable {
    case round
    case cross
    case line
    case curved
}

/// Background style variant.
public enum Variant: String, Sendable {
    /// Adds a radial gradient overlay.
    case gradient
    /// Plain solid background color.
    case solid
}

/// 3D effect intensity level.
public enum Intensity3D: String, Sendable {
    case none
    case subtle
    case medium
    case dramatic
}

/// Computed facehash properties derived deterministically from a name string.
public struct FacehashData: Sendable {
    /// The face type to render.
    public let faceType: FaceType
    /// Index into the colors array.
    public let colorIndex: Int
    /// Rotation position for 3D effect (-1, 0, or 1 for each axis).
    public let rotation: (x: Int, y: Int)
    /// First letter of the name, uppercased.
    public let initial: String
}

// MARK: - Constants

/// The ordered list of face types.
private let faceTypes: [FaceType] = [.round, .cross, .line, .curved]

/// Sphere positions for 3D rotation.
private let spherePositions: [(x: Int, y: Int)] = [
    (-1,  1),  // down-right
    ( 1,  1),  // up-right
    ( 1,  0),  // up
    ( 0,  1),  // right
    (-1,  0),  // down
    ( 0,  0),  // center
    ( 0, -1),  // left
    (-1, -1),  // down-left
    ( 1, -1),  // up-left
]

/// 3D intensity presets.
public struct Intensity3DPreset {
    public let rotateRange: Double
    public let translateZ: Double
    /// CSS perspective distance in points (e.g. 300). Nil means no 3D effect.
    public let perspective: Double?

    public static let none = Intensity3DPreset(rotateRange: 0, translateZ: 0, perspective: nil)
    public static let subtle = Intensity3DPreset(rotateRange: 5, translateZ: 4, perspective: 800)
    public static let medium = Intensity3DPreset(rotateRange: 10, translateZ: 8, perspective: 500)
    public static let dramatic = Intensity3DPreset(rotateRange: 15, translateZ: 12, perspective: 300)

    public static func preset(for intensity: Intensity3D) -> Intensity3DPreset {
        switch intensity {
        case .none: return .none
        case .subtle: return .subtle
        case .medium: return .medium
        case .dramatic: return .dramatic
        }
    }
}

// MARK: - Core Functions

/// Computes deterministic face properties from a name string.
/// Pure function with no side effects.
///
/// - Parameters:
///   - name: The string to generate a face from.
///   - colorsLength: Number of colors available (for modulo). Defaults to 5 (default palette size).
/// - Returns: A `FacehashData` with deterministic face properties.
public func computeFacehash(name: String, colorsLength: Int = FacehashColors.default.count) -> FacehashData {
    let hash = stringHash(name)
    let faceIndex = hash % faceTypes.count
    let colorIndex = hash % colorsLength
    let positionIndex = hash % spherePositions.count
    let position = spherePositions[positionIndex]

    return FacehashData(
        faceType: faceTypes[faceIndex],
        colorIndex: colorIndex,
        rotation: position,
        initial: name.isEmpty ? "" : String(name.first!).uppercased()
    )
}

/// Gets a color from an array by index, with fallback to default colors.
///
/// - Parameters:
///   - colors: Optional color array. Falls back to default palette if nil or empty.
///   - index: The index to look up (will be wrapped with modulo).
/// - Returns: The color at the given index.
public func getColor(from colors: [Color]?, at index: Int) -> Color {
    let palette = (colors != nil && !colors!.isEmpty) ? colors! : FacehashColors.default
    return palette[index % palette.count]
}
