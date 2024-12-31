//
//  SubjectAverageView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import SwiftUI

struct SubjectAverageView: View {
    let subject: Subject
    @ObservedObject var averagesViewModel: AveragesViewModel
    @StateObject private var viewModel: SubjectAverageViewModel
    @State private var showingSimulation = false
    @State private var simulatedGrade = 10
    
    init(subject: Subject, targetAverage: Int, averagesViewModel: AveragesViewModel) {
        self.subject = subject
        self.averagesViewModel = averagesViewModel
        self._viewModel = StateObject(
            wrappedValue: SubjectAverageViewModel(
                subject: subject,
                targetAverage: targetAverage,
                averagesViewModel: averagesViewModel
            )
        )
    }
    
    var body: some View {
        List {
            Section("Average") {
                LabeledContent {
                    HStack(spacing: 14) {
                        Text("\(viewModel.simulation.average)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if viewModel.simulation.averageDouble != Double(viewModel.simulation.average) {
                            Text("\(viewModel.simulation.averageDouble.gradeFormatted)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
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
                        .foregroundStyle(.white)
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
                                viewModel.removeSimulatedGrade(withID: grade.id)
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
        .navigationTitle(subject.displayName)
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
                        viewModel.addSimulatedGrade(simulatedGrade)
                        showingSimulation = false
                    }
                )
            }
        }
    }
}
