//
//  AveragesScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import SwiftUI
import SwiftData

struct AveragesScreen: View {
    @Environment(\.modelContext) private var context
    @State private var subjects: [Subject] = []
    @State private var firstAppear = true
    
    var body: some View {
        NavigationStack {
            AveragesView(subjects: subjects)
                .navigationTitle("Averages Calculator")
                .refreshable {
                    do {
                        subjects = try context.fetch(FetchDescriptor<Subject>(
                            predicate: #Predicate { $0.hidden == false }
                        ))
                    } catch {
                        print(error)
                    }
                }
        }
        .onAppear {
            do {
                if firstAppear {
                    subjects = try context.fetch(FetchDescriptor<Subject>(
                        predicate: #Predicate { $0.hidden == false }
                    ))
                    firstAppear = false
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    AveragesScreen()
}
