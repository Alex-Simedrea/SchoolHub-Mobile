//
//  SubjectAverageView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import SwiftUI

struct SubjectAverageView: View {
    let subject: Subject
    @StateObject private var viewModel: SubjectAverageViewModel
    @State private var showingSimulation = false
    @State private var simulatedGrade = 7
    
    init(subject: Subject, targetAverage: Int) {
        self.subject = subject
        self._viewModel = StateObject(
            wrappedValue: SubjectAverageViewModel(
                subject: subject,
                targetAverage: targetAverage
            )
        )
    }
    
    var body: some View {
        List {
            Section("Average") {
                LabeledContent {
                    Text("\(viewModel.simulation.average)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                } label: {
                    Text("Current Average")
                }
                
                LabeledContent {
                    TextField("Target Average", value: $viewModel.targetAverage, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Text("Target Average")
                }
            }
            
            Section("Suggestions to Reach Target") {
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
                        Text("Suggestions to Reach Target")
                            .font(.headline.bold())
                        Text("Any of the following suggestions will help you reach your target average")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                }
                if !viewModel.improvementSuggestions.isEmpty {
                    ForEach(viewModel.improvementSuggestions) { suggestion in
                        Text(suggestion.description)
                    }
                } else if viewModel.simulation.average < viewModel.targetAverage {
                    Text("Target average not achievable with reasonable number of grades")
                        .foregroundStyle(.secondary)
                } else {
                    Text("You already have the target average")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Real Grades") {
                ForEach(subject.unwrappedGrades) { grade in
                    Text("\(grade.value)")
                }
                if subject.unwrappedGrades.isEmpty {
                    Text("No grades")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Simulated Grades") {
                ForEach(viewModel.simulation.simulatedGrades) { grade in
                    Text("\(grade.value)")
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                viewModel.simulation.simulatedGrades.removeAll { $0.id == grade.id }
                            }
                        }
                }
                Button {
                    showingSimulation = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add simulated grade")
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(subject.name)
        .sheet(isPresented: $showingSimulation) {
            NavigationView {
                Form {
                    Picker("Grade", selection: $simulatedGrade) {
                        ForEach(1 ... 10, id: \.self) { grade in
                            Text("\(grade)").tag(grade)
                        }
                    }
                }
                .navigationTitle("Add Grade")
                .navigationBarItems(
                    leading: Button("Cancel") { showingSimulation = false },
                    trailing: Button("Add") {
                        viewModel.simulation.simulatedGrades.append(
                            GradeSimulation(value: simulatedGrade, isSimulated: true)
                        )
                        showingSimulation = false
                    }
                )
            }
        }
    }
}
