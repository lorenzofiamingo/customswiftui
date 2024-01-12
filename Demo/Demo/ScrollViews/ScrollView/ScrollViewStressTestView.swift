//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct ScrollViewStressTestView: View {

    @State private var axes: Axis.Set = [.horizontal]

    @State private var fixedCardHorizontal = false

    @State private var fixedCardVertical = false

    @State private var fixedScrollHorizontal = false

    @State private var fixedScrollVertical = false

    private let cardMaxSize = 300.0

    @State private var cardMinWidth: CGFloat?

    @State private var cardIdealWidth: CGFloat?

    @State private var cardMaxWidth: CGFloat?

    @State private var cardMinHeight: CGFloat?

    @State private var cardIdealHeight: CGFloat?

    @State private var cardMaxHeight: CGFloat?

    @State private var scrollWidth: CGFloat?

    @State private var scrollHeight: CGFloat?

    var body: some View {
        ScrollView {
            ScrollView(axes) {
                VStack {
                    ForEach(0..<1) { _ in
                        Card()
                            .frame(minWidth: cardMinWidth, idealWidth: cardIdealWidth, maxWidth: cardMaxWidth, minHeight: cardMinHeight, idealHeight: cardIdealHeight, maxHeight: cardMaxHeight)
                            .fixedSize(horizontal: fixedCardHorizontal, vertical: fixedCardVertical)
                    }
                }
            }
            .frame(width: scrollWidth, height: scrollHeight)
            .fixedSize(horizontal: fixedScrollHorizontal, vertical: fixedScrollVertical)
            .background(.green)
            .padding()
            .frame(width: 150, height: 150, alignment: .center)

            CustomScrollView(axes) {
                Card()
                    .frame(minWidth: cardMinWidth, idealWidth: cardIdealWidth, maxWidth: cardMaxWidth, minHeight: cardMinHeight, idealHeight: cardIdealHeight, maxHeight: cardMaxHeight)
                    .fixedSize(horizontal: fixedCardHorizontal, vertical: fixedCardVertical)
            }
            .frame(width: scrollWidth, height: scrollHeight)
            .fixedSize(horizontal: fixedScrollHorizontal, vertical: fixedScrollVertical)
            .background(.red)
            .padding()
            .frame(width: 150, height: 150, alignment: .center)
            VStack {
                HStack {
                    Button("Start test") {
                        Task {
                            let axes = [0, 1, 2, 3].map(Axis.Set.init).compactMap { $0 }
                            let sliders = [
                                $cardMinWidth, $cardIdealWidth, $cardMaxWidth,
                                $cardMinHeight, $cardIdealHeight, $cardMaxHeight,
                                $scrollWidth, $scrollHeight
                            ]
                            for ax in axes {
                                withAnimation {
                                    self.axes = ax
                                }
                                try await Task.sleep(for: .seconds(1))
                                for slider in sliders {
                                    withAnimation {
                                        slider.wrappedValue = 0
                                    }
                                    try await Task.sleep(for: .seconds(1))
                                    for i in stride(from: 0, to: cardMaxSize, by: 10) {
                                        slider.wrappedValue = i
                                        try await Task.sleep(for: .seconds(10/cardMaxSize))
                                    }
                                    for i in stride(from: 0, to: cardMaxSize, by: 10) {
                                        slider.wrappedValue = cardMaxSize-i
                                        try await Task.sleep(for: .seconds(10/cardMaxSize))
                                    }
                                    withAnimation {
                                        slider.wrappedValue = nil
                                    }
                                    try await Task.sleep(for: .seconds(2))
                                }
                            }
                        }
                    }
                    Button("[]") {
                        withAnimation {
                            axes = []
                        }
                    }
                    .tint(axes == [] ? .green : .red)
                    Button(".H") {
                        withAnimation {
                            axes = .horizontal
                        }
                    }
                    .tint(axes == .horizontal ? .green : .red)
                    Button(".V") {
                        withAnimation {
                            axes = .vertical
                        }
                    }
                    .tint(axes == .vertical ? .green : .red)
                    Button("[.H, .V]") {
                        withAnimation {
                            axes = [.horizontal, .vertical]
                        }
                    }
                    .tint(axes == [.horizontal, .vertical] ? .green : .red)
                }
                HStack {
                    Button("Card Horizontal fixed") {
                        withAnimation {
                            fixedCardHorizontal.toggle()
                        }
                    }
                    .tint(fixedCardHorizontal ? .green : .red)
                    Button("Card Vertical fixed") {
                        withAnimation {
                            fixedCardVertical.toggle()
                        }
                    }
                    .tint(fixedCardVertical ? .green : .red)
                }
                HStack {
                    Button("Scroll Horizontal fixed") {
                        withAnimation {
                            fixedScrollHorizontal.toggle()
                        }
                    }
                    .tint(fixedScrollHorizontal ? .green : .red)
                    Button("Scroll Vertical fixed") {
                        withAnimation {
                            fixedScrollVertical.toggle()
                        }
                    }
                    .tint(fixedScrollVertical ? .green : .red)
                }
                sizeController(size: $cardMinWidth, text: "Card Min Width")
                sizeController(size: $cardIdealWidth, text: "Card Ideal Width")
                sizeController(size: $cardMaxWidth, text: "Card Max Width")
                sizeController(size: $cardMinHeight, text: "Card Min Height")
                sizeController(size: $cardIdealHeight, text: "Card Ideal Height")
                sizeController(size: $cardMaxHeight, text: "Card Max Height")
                sizeController(size: $scrollWidth, text: "Scroll Width")
                //sizeController(size: $scrollHeight, text: "Scroll Height")
            }
            .buttonStyle(.bordered)
        }
        .navigationTitle("Stress Test")
    }

    func sizeController(size: Binding<CGFloat?>, text: String) -> some View {
        HStack {
            Button(text) {
                withAnimation {
                    size.wrappedValue =  size.wrappedValue == nil ? cardMaxSize/2 : nil
                }
            }
            .tint(size.wrappedValue != nil ? .green : .red)

            Slider(value: Binding(size) ?? .constant(cardMaxSize/2), in: 0...cardMaxSize)
                .disabled(size.wrappedValue == nil)
        }
    }
}

#Preview {
    ContentView()
}

private struct Card: View {
    var body: some View {
        Button {} label: {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Color.clear
                    Color.purple
                }
                VStack(spacing: 0) {
                    Color.purple
                    Color.clear
                }
            }
        }
    }
}

