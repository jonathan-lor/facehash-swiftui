import QuartzCore
import SwiftUI

/// Deterministic avatar face generated from any string.
///
/// Same string always produces the same face. The view renders eyes (one of 4 styles),
/// a background color, an optional gradient overlay, an optional initial letter,
/// and an optional 3D rotation effect.
///
/// ```swift
/// FacehashView(name: "John")
///
/// FacehashView(name: "Alice", size: 64, variant: .solid, intensity3D: .subtle)
/// ```
public struct FacehashView<Mouth: View>: View {
    // MARK: - Properties

    /// String to generate a deterministic face from.
    public let name: String

    /// Size in points. Defaults to 40.
    public let size: CGFloat

    /// Background style. Defaults to `.gradient`.
    public let variant: Variant

    /// 3D effect intensity. Defaults to `.dramatic`.
    public let intensity3D: Intensity3D

    /// Enable hover/tap interaction (face "looks straight"). Defaults to `true`.
    public let interactive: Bool

    /// Show first letter of name below the eyes. Defaults to `true`.
    public let showInitial: Bool

    /// Custom color palette. Uses default palette when nil.
    public let colors: [Color]?

    /// Enable random eye blinking animation. Defaults to `false`.
    public let enableBlink: Bool

    /// Color for the eyes and initial letter. Defaults to `.primary`.
    public let faceColor: Color

    /// Custom mouth view. When provided, replaces the initial letter.
    private let mouth: Mouth?

    // MARK: - State

    @State private var isHovered = false

    // MARK: - Init

    /// Creates a facehash view with the default initial letter as the mouth.
    public init(
        name: String,
        size: CGFloat = 40,
        variant: Variant = .gradient,
        intensity3D: Intensity3D = .dramatic,
        interactive: Bool = true,
        showInitial: Bool = true,
        colors: [Color]? = nil,
        enableBlink: Bool = false,
        faceColor: Color = .primary
    ) where Mouth == EmptyView {
        self.name = name
        self.size = size
        self.variant = variant
        self.intensity3D = intensity3D
        self.interactive = interactive
        self.showInitial = showInitial
        self.colors = colors
        self.enableBlink = enableBlink
        self.faceColor = faceColor
        self.mouth = nil
    }

    /// Creates a facehash view with a custom mouth renderer replacing the initial letter.
    ///
    /// ```swift
    /// FacehashView(name: "loading") {
    ///     ProgressView()
    /// }
    /// ```
    public init(
        name: String,
        size: CGFloat = 40,
        variant: Variant = .gradient,
        intensity3D: Intensity3D = .dramatic,
        interactive: Bool = true,
        colors: [Color]? = nil,
        enableBlink: Bool = false,
        faceColor: Color = .primary,
        @ViewBuilder mouth: () -> Mouth
    ) {
        self.name = name
        self.size = size
        self.variant = variant
        self.intensity3D = intensity3D
        self.interactive = interactive
        self.showInitial = true
        self.colors = colors
        self.enableBlink = enableBlink
        self.faceColor = faceColor
        self.mouth = mouth()
    }

    // MARK: - Computed

    private var data: FacehashData {
        let palette = colors ?? FacehashColors.default
        return computeFacehash(name: name, colorsLength: palette.count)
    }

    private var backgroundColor: Color {
        getColor(from: colors, at: data.colorIndex)
    }

    private var preset: Intensity3DPreset {
        .preset(for: intensity3D)
    }

    private var rotateX: Double {
        if isHovered && interactive { return 0 }
        return Double(data.rotation.x) * preset.rotateRange
    }

    private var rotateY: Double {
        if isHovered && interactive { return 0 }
        return Double(data.rotation.y) * preset.rotateRange
    }

