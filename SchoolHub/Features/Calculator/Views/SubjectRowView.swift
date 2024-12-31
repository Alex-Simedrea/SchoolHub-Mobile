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
                targetAverage: 10,
                averagesViewModel: viewModel
            )
        ) {
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
                            .font(simulatedSubject.isSimulated ? .body : .body.bold())
                            .foregroundStyle(
                                simulatedSubject.isSimulated
                                ? .secondary
                                : .primary)
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.foreground)
                }
            }
        }
        .onChange(of: simulatedSubject.simulatedAverage) {
            average = simulatedSubject.simulatedAverage
        }
    }
}
