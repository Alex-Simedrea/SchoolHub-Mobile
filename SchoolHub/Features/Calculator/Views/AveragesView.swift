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
                            viewModel.overallAverage.gradeFormatted
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
                            .foregroundStyle(.white)
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
                                SubjectAverageView(
                                    subject: simulatedSubject.subject,
                                    targetAverage: simulatedSubject.simulatedAverage + increase,
                                    averagesViewModel: viewModel
                                )
                            }) {
                                HStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 28, height: 28)
                                        .foregroundStyle(simulatedSubject.subject.color.color.gradient)
                                        .overlay {
                                            Image(systemName: simulatedSubject.subject.symbolName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .padding(4)
                                                .foregroundStyle(.white)
                                        }
                                    Text(simulatedSubject.subject.displayName)
                                    Spacer()
                                    Text("Current: \(simulatedSubject.simulatedAverage)")
                                    Text("Target: \(simulatedSubject.simulatedAverage + increase)")
                                        .foregroundStyle(.blue)
                                        .font(.body.bold())
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
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button {
                    viewModel.resetAll()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
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
