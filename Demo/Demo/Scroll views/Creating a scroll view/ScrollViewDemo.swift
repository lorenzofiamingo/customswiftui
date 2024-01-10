//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct ScrollViewDemo: View {

    @State private var scrollPositionID: Int? = nil

    @State private var scrollAnchor: UnitPoint? = nil

    @State private var scrollPositionIDString: String? = nil

    @State private var isScrollingDisabled = false

    @State private var flashSeed = false

    @State private var showingFirst = true

    var body: some View {
        Spacer()

        if #available(iOS 17.0, *) {
            Text("Native")
                .font(.headline)
                .padding()

            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(0..<8) { i in
                        if i != 0 || showingFirst {
                            Card(i)
                                .containerRelativeFrame(.horizontal)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(phase.isIdentity ? 1 : 0)
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicatorsFlash(onAppear: true)
            .scrollDisabled(isScrollingDisabled)
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(20)
            .scrollPosition(id: $scrollPositionID, anchor: scrollAnchor)
            .scrollIndicators(.visible)
            .scrollIndicatorsFlash(trigger: flashSeed)
            .scrollClipDisabled()
            .frame(width: 200, height: 100)
            .padding()
            .background(.green)
            .animation(.default, value: scrollPositionID)
        }

        Spacer()

        Text("Custom")
            .font(.headline)
            .padding()

        CustomScrollView(.horizontal) {
           CustomHStack {
                CustomForEach(0..<8) { i in
                    if i != 0 || showingFirst {
                        Card(i)
                            .customContainerRelativeFrame(.horizontal)
                            .customScrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                    }
                }
           }
           .customScrollTargetLayout()
           .animation(.default, value: showingFirst)
        }
        .customScrollIndicatorsFlash(onAppear: true)
        .customScrollDisabled(isScrollingDisabled)
        .customScrollTargetBehavior(.viewAligned)
        .customContentMargins(20)
        .customScrollPosition(id: $scrollPositionID, anchor: scrollAnchor)
        .customScrollIndicators(.visible)
        .customScrollIndicatorsFlash(trigger: flashSeed)
        .customScrollClipDisabled()
        .frame(width: 200, height: 100)
        .padding()
        .background(.green)
        .animation(.default, value: scrollPositionID)

        Spacer()

        HStack {
            Button("nil") {
                scrollPositionID = nil
            }
            .buttonStyle(.bordered)
            .tint(scrollPositionID == nil ? .green : .red)
            ForEach(0..<8) { i in
                Button(String(i)) {
                    scrollPositionID = i
                }
                .buttonStyle(.bordered)
                .tint(scrollPositionID == i ? .green : .red)
            }
        }

        HStack {
            Button("nil") {
                scrollAnchor = nil
            }
            .buttonStyle(.bordered)
            .tint(scrollAnchor == nil ? .green : .red)

            Button("Leading") {
                scrollAnchor = .leading
            }
            .buttonStyle(.bordered)
            .tint(scrollAnchor == .leading ? .green : .red)

            Button("Center") {
                scrollAnchor = .center
            }
            .buttonStyle(.bordered)
            .tint(scrollAnchor == .center ? .green : .red)

            Button("Trailing") {
                scrollAnchor = .trailing
            }
            .buttonStyle(.bordered)
            .tint(scrollAnchor == .trailing ? .green : .red)
        }

        Button("Scroll Enabled") {
            isScrollingDisabled.toggle()
        }
        .buttonStyle(.bordered)
        .tint(!isScrollingDisabled ? .green : .red)

        Button("Flash Scroll indicator") {
            flashSeed.toggle()
        }
        .buttonStyle(.bordered)
        .tint(flashSeed ? .blue : .cyan)


        Button("Showing first") {
            withAnimation {
                showingFirst.toggle()
            }
        }
        .buttonStyle(.bordered)
        .tint(showingFirst ? .green : .red)

        Spacer()
    }
}


private struct Card: View {

    let i: Int

    @State private var width: CGFloat = 50

    init(_ i: Int) {
        self.i = i
    }

    var body: some View {
        Button {
            withAnimation(.linear) {
                width = width == 100 ? 10 : 100
            }
        } label: {
            ZStack {
                if i.isMultiple(of: 2) {
                    Color.yellow
                } else {
                    Color.orange
                }
                Text(String(i))
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
        }
        .frame(width: width)
        .id(i)
    }
}
