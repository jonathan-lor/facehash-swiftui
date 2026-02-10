import SwiftUI

// MARK: - Face Shape Protocol

/// A face shape that can render eyes within a given rectangle.
/// Each shape scales its SVG-derived paths to fit the provided rect.
public protocol FaceShape: Shape {
    /// The original SVG viewBox dimensions.
    static var viewBoxSize: CGSize { get }
}

// MARK: - Round Face

/// Round eyes face - simple circular eyes.
/// SVG viewBox: 0 0 63 15
public struct RoundFaceShape: FaceShape {
    public static let viewBoxSize = CGSize(width: 63, height: 15)

    public init() {}

    public func path(in rect: CGRect) -> Path {
        // Uniform scale preserves circles (matches SVG preserveAspectRatio)
        let scale = min(rect.width / 63.0, rect.height / 15.0)
        let offsetX = rect.minX + (rect.width - 63.0 * scale) / 2
        let offsetY = rect.minY + (rect.height - 15.0 * scale) / 2
        let d = 14.4 * scale
        var path = Path()

        // Right eye - circle at (55.2, 7.2) radius 7.2
        path.addEllipse(in: CGRect(
            x: offsetX + 48.0 * scale,
            y: offsetY,
            width: d,
            height: d
        ))

        // Left eye - circle at (7.2, 7.2) radius 7.2
        path.addEllipse(in: CGRect(
            x: offsetX,
            y: offsetY,
            width: d,
            height: d
        ))

        return path
    }
}

// MARK: - Cross Face

/// Cross/plus eyes face - plus-sign shaped eyes.
/// SVG viewBox: 0 0 71 23
public struct CrossFaceShape: FaceShape {
    public static let viewBoxSize = CGSize(width: 71, height: 23)

    public init() {}

    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 71.0
        let sy = rect.height / 23.0
        var path = Path()

        // Left eye - plus shape
        path.addPath(crossEyePath(
            centerX: 11.5, centerY: 11.5,
            armWidth: 7.077, armLength: 11.5,
            cornerRadius: 3.5,
            sx: sx, sy: sy, origin: rect.origin
        ))

        // Right eye - plus shape
        path.addPath(crossEyePath(
            centerX: 58.7695, centerY: 11.5,
            armWidth: 7.077, armLength: 11.5,
            cornerRadius: 3.5,
            sx: sx, sy: sy, origin: rect.origin
        ))

        return path
    }

    private func crossEyePath(
        centerX: Double, centerY: Double,
        armWidth: Double, armLength: Double,
        cornerRadius: Double,
        sx: Double, sy: Double, origin: CGPoint
    ) -> Path {
        // Build a plus/cross shape as a union of two rounded rectangles
        let halfArm = armWidth / 2.0
        var path = Path()

        // Vertical bar
        path.addRoundedRect(
            in: CGRect(
                x: origin.x + (centerX - halfArm) * sx,
                y: origin.y + (centerY - armLength) * sy,
                width: armWidth * sx,
                height: armLength * 2 * sy
            ),
            cornerSize: CGSize(width: cornerRadius * sx, height: cornerRadius * sy)
        )

        // Horizontal bar
        path.addRoundedRect(
            in: CGRect(
                x: origin.x + (centerX - armLength) * sx,
                y: origin.y + (centerY - halfArm) * sy,
                width: armLength * 2 * sx,
                height: armWidth * sy
            ),
            cornerSize: CGSize(width: cornerRadius * sx, height: cornerRadius * sy)
        )

        return path
    }
}

// MARK: - Line Face

/// Line eyes face - horizontal line/dash eyes.
/// SVG viewBox: 0 0 82 8
public struct LineFaceShape: FaceShape {
    public static let viewBoxSize = CGSize(width: 82, height: 8)

    public init() {}

    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 82.0
        let sy = rect.height / 8.0
        let cr = 3.5 // corner radius in SVG units
        var path = Path()

        // Left eye: small dot + longer dash
        // Small dot (roughly 0.066 to 6.995, 0.164 to 7.093)
        path.addRoundedRect(
            in: CGRect(
                x: rect.minX + 0.066 * sx,
                y: rect.minY + 0.164 * sy,
                width: 6.929 * sx,
                height: 6.929 * sy
            ),
            cornerSize: CGSize(width: cr * sx, height: cr * sy)
        )

        // Longer dash (roughly 7.861 to 28.648, 0.164 to 7.093)
        path.addRoundedRect(
            in: CGRect(
                x: rect.minX + 7.861 * sx,
                y: rect.minY + 0.164 * sy,
                width: 20.787 * sx,
                height: 6.929 * sy
            ),
            cornerSize: CGSize(width: cr * sx, height: cr * sy)
        )

        // Right eye: longer dash + small dot
        // Small dot (roughly 74.740 to 81.668, 0.165 to 7.093)
        path.addRoundedRect(
            in: CGRect(
                x: rect.minX + 74.740 * sx,
                y: rect.minY + 0.165 * sy,
                width: 6.929 * sx,
                height: 6.929 * sy
            ),
            cornerSize: CGSize(width: cr * sx, height: cr * sy)
        )

