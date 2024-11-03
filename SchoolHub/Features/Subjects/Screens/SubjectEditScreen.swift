//
//  SubjectEditScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 31.10.2024.
//

import SwiftData
import SwiftUI
//import SFSymbolsPicker
import SymbolPicker

struct ColorPicker: View {
    @Binding var color: SubjectColor

    var body: some View {
        Picker("Color", selection: $color) {
            ForEach(
                SubjectColor.allCases,
                id: \.id
            ) { color in
                Text(color.name).tag(color)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(color.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .foregroundStyle(.white)
            }
        }
        .pickerStyle(.navigationLink)
    }
}

struct SubjectEditScreen: View {
    @State var subject: Subject
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSymbolPickerPresented = false

    @State private var editingSubject: Subject = .init(
        name: "",
        grades: [],
        absences: []
    )

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $editingSubject.displayName)
                        .multilineTextAlignment(.leading)
                } header: {
                    Text("Display Name")
                } footer: {
                    Text("Original name: \(subject.name)")
                }
                Section("Appearance") {
                    ColorPicker(color: $editingSubject.color)
                    HStack {
                        Button("Choose Icon") {
                            isSymbolPickerPresented.toggle()
                        }
                        Spacer()
                        Image(systemName: editingSubject.symbolName)
                            .foregroundStyle(editingSubject.color.color)
                    }
                    Toggle("Hidden", isOn: $editingSubject.hidden)
                }
            }
            .navigationTitle("Edit Subject")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        subject.displayName = editingSubject.displayName
                        subject.color = editingSubject.color
                        subject.symbolName = editingSubject.symbolName
                        subject.hidden = editingSubject.hidden
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            editingSubject = .init(
                name: subject.name,
                grades: [],
                absences: [],
                color: subject.color,
                symbolName: subject.symbolName,
                displayName: subject.displayName,
                hidden: subject.hidden
            )
        }
        .sheet(isPresented: $isSymbolPickerPresented) {
            SymbolPicker(symbol: $editingSubject.symbolName)
//            SymbolsPicker(selection: $editingSubject.symbolName, title: "Choose an icon")
        }
    }
}

//#Preview {
//    SubjectEditScreen(subject: .constant(.init(name: "Math", grades: [], absences: [])))
//}
