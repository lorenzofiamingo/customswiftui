import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Sets the visibility of scroll indicators within this view.
    ///
    /// Use this modifier to hide or show scroll indicators on scrollable
    /// content in views like a ``ScrollView``, ``List``, or ``TextEditor``.
    /// This modifier applies the prefered visibility to any
    /// scrollable content within a view hierarchy.
    ///
    ///     ScrollView {
    ///         VStack(alignment: .leading) {
    ///             ForEach(0..<100) {
    ///                 Text("Row \($0)")
    ///             }
    ///         }
    ///     }
    ///     .scrollIndicators(.hidden)
    ///
    /// Use the ``ScrollIndicatorVisibility/hidden`` value to indicate that you
    /// prefer that views never show scroll indicators along a given axis.
    /// Use ``ScrollIndicatorVisibility/visible`` when you prefer that
    /// views show scroll indicators. Depending on platform conventions,
    /// visible scroll indicators might only appear while scrolling. Pass
    /// ``ScrollIndicatorVisibility/automatic`` to allow views to
    /// decide whether or not to show their indicators.
    ///
    /// - Parameters:
    ///   - visibility: The visibility to apply to scrollable views.
    ///   - axes: The axes of scrollable views that the visibility applies to.
    ///
    /// - Returns: A view with the specified scroll indicator visibility.
    public func customScrollIndicators(_ visibility: CustomScrollIndicatorVisibility, axes: Axis.Set = [.vertical, .horizontal]) -> some View {
        transformEnvironment(\.customScrollEnvironmentProperties) { scrollEnvironmentProperties in
            if axes.contains(.horizontal) {
                scrollEnvironmentProperties.horizontal.indicator.visibility = visibility
            }
            if axes.contains(.vertical) {
                scrollEnvironmentProperties.vertical.indicator.visibility = visibility
            }
        }
    }

    /// Sets the style of scroll indicators within this view.
    ///
    /// - Parameters:
    ///   - style: The style to apply to scrollable views.
    ///   - axes: The axes of scrollable views that the visibility applies to.
    ///
    /// - Returns: A view with the specified scroll indicator style.
    public func customScrollIndicators(_ style: CustomScrollIndicatorStyle) -> some View {
        transformEnvironment(\.customScrollEnvironmentProperties) { scrollEnvironmentProperties in
            scrollEnvironmentProperties.horizontal.indicator.style = style
            scrollEnvironmentProperties.vertical.indicator.style = style
        }
    }
}
