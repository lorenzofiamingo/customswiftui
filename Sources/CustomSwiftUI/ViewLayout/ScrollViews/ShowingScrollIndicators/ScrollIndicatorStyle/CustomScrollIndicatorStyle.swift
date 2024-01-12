/// The style of scroll indicators of a UI element.
public struct CustomScrollIndicatorStyle {

    let role: Role

    enum Role {
        case automatic
        case black
        case white
    }

    /// Scroll indicator style depends on the
    /// policies of the component accepting the visibility configuration.
    public static var automatic: CustomScrollIndicatorStyle {
        CustomScrollIndicatorStyle(role: .automatic)
    }

    /// Scroll indicator style should be black.
    public static var black: CustomScrollIndicatorStyle {
        CustomScrollIndicatorStyle(role: .black)
    }

    /// Scroll indicator style should be white.
    public static var white: CustomScrollIndicatorStyle {
        CustomScrollIndicatorStyle(role: .white)
    }
}
