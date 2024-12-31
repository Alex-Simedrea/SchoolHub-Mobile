//
//  LiveActivitySettingsScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 22.12.2024.
//

#if canImport(ActivityKit)
import ActivityKit
import Alamofire
import SwiftData
import SwiftUI
import Toasts

struct LiveActivitySettingsScreen: View {
    @Environment(\.presentToast) var presentToast
    
    @AppStorage("liveActivityEnabled") var liveActivityEnabled = false
    @AppStorage("liveActivityIsPaused") var liveActivityIsPaused = false
    @AppStorage("liveActivityPauseUntil") var liveActivityPauseUntil: Date = .now
    
    @Query private var timeSlots: [TimeSlot]
    @Query private var subjects: [Subject]
    
    @State private var isLoading: Bool = false
    @State private var previousLiveActivityEnabled: Bool = false
    @State private var previousLiveActivityIsPaused: Bool = false
    @State private var previousLiveActivityPauseUntil: Date = .now
    
    var timeSlotsPair: (current: TimeSlot?, next: TimeSlot?) {
        let currentOrNextTimeSlot = timeSlots.currentOrNextTimeSlot
        
        let today = Date.now.weekDay
        let timeSlotsToday = timeSlots.filter { $0.weekday == today }
        
        if let current = currentOrNextTimeSlot {
            if current.weekday == today {
                let nextTimeSlot = timeSlotsToday.first {
                    $0.isLater(than: current)
                }
                
                return (current, nextTimeSlot)
            }
        }
        
        return (nil, nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        VStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Image(systemName: "clock.badge.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(12)
                                        .foregroundStyle(.white)
                                }
                            Text("Timetable Live Activity")
                                .font(.title3.bold())
                                .padding(.bottom, 2)
                            Text("Show a Live Activity on the Lock Screen and Dynamic Island with the current time slot that updates automatically.")
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    Toggle("Live Activity", isOn: $liveActivityEnabled)
                        .disabled(isLoading)
                }
                if liveActivityEnabled {
                    Section {
                        Toggle("Pause Live Activity", isOn: $liveActivityIsPaused)
                        if liveActivityIsPaused {
                            DatePicker(
                                "Pause Until",
                                selection: $liveActivityPauseUntil,
                                in: .now.addingTimeInterval(60 * 60 * 24)...,
                                displayedComponents: .date
                            )
                        }
                    }
                }
                Section {
                    Button("Try a demo") {
                        startLiveActivityDemo()
                    }
                }
            }
            .navigationTitle("Live Activity")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                previousLiveActivityEnabled = liveActivityEnabled
                previousLiveActivityIsPaused = liveActivityIsPaused
                previousLiveActivityPauseUntil = liveActivityPauseUntil
            }
            .onChange(of: liveActivityEnabled) {
                guard liveActivityEnabled != previousLiveActivityEnabled, !isLoading else {
                    return
                }
                
                let oldValue = previousLiveActivityEnabled
                previousLiveActivityEnabled = liveActivityEnabled
                isLoading = true
                
                if liveActivityEnabled {
                    enableLiveActivity { success in
                        if !success {
                            previousLiveActivityEnabled = oldValue
                            liveActivityEnabled = oldValue
                        }
                        isLoading = false
                    }
                } else {
                    disableLiveActivity { success in
                        if !success {
                            previousLiveActivityEnabled = oldValue
                            liveActivityEnabled = oldValue
                        }
                        isLoading = false
                    }
                }
            }
            .onChange(of: liveActivityIsPaused) {
                guard liveActivityIsPaused != previousLiveActivityIsPaused, !isLoading else {
                    return
                }
                
                let oldValue = previousLiveActivityIsPaused
                previousLiveActivityIsPaused = liveActivityIsPaused
                isLoading = true
                
                if liveActivityIsPaused {
                    pauseLiveActivity { success in
                        if !success {
                            previousLiveActivityIsPaused = oldValue
                            liveActivityIsPaused = oldValue
                        }
                        isLoading = false
                    }
                } else {
                    resumeLiveActivity { success in
                        if !success {
                            previousLiveActivityIsPaused = oldValue
                            liveActivityIsPaused = oldValue
                        }
                        isLoading = false
                    }
                }
            }
            .onChange(of: liveActivityPauseUntil) {
                guard liveActivityPauseUntil != previousLiveActivityPauseUntil, !isLoading else {
                    return
                }
                
                let oldValue = previousLiveActivityPauseUntil
                previousLiveActivityPauseUntil = liveActivityPauseUntil
                isLoading = true
                
                pauseLiveActivity { success in
                    if !success {
                        previousLiveActivityPauseUntil = oldValue
                        liveActivityPauseUntil = oldValue
                    }
                    isLoading = false
                }
            }
        }
    }
    
    func enableLiveActivity(completion: @escaping (Bool) -> Void) {
        let timetable: [TimetableSubjectDTO] = subjects.map {
            TimetableSubjectDTO(
                displayName: $0.displayName,
                symbolName: $0.symbolName,
                color: $0.color,
                timeSlots: $0.timeSlots?.map { timeSlot in
                    TimetableSubjectDTO
                        .TimeSlotDTO(
                            weekday: timeSlot.weekday.rawValue,
                            startTime: timeSlot.startTime,
                            endTime: timeSlot.endTime
                        )
                } ?? []
            )
        }
        AF.request(TimetableRouter.postTimetable(timetable: timetable)).response { response in
            switch response.result {
            case .success:
                print("response: \(response.debugDescription)")
                completion(true)
            case .failure:
                let toast = ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red),
                    message: "Error enabling Live Activity"
                )
                DispatchQueue.main.async {
                    presentToast(toast)
                }
                completion(false)
            }
        }
    }
    
    func disableLiveActivity(completion: @escaping (Bool) -> Void) {
        AF.request(TimetableRouter.deleteTimetable).response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure:
                let toast = ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red),
                    message: "Error disabling Live Activity"
                )
                DispatchQueue.main.async {
                    presentToast(toast)
                }
                completion(false)
            }
        }
    }
    
    func pauseLiveActivity(completion: @escaping (Bool) -> Void) {
        AF
            .request(TimetableRouter.pauseTimetable(timestamp: liveActivityPauseUntil))
            .response { response in
                switch response.result {
                case .success:
                    completion(true)
                case .failure:
                    let toast = ToastValue(
                        icon: Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red),
                        message: "Error pausing Live Activity"
                    )
                    DispatchQueue.main.async {
                        presentToast(toast)
                    }
                    completion(false)
                }
            }
    }
    
    func resumeLiveActivity(completion: @escaping (Bool) -> Void) {
        AF.request(TimetableRouter.resumeTimetable).response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure:
                let toast = ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red),
                    message: "Error resuming Live Activity"
                )
                DispatchQueue.main.async {
                    presentToast(toast)
                }
                completion(false)
            }
        }
    }
    
    func startLiveActivityDemo() {
        if let current = timeSlotsPair.current {
            let initialContentState: TimetableAttributes.ContentState
            
            let startTime = current.startTime
            let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: startTime)
            var todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
            todayComponents.hour = timeComponents.hour
            todayComponents.minute = timeComponents.minute
            todayComponents.second = timeComponents.second
            let startDate = Calendar.current.date(from: todayComponents)
            
            let endTime = current.endTime
            let endTimeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: endTime)
            todayComponents.hour = endTimeComponents.hour
            todayComponents.minute = endTimeComponents.minute
            todayComponents.second = endTimeComponents.second
            let endDate = Calendar.current.date(from: todayComponents)
            
            if current.startTime.isTimeEarlier(than: .now) {
                initialContentState = TimetableAttributes.ContentState(
                    displayName: current.subject?.displayName ?? "",
                    color: current.subject?.color.rawValue ?? "blue",
                    symbolName: current.subject?.symbolName ?? "graduationcap.fill",
                    startTime: nil,
                    endTime: endDate?
                        .ISO8601Format() ?? Date.now.ISO8601Format(),
                    nextTimeSlot: timeSlotsPair.next == nil ? nil : .init(
                        displayName: timeSlotsPair.next?.subject?.displayName ?? "",
                        color: timeSlotsPair.next?.subject?.color.rawValue ?? "blue",
                        symbolName: timeSlotsPair.next?.subject?.symbolName ?? "graduationcap.fill"
                    )
                )
            } else {
                initialContentState = TimetableAttributes.ContentState(
                    displayName: current.subject?.displayName ?? "",
                    color: current.subject?.color.rawValue ?? "blue",
                    symbolName: current.subject?.symbolName ?? "graduationcap.fill",
                    startTime: startDate?
                        .ISO8601Format() ?? Date.now.ISO8601Format(),
                    endTime: nil,
                    nextTimeSlot: nil
                )
            }
            
            do {
                let activity = try Activity<TimetableAttributes>.request(
                    attributes: .init(),
                    content: .init(
                        state: initialContentState,
                        staleDate: .now.addingTimeInterval(60 * 60 * 8)
                        
                    ),
                    pushType: .token
                )
                print("Live Activity started: \(activity.id)")
            } catch {
                print("Failed to start Live Activity: \(error.localizedDescription)")
            }
        } else {
            let initialContentState = TimetableAttributes.ContentState(
                displayName: "Math",
                color: "blue",
                symbolName: "x.squareroot",
                startTime: nil,
                endTime: Date.now.addingTimeInterval(60 * 60).ISO8601Format(),
                nextTimeSlot: .init(
                    displayName: "Physics",
                    color: "green",
                    symbolName: "atom"
                )
            )
            
            do {
                let activity = try Activity<TimetableAttributes>.request(
                    attributes: .init(),
                    content: .init(
                        state: initialContentState,
                        staleDate: .now.addingTimeInterval(60 * 60 * 8)
                        
                    ),
                    pushType: .token
                )
                print("Live Activity started: \(activity.id)")
            } catch {
                print("Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    LiveActivitySettingsScreen()
}

#endif
