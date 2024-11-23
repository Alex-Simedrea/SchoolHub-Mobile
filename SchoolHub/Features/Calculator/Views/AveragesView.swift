//
//  AveragesView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import SwiftUI

struct AveragesView: View {
    let subjects: [Subject]
    @ObservedObject private var viewModel: AveragesViewModel = .init()
    @State private var firstAppear = true
    
    var body: some View {
        List {
            Section("Overall Average") {
                LabeledContent {
                    HStack {
                        Text(
                            String(format: "%.2f", viewModel.overallAverage)
                        )
                        .foregroundStyle(.primary)
                        .font(.headline)
                    }
                } label: {
                    Text("Current Average")
                }
                
                LabeledContent {
                    TextField("Target Average", value: $viewModel.targetOverallAverage, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Text("Target Average")
                }
            }
            
            if !viewModel.improvementSuggestions.isEmpty {
                Section("Suggestions for improvement") {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.blue.gradient)
                            }
                        VStack(alignment: .leading) {
                            Text("Suggestions for improvement")
                                .font(.headline.bold())
                            Text("Changes to reach the given target, based on the current average.")
                                .foregroundStyle(.secondary)
                                .font(.callout)
                        }
                    }
                    ForEach(viewModel.improvementSuggestions, id: \.0.id) { simulatedSubject, increase in
                        NavigationLink(destination:
                            NavigationStack {
                                SubjectAverageView(subject: simulatedSubject.subject, targetAverage: simulatedSubject.simulatedAverage + increase)
                            }) {
                                HStack {
                                    Text(simulatedSubject.subject.displayName)
                                    Spacer()
                                    Text("Current: \(simulatedSubject.simulatedAverage)")
                                    Text("Target: \(simulatedSubject.simulatedAverage + increase)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                    }
                }
            }
            
            Section("Subjects") {
                ForEach(viewModel.simulatedSubjects.sorted { $0.subject.displayName < $1.subject.displayName }) { simSubject in
                    SubjectRowView(simulatedSubject: simSubject, viewModel: viewModel)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: subjects) { _, newSubjects in
            viewModel.updateSimulations(with: newSubjects)
        }
        .onAppear {
            if firstAppear {
                viewModel.updateSimulations(with: subjects)
                firstAppear = false
            }
        }
    }
}