    private var blinkTimings: (delay: Double, duration: Double) {
        let hash = stringHash(name)
        let blinkSeed = hash * 31 // TS uses regular multiplication (no overflow)
        let delay = Double(blinkSeed % 40) / 10.0
        let duration = 2.0 + Double(blinkSeed % 40) / 10.0
        return (delay, duration)
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Background
            backgroundColor

            // Gradient overlay
            if variant == .gradient {
                RadialGradient(
                    colors: [Color.white.opacity(0.15), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.6
                )
            }

            // Face container with 3D transform
            faceContent
                .frame(width: size, height: size)
                .applyIf(intensity3D != .none) { view in
                    view.modifier(Facehash3DEffect(
                        rotateX: rotateX,
                        rotateY: rotateY,
                        translateZ: preset.translateZ,
                        perspective: preset.perspective!
                    ))
                }
                .applyIf(interactive) { view in
                    view.animation(
                        .easeInOut(duration: 0.3),
                        value: isHovered
                    )
                }
        }
        .frame(width: size, height: size)
        .clipShape(Rectangle())
        .contentShape(Rectangle())
        #if os(macOS)
        .onHover { hovering in
            if interactive {
                isHovered = hovering
            }
        }
        #else
        .onTapGesture {
            if interactive {
                isHovered = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isHovered = false
                }
            }
        }
        #endif
    }

    // MARK: - Subviews

    @ViewBuilder
    private var faceContent: some View {
        VStack(spacing: 0) {
            // Eyes
            eyesView
                .frame(width: size * 0.6)
                .aspectRatio(faceAspectRatio(for: data.faceType), contentMode: .fit)
                .frame(maxWidth: size * 0.9, maxHeight: size * 0.4)

            // Mouth area: custom renderer or initial letter
            if let mouth {
                mouth
                    .padding(.top, size * 0.08)
            } else if showInitial && !data.initial.isEmpty {
                Text(data.initial)
                    .font(.system(size: size * 0.26, weight: .bold, design: .monospaced))
                    .padding(.top, size * 0.08)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(faceColor)
    }

    @ViewBuilder
    private var eyesView: some View {
        faceShapeView(for: data.faceType)
            .applyIf(enableBlink) { view in
                view.modifier(BlinkModifier(delay: blinkTimings.delay, duration: blinkTimings.duration))
                    .id(name) // Reset blink state when name changes
            }
    }
}

// MARK: - Blink Animation Modifier

private struct BlinkModifier: ViewModifier {
    let delay: Double
    let duration: Double

    @State private var blinkScale: CGFloat = 1.0
    @State private var blinkTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .scaleEffect(y: blinkScale)
            .onAppear { startBlinking() }
            .onDisappear { blinkTask?.cancel() }
    }

    private func startBlinking() {
        blinkTask = Task { @MainActor in
            // Animation-delay: wait before first cycle
            try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))

            while !Task.isCancelled {
                // 0%–92%: eyes open
                try? await Task.sleep(for: .milliseconds(Int(duration * 0.92 * 1000)))
                if Task.isCancelled { break }

                // 92%–96%: close eyes
                withAnimation(.easeInOut(duration: duration * 0.04)) {
                    blinkScale = 0.05
                }
                try? await Task.sleep(for: .milliseconds(Int(duration * 0.04 * 1000)))
                if Task.isCancelled { break }

                // 96%–100%: reopen eyes
                withAnimation(.easeInOut(duration: duration * 0.04)) {
                    blinkScale = 1.0
                }
                try? await Task.sleep(for: .milliseconds(Int(duration * 0.04 * 1000)))
            }
        }
    }
}

// MARK: - 3D Transform Effect

/// Applies a CSS-equivalent 3D transform using `projectionEffect`.
///
///   - Parent perspective: `perspective: Npx`
///   - Child transform: `rotateX(Xdeg) rotateY(Ydeg) translateZ(Zpx)`
///   - Transform origin: center center
private struct Facehash3DEffect: GeometryEffect {
    var rotateX: Double
    var rotateY: Double
    var translateZ: Double
    var perspective: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { .init(rotateX, rotateY) }
        set {
            rotateX = newValue.first
            rotateY = newValue.second
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let cx = size.width / 2
        let cy = size.height / 2
        let rx = rotateX * .pi / 180.0
        let ry = rotateY * .pi / 180.0

        // Build CATransform3D matching CSS:
        //   perspective on parent → m34
        //   transform: rotateX() rotateY() translateZ() on child
        //   transform-origin: center center
        var t = CATransform3DIdentity
        t = CATransform3DTranslate(t, cx, cy, 0)
        t.m34 = -1.0 / perspective
        t = CATransform3DRotate(t, rx, 1, 0, 0)
        t = CATransform3DRotate(t, ry, 0, 1, 0)
        t = CATransform3DTranslate(t, 0, 0, translateZ)
        t = CATransform3DTranslate(t, -cx, -cy, 0)

        return ProjectionTransform(t)
    }
}

// MARK: - Conditional Modifier Helper

extension View {
    @ViewBuilder
    func applyIf<V: View>(_ condition: Bool, transform: (Self) -> V) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Facehash Gallery") {
    let names = ["John", "Alice", "Bob", "Charlie", "Diana", "Eve", "Frank", "Grace"]
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
            ForEach(names, id: \.self) { name in
                VStack(spacing: 4) {
                    FacehashView(name: name, size: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Text(name)
                        .font(.caption2)
                }
            }
        }
        .padding()
    }
}

#Preview("Variants") {
    HStack(spacing: 16) {
        FacehashView(name: "Test", size: 80, variant: .gradient)
            .clipShape(Circle())
        FacehashView(name: "Test", size: 80, variant: .solid)
            .clipShape(Circle())
    }
    .padding()
}

#Preview("Intensities") {
    HStack(spacing: 12) {
        ForEach([Intensity3D.none, .subtle, .medium, .dramatic], id: \.rawValue) { intensity in
            VStack {
                FacehashView(name: "Hello", size: 64, intensity3D: intensity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(intensity.rawValue)
                    .font(.caption2)
            }
        }
    }
    .padding()
}
#endif