        // Longer dash (roughly 53.086 to 73.873, 0.165 to 7.093)
        path.addRoundedRect(
            in: CGRect(
                x: rect.minX + 53.086 * sx,
                y: rect.minY + 0.165 * sy,
                width: 20.787 * sx,
                height: 6.929 * sy
            ),
            cornerSize: CGSize(width: cr * sx, height: cr * sy)
        )

        return path
    }
}

// MARK: - Curved Face

/// Curved/happy eyes face - curved arc eyes.
/// SVG viewBox: 0 0 63 9
public struct CurvedFaceShape: FaceShape {
    public static let viewBoxSize = CGSize(width: 63, height: 9)

    public init() {}

    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 63.0
        let sy = rect.height / 9.0
        var path = Path()

        // Left eye
        path.addPath(curvedEyePath(offsetX: 0, sx: sx, sy: sy, origin: rect.origin))

        // Right eye
        path.addPath(curvedEyePath(offsetX: 42, sx: sx, sy: sy, origin: rect.origin))

        return path
    }

    private func curvedEyePath(offsetX: Double, sx: Double, sy: Double, origin: CGPoint) -> Path {
        var p = Path()

        // Helper to scale SVG coordinates into the rect.
        // Right eye (offsetX=42) is identical to left eye but shifted +42 in x.
        func pt(_ x: Double, _ y: Double) -> CGPoint {
            CGPoint(x: origin.x + (offsetX + x) * sx, y: origin.y + y * sy)
        }

        // 16 cubic bezier segments.
        // Left eye path: M0 5.06511 C... Z  (right eye is offset +42 in x)

        p.move(to: pt(0, 5.06511))

        // C1
        p.addCurve(to: pt(0.00771184, 4.79757),
                   control1: pt(0, 4.94513), control2: pt(0, 4.88513))
        // C2
        p.addCurve(to: pt(0.690821, 3.46107),
                   control1: pt(0.0483059, 4.33665), control2: pt(0.341025, 3.76395))
        // C3
        p.addCurve(to: pt(0.837439, 3.34559),
                   control1: pt(0.757274, 3.40353), control2: pt(0.783996, 3.38422))
        // C4
        p.addCurve(to: pt(10.5, 0),
                   control1: pt(2.40699, 2.21129), control2: pt(6.03888, 0))
        // C5
        p.addCurve(to: pt(20.1626, 3.34559),
                   control1: pt(14.9611, 0), control2: pt(18.593, 2.21129))
        // C6
        p.addCurve(to: pt(20.3092, 3.46107),
                   control1: pt(20.216, 3.38422), control2: pt(20.2427, 3.40353))
        // C7
        p.addCurve(to: pt(20.9923, 4.79757),
                   control1: pt(20.659, 3.76395), control2: pt(20.9517, 4.33665))
        // C8
        p.addCurve(to: pt(21, 5.06511),
                   control1: pt(21, 4.88513), control2: pt(21, 4.94513))
        // C9
        p.addCurve(to: pt(20.9657, 6.6754),
                   control1: pt(21, 6.01683), control2: pt(21, 6.4927))
        // C10
        p.addCurve(to: pt(18.5289, 8.25054),
                   control1: pt(20.7241, 7.96423), control2: pt(19.8033, 8.55941))
        // C11
        p.addCurve(to: pt(16.7627, 7.49275),
                   control1: pt(18.3483, 8.20676), control2: pt(17.8198, 7.96876))
        // C12
        p.addCurve(to: pt(10.5, 6),
                   control1: pt(14.975, 6.68767), control2: pt(12.7805, 6))
        // C13
        p.addCurve(to: pt(4.23727, 7.49275),
                   control1: pt(8.21954, 6), control2: pt(6.02504, 6.68767))
        // C14
        p.addCurve(to: pt(2.47108, 8.25054),
                   control1: pt(3.18025, 7.96876), control2: pt(2.65174, 8.20676))
        // C15
        p.addCurve(to: pt(0.0342566, 6.6754),
                   control1: pt(1.19668, 8.55941), control2: pt(0.275917, 7.96423))
        // C16
        p.addCurve(to: pt(0, 5.06511),
                   control1: pt(0, 6.4927), control2: pt(0, 6.01683))

        p.closeSubpath()
        return p
    }
}

// MARK: - Face Shape Factory

/// Returns the appropriate filled face shape view for a given face type.
@ViewBuilder
public func faceShapeView(for faceType: FaceType) -> some View {
    switch faceType {
    case .round:
        RoundFaceShape().fill(.primary)
    case .cross:
        CrossFaceShape().fill(.primary)
    case .line:
        LineFaceShape().fill(.primary)
    case .curved:
        CurvedFaceShape().fill(.primary)
    }
}

/// Returns the viewBox aspect ratio for a given face type.
public func faceAspectRatio(for faceType: FaceType) -> CGFloat {
    switch faceType {
    case .round: return 63.0 / 15.0
    case .cross: return 71.0 / 23.0
    case .line:  return 82.0 / 8.0
    case .curved: return 63.0 / 9.0
    }
}
