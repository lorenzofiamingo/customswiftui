/// The ways that a scrollable view can bounce when it reaches the end of its
/// content.
///
/// Use the ``View/scrollBounceBehavior(_:axes:)`` view modifier to set a value
/// of this type for a scrollable view, like a ``ScrollView`` or a ``List``.
/// The value configures the bounce behavior when people scroll to the end of
/// the view's content.
///
/// You can configure each scrollable axis to use a different bounce mode.
public struct CustomScrollBounceBehavior {

    var role: Role

    enum Role {
        case automatic
        case always
        case basedOnSize
    }

    /// The automatic behavior.
    ///
    /// The scrollable view automatically chooses whether content bounces when
    /// people scroll to the end of the view's content. By default, scrollable
    /// views use the ``ScrollBounceBehavior/always`` behavior.
    public static var automatic: CustomScrollBounceBehavior {
        CustomScrollBounceBehavior(role: .automatic)
    }

    /// The scrollable view always bounces.
    ///
    /// The scrollable view always bounces along the specified axis,
    /// regardless of the size of the content.
    public static var always: CustomScrollBounceBehavior {
        CustomScrollBounceBehavior(role: .always)
    }

    /// The scrollable view bounces when its content is large enough to require
    /// scrolling.
    ///
    /// The scrollable view bounces along the specified axis if the size of
    /// the content exceeeds the size of the scrollable view in that axis.
    public static var basedOnSize: CustomScrollBounceBehavior {
        CustomScrollBounceBehavior(role: .basedOnSize)
    }
}
