import SwiftUI

/// Avatar view that loads a remote image with a Facehash fallback.
///
/// Shows the remote image when loaded successfully, otherwise falls back
/// to a deterministic Facehash avatar generated from the name string.
///
/// ```swift
/// AvatarView(
///     url: URL(string: "https://example.com/photo.jpg"),
///     name: "John Doe",
///     size: 48
/// )
/// .clipShape(Circle())
/// ```
public struct AvatarView<Mouth: View>: View {
    /// Remote image URL. If nil, shows Facehash fallback immediately.
    public let url: URL?

    /// Name to generate the fallback Facehash from.
    public let name: String

    /// Size in points.
    public let size: CGFloat

    /// Background variant for the Facehash fallback.
    public let variant: Variant

    /// 3D intensity for the Facehash fallback.
    public let intensity3D: Intensity3D

    /// Enable hover/tap interaction for the Facehash fallback.
    public let interactive: Bool

    /// Show first letter of name below the eyes in the Facehash fallback.
    public let showInitial: Bool

    /// Custom color palette for the Facehash fallback.
    public let colors: [Color]?

    /// Enable random eye blinking animation for the Facehash fallback.
    public let enableBlink: Bool

    /// Color for the eyes and initial letter in the Facehash fallback.
    public let faceColor: Color

    /// Custom mouth view for the Facehash fallback.
    private let mouth: Mouth?

    public init(
        url: URL?,
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
        self.url = url
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

    public init(
        url: URL?,
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
        self.url = url
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

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                facehashFallback
            case .empty:
                facehashFallback
            @unknown default:
                facehashFallback
            }
        }
        .frame(width: size, height: size)
        .clipped()
    }

    @ViewBuilder
    private var facehashFallback: some View {
        if let mouth {
            FacehashView(
                name: name,
                size: size,
                variant: variant,
                intensity3D: intensity3D,
                interactive: interactive,
                colors: colors,
                enableBlink: enableBlink,
                faceColor: faceColor
            ) {
                mouth
            }
        } else {
            FacehashView(
                name: name,
                size: size,
                variant: variant,
                intensity3D: intensity3D,
                interactive: interactive,
                showInitial: showInitial,
                colors: colors,
                enableBlink: enableBlink,
                faceColor: faceColor
            )
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("AvatarView - No Image") {
    AvatarView(
        url: nil,
        name: "John Doe",
        size: 64
    )
    .clipShape(Circle())
    .padding()
}

#Preview("AvatarView - Invalid URL") {
    AvatarView(
        url: URL(string: "https://invalid.example.com/nonexistent.jpg"),
        name: "Alice",
        size: 64
    )
    .clipShape(Circle())
    .padding()
}
#endif
