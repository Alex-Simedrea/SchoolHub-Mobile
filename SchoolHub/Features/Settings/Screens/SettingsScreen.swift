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
    @Query private var grades: [Grade]
    @Query private var absences: [Absence]
    @Query private var timeSlots: [TimeSlot]
    @State private var json: String = ""
    @Environment(\.modelContext) private var context
    @State private var isLoginPresented: Bool = false
    @State private var isConfirmingDeleteAll: Bool = false
    @State private var isConfirmingDeleteGradesAndAbsences: Bool = false
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
                                if let existingSubject = subjects.first(where: { $0.name == subjectDTO.name }) {
                                    for grade in existingSubject.unwrappedGrades {
                                        context.delete(grade)
                                    }
                                    
                                    if let grades = subjectDTO.grades {
                                        for grade in grades {
                                            let grade = Grade(
                                                value: grade.value, date: grade.date)
                                            existingSubject.grades?.append(grade)
                                        }
                                    }
                                    
                                    for absence in existingSubject.unwrappedAbsences {
                                        context.delete(absence)
                                    }
                                    
                                    if let absences = subjectDTO.absences {
                                        for absence in absences {
                                            let absence = Absence(
                                                date: absence.date, excused: absence.excused)
                                            existingSubject.absences?.append(absence)
                                        }
                                    }
                                } else {
                                    let subject = Subject(
                                        name: subjectDTO.name,
                                        grades: [],
                                        absences: [],
                                        color: subjectDTO.color,
                                        symbolName: subjectDTO.symbolName,
                                        displayName: subjectDTO.displayName,
                                        hidden: subjectDTO.hidden)
                                    
                                    if let grades = subjectDTO.grades {
                                        for gradeDTO in grades {
                                            let grade = Grade(
                                                value: gradeDTO.value, date: gradeDTO.date)
                                            subject.grades?.append(grade)
                                        }
                                    }
                                    
                                    if let absences = subjectDTO.absences {
                                        for absenceDTO in absences {
                                            let absence = Absence(
                                                date: absenceDTO.date,
                                                excused: absenceDTO.excused)
                                            subject.absences?.append(absence)
                                        }
                                    }
                                    
                                    if let timeSlots = subjectDTO.timeSlots {
                                        for timeSlotDTO in timeSlots {
                                            let timeSlot = TimeSlot(
                                                weekday: timeSlotDTO.weekday, startTime: timeSlotDTO.startTime, endTime: timeSlotDTO.endTime)
                                            subject.timeSlots?.append(timeSlot)
                                        }
                                    }
                                    
                                    context.insert(subject)
                                }
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
                Section("Import from other gradebooks") {
                    if Auth.shared.loggedIn {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.gray)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Auth.shared.getCredentials().username ?? "Username")
                                Text(Auth.shared.getCredentials().requestUrl ?? "URL")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                    .contextMenu {
                                        Button {
                                            UIPasteboard.general.setValue(
                                                Auth.shared.getCredentials().requestUrl ?? "",
                                                forPasteboardType: UTType.plainText.identifier)
                                        } label: {
                                            Label("Copy URL", systemImage: "doc.on.doc")
                                        }
                                    }
                            }
                        }
                        Button("Log out", role: .destructive) {
                            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                            Auth.shared.logout()
                        }
                    } else {
                        Button("Login") {
                            isLoginPresented = true
                        }
                    }
                }
                .headerProminence(.increased)
                
#if canImport(ActivityKit)
                Section("Settings") {
                    NavigationLink(destination: LiveActivitySettingsScreen()) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: 30, height: 30)
                                .overlay {
                                    Image(systemName: "clock.badge.fill")
                                        .foregroundStyle(.white)
                                }
                            Text("Live Activity")
                        }
                    }
                }
                .headerProminence(.increased)
#endif
                
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
                    isConfirmingDeleteGradesAndAbsences = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete grades and absences")
                    }
                }
                .confirmationDialog(
                    "Are you sure you want to delete all grades and absences?",
                    isPresented: $isConfirmingDeleteGradesAndAbsences)
                {
                    Button("Delete", role: .destructive) {
                        for grade in grades {
                            context.delete(grade)
                        }
                        
                        for absence in absences {
                            context.delete(absence)
                        }
                        
                        for subject in subjects {
                            for grade in subject.unwrappedGrades {
                                context.delete(grade)
                            }
                            
                            for absence in subject.unwrappedAbsences {
                                context.delete(absence)
                            }
                        }
                    }
                }
                Button(role: .destructive) {
                    isConfirmingDeleteAll = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete all data")
                    }
                }
                .confirmationDialog(
                    "Are you sure you want to delete all data?",
                    isPresented: $isConfirmingDeleteAll)
                {
                    Button("Delete", role: .destructive) {
                        for grade in grades {
                            context.delete(grade)
                        }
                        for absence in absences {
                            context.delete(absence)
                        }
                        for timeSlot in timeSlots {
                            context.delete(timeSlot)
                        }
                        for subject in subjects {
                            context.delete(subject)
                        }
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
