/// The placement of margins.
///
/// Different views can support customizating margins that appear in
/// different parts of that view. Use values of this type to customize
/// those margins of a particular placement.
///
/// For example, use a ``ContentMarginPlacement/scrollIndicators``
/// placement to customize the margins of scrollable view's scroll
/// indicators separately from the margins of a scrollable view's
/// content.
///
/// Use this type with the ``View/contentMargins(_:for:)`` modifier.
public struct CustomContentMarginPlacement {

    var role: Role

    enum Role {
        case automatic
        case scrollContent
        case scrollIndicators
    }

    /// The automatic placement.
    ///
    /// Views that support margin customization can automatically use
    /// margins with this placement. For example, a ``ScrollView`` will
    /// use this placement to automatically inset both its content and
    /// scroll indicators by the specified amount.
    public static var automatic: CustomContentMarginPlacement {
        CustomContentMarginPlacement(role: .automatic)
    }

    /// The scroll content placement.
    ///
    /// Scrollable views like ``ScrollView`` will use this placement to
    /// inset their content, but not their scroll indicators.
    public static var scrollContent: CustomContentMarginPlacement {
        CustomContentMarginPlacement(role: .scrollContent)
    }

    /// The scroll indicators placement.
    ///
    /// Scrollable views like ``ScrollView`` will use this placement to
    /// inset their scroll indicators, but not their content.
    public static var scrollIndicators: CustomContentMarginPlacement {
        CustomContentMarginPlacement(role: .scrollIndicators)
    }
}

