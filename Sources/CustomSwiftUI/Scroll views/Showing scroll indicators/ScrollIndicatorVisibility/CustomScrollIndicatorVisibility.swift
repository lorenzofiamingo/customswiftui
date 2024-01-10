/// The visibility of scroll indicators of a UI element.
///
/// Pass a value of this type to the ``View/scrollIndicators(_:axes:)`` method
/// to specify the preferred scroll indicator visibility of a view hierarchy.
public struct CustomScrollIndicatorVisibility: Equatable {

    let role: Role

    enum Role {
        case automatic
        case visible
        case hidden
        case never
    }

    /// Scroll indicator visibility depends on the
    /// policies of the component accepting the visibility configuration.
    public static var automatic: CustomScrollIndicatorVisibility {
        CustomScrollIndicatorVisibility(role: .automatic)
    }

    /// Show the scroll indicators.
    ///
    /// The actual visibility of the indicators depends on platform
    /// conventions like auto-hiding behaviors in iOS or user preference
    /// behaviors in macOS.
    public static var visible: CustomScrollIndicatorVisibility {
        CustomScrollIndicatorVisibility(role: .visible)
     }

    /// Hide the scroll indicators.
    ///
    /// By default, scroll views in macOS show indicators when a
    /// mouse is connected. Use ``never`` to indicate
    /// a stronger preference that can override this behavior.
    public static var hidden: CustomScrollIndicatorVisibility {
        CustomScrollIndicatorVisibility(role: .hidden)
     }

    /// Scroll indicators should never be visible.
    ///
    /// This value behaves like ``hidden``, but
    /// overrides scrollable views that choose
    /// to keep their indidicators visible. When using this value,
    /// provide an alternative method of scrolling. The typical
    /// horizontal swipe gesture might not be available, depending on
    /// the current input device.
    public static var never: CustomScrollIndicatorVisibility {
        CustomScrollIndicatorVisibility(role: .never)
     }
}

