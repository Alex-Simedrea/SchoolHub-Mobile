//
//  SubjectsScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 30.10.2024.
//

import SwiftData
import SwiftUI

struct SubjectsScreen: View {
    @Query(sort: \Subject.displayName) private var subjects: [Subject]
    @Namespace private var namespace
    
    @State private var showHiddenSubjects = false

    let items = Array(1 ... 10)

    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(subjects, id: \.id) { item in
                        if !item.hidden {
                            NavigationLink(
                                destination: SubjectScreen(subject: item)
                                    .navigationTransition(
                                        .zoom(sourceID: item.id, in: namespace)
                                    )
                            ) {
                                SubjectCard(subject: item, onHide: {
                                    item.hidden.toggle()
                                })
                            }
                            .matchedTransitionSource(id: item.id, in: namespace)
                        }
                        if item.hidden && showHiddenSubjects {
                            NavigationLink(
                                destination: SubjectScreen(subject: item)
                                    .navigationTransition(
                                        .zoom(sourceID: item.id, in: namespace)
                                    )
                            ) {
                                SubjectCard(subject: item, onHide: {
                                    item.hidden.toggle()
                                })
                                .opacity(0.6)
                            }
                            .matchedTransitionSource(id: item.id, in: namespace)
                        }
                    }
                }
                .padding()
                Toggle("Show hidden subjects", isOn: $showHiddenSubjects)
                    .padding()
            }
            .navigationTitle("Subjects")
        }
    }
}

#Preview {
    SubjectsScreen()
}
