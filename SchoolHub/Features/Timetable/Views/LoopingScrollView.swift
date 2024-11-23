//
//  LoopingScrollView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 01.11.2024.
//

import SwiftUI

struct LoopingScrollView<Content: View, Item: RandomAccessCollection>: View where Item.Element: Identifiable {
    var width: CGFloat
    var spacing: CGFloat
    var items: Item
    @Binding var currentIndex: Int
    @ViewBuilder var content: (Item.Element) -> Content
    
    @State private var scrollView: UIScrollView?
    @State private var internalIndex: Int
    
    init(width: CGFloat, spacing: CGFloat, items: Item, currentIndex: Binding<Int>, @ViewBuilder content: @escaping (Item.Element) -> Content) {
        self.width = width
        self.spacing = spacing
        self.items = items
        self._currentIndex = currentIndex
        self.content = content
        self._internalIndex = State(initialValue: currentIndex.wrappedValue)
    }
    
    var body: some View {
//        GeometryReader {
//            let size = $0.size
//            let repeatingCount = width > 0 ? (Int((size.width / width).rounded()) + 1) : 1
                
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                ForEach(items) { item in
                    content(item)
                        .frame(width: width)
                }
                        
                ForEach(0 ..< 1, id: \.self) { index in
                    let item = Array(items)[index % items.count]
                    content(item)
                        .frame(width: width)
                }
            }
            .background {
                let _ = print("width before \(width)")
                if width > 0 {
                    ScrollViewHelper(
                        width: width,
                        spacing: spacing,
                        itemsCount: items.count,
                        repeatingCount: 1,
                        internalIndex: $internalIndex,
                        scrollView: $scrollView
                    )
                }
            }
//            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollToIndex(currentIndex, animated: true)
//                internalIndex = 4
//                print("❌❌❌❌❌❌❌ scrolling to \(currentIndex)")
            }
        }
        .onChange(of: currentIndex) {
            if internalIndex != currentIndex {
                scrollToIndex(currentIndex, animated: true)
                internalIndex = currentIndex
            }
        }
        .onChange(of: internalIndex) {
            if currentIndex != internalIndex {
                currentIndex = internalIndex
            }
        }
    }
    
    private func scrollToIndex(_ index: Int, animated: Bool) {
        guard let scrollView = scrollView else { return }
        let itemWidth = width + spacing
        let offsetX = CGFloat(index) * itemWidth
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }
}

private struct ScrollViewHelper: UIViewRepresentable {
    var width: CGFloat
    var spacing: CGFloat
    var itemsCount: Int
    var repeatingCount: Int
    @Binding var internalIndex: Int
    @Binding var scrollView: UIScrollView?
    
    func makeCoordinator() -> Coordinator {
        print("width in makecoordinator \(width)")
        return Coordinator(
            width: width,
            spacing: spacing,
            itemsCount: itemsCount,
            repeatingCount: repeatingCount,
            internalIndex: $internalIndex
        )
    }
    
    func makeUIView(context: Context) -> UIView {
        return .init()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView, !context.coordinator.isAdded {
                self.scrollView = scrollView
                scrollView.delegate = context.coordinator
                context.coordinator.isAdded = true
            }
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var width: CGFloat
        var spacing: CGFloat
        var itemsCount: Int
        var repeatingCount: Int
        var internalIndex: Binding<Int>
        
        init(
            width: CGFloat,
            spacing: CGFloat,
            itemsCount: Int,
            repeatingCount: Int,
            internalIndex: Binding<Int>
        ) {
            self.width = width
            self.spacing = spacing
            self.itemsCount = itemsCount
            self.repeatingCount = repeatingCount
            self.internalIndex = internalIndex
        }
        
        var isAdded: Bool = false
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let minX = scrollView.contentOffset.x
            let minContentSize = CGFloat(itemsCount) * width
            let spacingSize = CGFloat(itemsCount) * spacing
            
            if minX > (minContentSize + spacingSize) {
                scrollView.contentOffset.x -= (minContentSize + spacingSize)
            } else if minX < 0 {
                scrollView.contentOffset.x += (minContentSize + spacingSize)
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            updateCurrentIndex(scrollView)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                updateCurrentIndex(scrollView)
            }
        }
        
        private func updateCurrentIndex(_ scrollView: UIScrollView) {
            let itemWidth = width + spacing
            print("width in \(itemWidth)")
            let estimatedIndex = Int((scrollView.contentOffset.x / itemWidth).rounded())
            let normalizedIndex = estimatedIndex % itemsCount
            let safeIndex = max(0, min(normalizedIndex, itemsCount - 1))
            
            internalIndex.wrappedValue = safeIndex
        }
    }
}

#Preview {
    LoopingScrollView(
        width: 150,
        spacing: 15,
        items: Weekday.weekdays,
        currentIndex: .constant(0)
    ) { item in
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(.blue)
            .overlay {
                Text(item.name)
            }
    }
    .frame(height: 150)
    .contentMargins(.horizontal, 15, for: .scrollContent)
}
