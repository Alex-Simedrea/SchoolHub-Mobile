//
//  HomeScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel = .init()
    @Query private var subjects: [Subject]
    @State private var json: String = ""
    @Environment(\.modelContext) private var context
    @State private var isLoginPresented: Bool = false
    @State private var isConfirmingDeletion: Bool = false
    @State private var isShowingFormatGuide: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("JSON", text: $json)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    Button("Import") {
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .iso8601
                            let subjectsDTO = try decoder.decode([SubjectDTO].self, from: json.data(using: .utf8)!)
                            
                            try context.delete(model: Subject.self)
                            
                            for subjectDTO in subjectsDTO {
                                let subject = Subject(
                                    name: subjectDTO.name,
                                    grades: [],
                                    absences: [],
                                    color: subjectDTO.color,
                                    displayName: subjectDTO.displayName,
                                    hidden: subjectDTO.hidden)
                                
                                for gradeDTO in subjectDTO.grades {
                                    let grade = Grade(
                                        value: gradeDTO.value, date: gradeDTO.date)
                                    subject.grades.append(grade)
                                }
                                
                                for absenceDTO in subjectDTO.absences {
                                    let absence = Absence(
                                        date: absenceDTO.date,
                                        excused: absenceDTO.excused)
                                    subject.absences.append(absence)
                                }
                                
                                for timeSlotDTO in subjectDTO.timeSlots {
                                    let timeSlot = TimeSlot(
                                        weekday: timeSlotDTO.weekday, startTime: timeSlotDTO.startTime, endTime: timeSlotDTO.endTime)
                                    subject.timeSlots.append(timeSlot)
                                }
                                
                                context.insert(subject)
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                } header: {
                    Text("Import from JSON")
                } footer: {
                    Button("Show format guide...") {
                        isShowingFormatGuide = true
                    }
                }
                .headerProminence(.increased)
                Section("Import from NIC") {
                    if Auth.shared.loggedIn {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.gray)
                            Text(viewModel.username ?? "Username")
                        }
                        Button("Log out", role: .destructive) {
                            viewModel.logout()
                        }
                    } else {
                        Button("Login") {
                            isLoginPresented = true
                        }
                    }
                }
                .headerProminence(.increased)
                Button {
                    do {
                        let jsonData = try subjects.exportToJSON()
                        let jsonString = String(data: jsonData, encoding: .utf8)!
                        print(jsonString)
                        UIPasteboard.general
                            .setValue(
                                jsonString,
                                forPasteboardType: UTType.plainText.identifier)
                    } catch {
                        print(error)
                    }
                } label: {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy all data as JSON")
                    }
                }
                Button(role: .destructive) {
                    isConfirmingDeletion = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete all data")
                    }
                }
                .confirmationDialog(
                    "Are you sure you want to delete all data?",
                    isPresented: $isConfirmingDeletion)
                {
                    Button("Delete", role: .destructive) {
                        try? context.delete(model: Subject.self)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $isLoginPresented) {
                LoginScreen()
            }
            .sheet(isPresented: $isShowingFormatGuide) {
                NavigationStack {
                    ScrollView {
                        Text("""
                    {
                        "name": "String (Full name of the subject)",
                        "displayName": "String (Short/display name of the subject)",
                        "hidden": "Boolean (true/false)",
                        "color": "String (one of: red, blue, green, yellow, purple, orange, pink, mint, teal, cyan, indigo, brown)",
                        "symbolName": "String (SF Symbol name)",
                        "id": "String (UUID format)",
                        "timeSlots": [
                            {
                                "id": "String (UUID format)",
                                "weekday": "Integer (1-7, where 1 is Monday)",
                                "startTime": "String (ISO 8601 date format)",
                                "endTime": "String (ISO 8601 date format)",
                                "location": "String (can be empty)"
                            }
                        ],
                        "grades": [
                            {
                                "id": "String (UUID format)",
                                "value": "Integer",
                                "date": "String (ISO 8601 date format)"
                            }
                        ],
                        "absences": [
                            {
                                "id": "String (UUID format)",
                                "date": "String (ISO 8601 date format)",
                                "excused": "Boolean (true/false)"
                            }
                        ]
                    }
                    """)
                        .padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                isShowingFormatGuide = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
