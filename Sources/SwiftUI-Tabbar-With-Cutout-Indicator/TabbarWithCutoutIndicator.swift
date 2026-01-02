//
//  TabbarWithCutoutIndicator.swift
//  SwiftUI-Tabbar-With-Cutout-Indicator
//
//  Created by acumenrev on 2/1/26.
//

import SwiftUI

struct TabPreferenceKey: PreferenceKey {
    static let defaultValue: [Int: CGRect] = [:]
    
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

public struct TabbarWithCutoutIndicator<TabbarItemView: View, BackgroundView: View>: View {
 
    public struct CutoutIndicatorData {
        let gapRatio: CGFloat
        let topCornerRadius: CGFloat
        let botCornerRadius: CGFloat
        let width: CGFloat
        let height: CGFloat
        public init(gapRatio: CGFloat,
                    topCornerRadius: CGFloat,
                    botCornerRadius: CGFloat,
                    width: CGFloat,
                    height: CGFloat) {
            self.gapRatio = gapRatio
            self.topCornerRadius = topCornerRadius
            self.botCornerRadius = botCornerRadius
            self.width = width
            self.height = height
        }
        
        static func defaultValue() -> CutoutIndicatorData {
            return CutoutIndicatorData(gapRatio: 0.85,
                                       topCornerRadius: 6,
                                       botCornerRadius: 20,
                                       width: 70,
                                       height: 50)
        }
    }
    
    let tabbarItems: [TabbarItemView]
    let backgroundView: BackgroundView
    let tabbarHeight: CGFloat
    let cutoutIndicatorData: CutoutIndicatorData
    @State var selectedIndex: Int = 0
    @State var blendedLayerOffsetX : CGFloat = -100
    @State private var frames: [Int: CGRect] = [:]
    private var selectedIndexHandler: ((Int) -> Void)
    
    public init(backgroundView: BackgroundView,
                buttons: [TabbarItemView],
                tabbarHeight: CGFloat = 60,
                cutoutIndicatorData: CutoutIndicatorData? = nil,
                selectedIndexHandler: @escaping ((Int) -> Void)) {
        self.tabbarItems = buttons
        self.backgroundView = backgroundView
        self.tabbarHeight = tabbarHeight
        self.selectedIndexHandler = selectedIndexHandler
        self.cutoutIndicatorData = cutoutIndicatorData ?? .defaultValue()
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let containerWidth = proxy.size.width
            HStack {
                ZStack(alignment: .top) {
                    backgroundView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // composite group
                    TabBarRoundedBoxShape(gapRatio: self.cutoutIndicatorData.gapRatio,
                                          topCornerRadius: self.cutoutIndicatorData.topCornerRadius,
                                          botCornerRadius: self.cutoutIndicatorData.botCornerRadius)
                        .frame(width: 70, height: 50)
                        .blendMode(.destinationOut)
                        .offset(x: blendedLayerOffsetX)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: blendedLayerOffsetX)
                    
                    HStack(alignment: .center, spacing: 12) {
                        // a list of icon
                        ForEach(tabbarItems.indices, id: \.self) { index in
                            Button(action: {
                                selectedIndex = index
                            }) {
                                tabbarItems[index]
                            }
                            .background(
                                GeometryReader { buttonProxy in
                                    Color.clear.preference(
                                        key: TabPreferenceKey.self,
                                        value: [index: buttonProxy.frame(in: .named("tabbar"))]
                                    )
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .compositingGroup()
                .coordinateSpace(name: "tabbar")
                .onPreferenceChange(TabPreferenceKey.self) { newFrames in
                    self.frames = newFrames
                    calculateOffset(width: containerWidth)
                }
                .onChange(of: selectedIndex) { _, _ in
                    calculateOffset(width: containerWidth)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: tabbarHeight)
    }
    
    private func calculateOffset(width: CGFloat) {
        guard let rect = frames[selectedIndex] else { return }
        
        // The center of the button relative to the ZStack's center
        // Math: Button center (midX) - Container center (width / 2)
        blendedLayerOffsetX = rect.midX - (width / 2)
    }
}

#Preview {
    let icons: [String] = ["square.and.arrow.up",
                           "square.and.arrow.up.circle",
                           "square.and.arrow.down.on.square",
                           "rectangle.portrait.and.arrow.forward",
                           "eraser"]
    
    
    VStack {
        Spacer()
        TabbarWithCutoutIndicator(backgroundView: Color.black, buttons: icons.map { Image(systemName: $0).padding() }, tabbarHeight: 60, selectedIndexHandler: { selectedIndex in
            
        })
    }
}
