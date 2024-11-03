//
//  SwiftUIView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 01.11.2024.
//

import SwiftUI

struct InfiniteScrollView<Content: View>: View {
    let content: Content
    let itemCount: Int
    
    @State private var offset: CGFloat = 0
    @State private var draggingOffset: CGFloat = 0
    
    init(itemCount: Int, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.itemCount = itemCount
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    // Duplicate content three times to ensure smooth infinite scrolling
                    content
                    content
                    content
                }
                .offset(x: offset + draggingOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            draggingOffset = value.translation.width
                        }
                        .onEnded { value in
                            let screenWidth = geometry.size.width
                            let totalContentWidth = screenWidth * CGFloat(itemCount)
                            
                            // Combine the existing offset with the drag offset
                            var newOffset = offset + draggingOffset
                            
                            // Normalize the offset to keep it within bounds
                            newOffset = newOffset.truncatingRemainder(dividingBy: totalContentWidth)
                            
                            // If we've scrolled past the first set of items to the left
                            if abs(newOffset) >= totalContentWidth {
                                newOffset = newOffset.truncatingRemainder(dividingBy: totalContentWidth)
                            }
                            
                            withAnimation {
                                offset = newOffset
                                draggingOffset = 0
                            }
                        }
                )
            }
        }
    }
}

#Preview {
    InfiniteScrollView(itemCount: 5) {
        Color.blue
            .frame(width: 100, height: 100)
    }
}
