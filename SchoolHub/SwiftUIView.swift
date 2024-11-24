//
//  SwiftUIView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 24.11.2024.
//

import SwiftUI

struct SwiftUIView: View {
    @State private var weekdays: [Weekday] = Weekday.weekdays
    @State private var current: ScrollPosition = .init(idType: Weekday.ID.self)

    var body: some View {
        ScrollView {
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(weekdays) { weekday in
                            VStack {
                                Color.blue
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Text("\(weekday.name)")
                                    }
                                Color.blue
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Text("\(weekday.name)")
                                    }
                                Color.blue
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Text("\(weekday.name)")
                                    }
                                Color.blue
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Text("\(weekday.name)")
                                    }
                                Color.blue
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Text("\(weekday.name)")
                                    }
                                Color.blue
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Text("\(weekday.name)")
                                    }
                                Color.blue
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Text("\(weekday.name)")
                                    }
                                Color.blue
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Text("\(weekday.name)")
                                    }
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition($current)
            }

//            Text("\(current.viewID)")
        }
    }
}

#Preview {
    SwiftUIView()
}
