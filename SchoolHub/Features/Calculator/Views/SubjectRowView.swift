//
//  SubjectRowView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import SwiftUI

struct SubjectRowView: View {
    let simulatedSubject: AverageSubjectSimulation
    @ObservedObject var viewModel: AveragesViewModel
    @State private var average: Int

    init(
        simulatedSubject: AverageSubjectSimulation,
        viewModel: AveragesViewModel
    ) {
        self.simulatedSubject = simulatedSubject
        self.viewModel = viewModel
        self._average = State(initialValue: simulatedSubject.simulatedAverage)
    }

    var body: some View {
        NavigationLink(
            destination: SubjectAverageView(
                subject: simulatedSubject.subject,
                targetAverage: 10
            )
        ) {
            HStack {
                Text(simulatedSubject.subject.displayName)
                Spacer()
                if simulatedSubject.isSimulated && simulatedSubject.originalAverage != nil {
                    Button {
                        viewModel.updateSubjectSimulation(
                            subject: simulatedSubject.subject,
                            simulatedAverage: nil
                        )
                        average = Int(round(simulatedSubject.subject.average ?? 10))
                    } label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                    }
                    .buttonStyle(.borderless)
                }
                Menu {
                    Section("Simulate an average") {
                        Picker("Simulate average", selection: $average) {
                            ForEach(1 ... 10, id: \.self) { value in
                                if value == Int(round(simulatedSubject.originalAverage ?? -1)) {
                                    Text("\(value) • original")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("\(value)")
                                }
                            }
                        }
                        .onChange(of: average) { _, newValue in
                            viewModel.updateSubjectSimulation(
                                subject: simulatedSubject.subject,
                                simulatedAverage: newValue
                            )
                        }
                    }
                } label: {
                    HStack {
                        Text("\(simulatedSubject.simulatedAverage)")
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .foregroundStyle(
                        simulatedSubject.isSimulated
                            ? .secondary
                            : .primary)
                    .foregroundStyle(.foreground)
                }
            }
        }
    }
}
