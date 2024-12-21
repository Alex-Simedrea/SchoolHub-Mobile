//
//  TimetableScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 01.11.2024.
//

import SwiftData
import SwiftUI
import WidgetKit

struct TimetableScreen: View {
    @Query private var timeSlots: [TimeSlot]
    @Environment(\.modelContext) private var context
    @State private var index = 0
    @State private var scrollPosition: ScrollPosition = .init(idType: Weekday.ID.self)
    @State private var viewWidth: CGFloat = 0

    @Namespace private var namespace

    @State private var currentPage = 0

    func maxTimeSlotsInADay() -> Int {
        let timeSlotsByWeekday = Dictionary(grouping: timeSlots, by: \.weekday)
        return timeSlotsByWeekday.values.map(\.count).max() ?? 0
    }

    var remainingTimeSlotsUntilMax: Int {
        maxTimeSlotsInADay() - timeSlots.filter { $0.weekday == .monday }.count
    }

    @State private var currentTimeSlot: TimeSlot?

    var currentDay: Int {
        if let currentTimeSlot = currentTimeSlot {
            return currentTimeSlot.weekday.rawValue
        }

        let day = Date.now.weekDay.rawValue
        if day > 5 {
            return 1
        }
        return day
    }

    @State private var timer: Timer?
    
    @State private var currentTime = Date.now
    private let timeUpdateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private func scheduleNextUpdate() {
        timer?.invalidate()
        
        guard let nextTimeSlot = timeSlots.currentOrNextTimeSlot else {
            return
        }
        
        let now = Date.now
        let calendar = Calendar.current
        let currentWeekDay = now.weekDay
        let currentMinutes = calendar.minutesSinceMidnight(for: now)
        
        if nextTimeSlot.weekday == currentWeekDay {
            let slotStartMinutes = calendar.minutesSinceMidnight(for: nextTimeSlot.startTime)
            let slotEndMinutes = calendar.minutesSinceMidnight(for: nextTimeSlot.endTime)
            
            if currentMinutes <= slotStartMinutes {
                let startTime = calendar.date(bySettingMinutesSinceMidnight: slotStartMinutes, for: now) ?? now
                let startInterval = startTime.timeIntervalSince(now)
                
                if startInterval > 0 {
                    Timer.scheduledTimer(withTimeInterval: startInterval, repeats: false) { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                self.currentTimeSlot = self.timeSlots.currentOrNextTimeSlot
                            }
                            self.scheduleNextUpdate()
                        }
                    }
                }
            }
            
            // Schedule timer for slot end
            if currentMinutes < slotEndMinutes {
                let endTime = calendar.date(bySettingMinutesSinceMidnight: slotEndMinutes, for: now) ?? now
                let endInterval = endTime.timeIntervalSince(now)
                
                if endInterval > 0 {
                    Timer.scheduledTimer(withTimeInterval: endInterval, repeats: false) { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                self.currentTimeSlot = self.timeSlots.currentOrNextTimeSlot
                            }
                            self.scheduleNextUpdate()
                        }
                    }
                }
            }
        } else {
            let nextDay = calendar.startOfDay(for: now.addingTimeInterval(24*60*60))
            let interval = nextDay.timeIntervalSince(now)
            
            if interval > 0 {
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                    DispatchQueue.main.async {
                        withAnimation {
                            self.currentTimeSlot = self.timeSlots.currentOrNextTimeSlot
                        }
                        self.scheduleNextUpdate()
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            if !ProcessInfo.processInfo.isOnMac {
                ScrollView {
                    HStack {
                        ForEach(Weekday.weekdays, id: \.id) { weekday in
                            Button {
                                withAnimation {
                                    scrollPosition.scrollTo(id: weekday.id, anchor: .center)
                                }
                            } label: {
                                if (scrollPosition.viewID(type: Weekday.ID.self) ?? 0) == (weekday.id) {
                                    Text(weekday.name)
                                        .padding()
                                        .cornerRadius(8)
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                } else {
                                    Text(weekday.name.prefix(1))
                                        .padding()
                                        .cornerRadius(8)
                                        .foregroundStyle(
                                            (
                                                Date.now.weekDay.name == weekday.name
                                            ) ? Color.blue : Color.primary
                                        )
                                        .font(.headline)
                                }
                            }
                            .background {
                                if (scrollPosition.viewID(type: Weekday.ID.self) ?? 0) == (weekday.id) {
                                    Capsule()
                                        .foregroundColor(.blue)
                                        .matchedGeometryEffect(id: "selected", in: namespace)
                                }
                            }
                            if weekday.id != Weekday.weekdays.last?.id {
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .padding()
                    .animation(.smooth(duration: 0.3), value: scrollPosition.viewID(type: Weekday.ID.self))
                    .frame(maxWidth: .infinity)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Weekday.weekdays) { weekday in
                                VStack {
                                    ForEach(timeSlots
                                        .filter { $0.weekday == weekday }
                                        .sorted { $0.isEarlier(than: $1) },
                                        id: \.id)
                                    { timeSlot in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                if let subject = timeSlot.subject {
                                                    Text(subject.displayName)
                                                        .font(.headline)
                                                        .foregroundStyle(.white)
                                                }
                                                if let location = timeSlot.location, !location.isEmpty {
                                                    Text(location)
                                                        .font(.subheadline)
                                                        .foregroundStyle(.white.opacity(0.8))
                                                }
                                            }
                                            if timeSlot == currentTimeSlot {
                                                if let nextOccurrence = currentTimeSlot?.nextOccurrence {
                                                    if !(nextOccurrence.start < currentTime) {
                                                        Text("Next Up")
                                                            .font(.callout.bold())
                                                            .padding(.horizontal, 12)
                                                            .padding(.vertical, 2)
                                                            .foregroundStyle(.clear)
                                                            .background {
                                                                Capsule()
                                                                    .foregroundColor(.white)
                                                            }
                                                            .overlay {
                                                                Text("Next Up")
                                                                    .font(.callout.bold())
                                                                    .padding(.horizontal, 12)
                                                                    .padding(.vertical, 2)
                                                                    .blendMode(.destinationOut)
                                                            }
                                                            .compositingGroup()
                                                    } else {
                                                        Text(nextOccurrence.end, style: .relative)
                                                            .font(.callout.bold())
                                                            .padding(.horizontal, 12)
                                                            .padding(.vertical, 2)
                                                            .foregroundStyle(.clear)
                                                            .background {
                                                                Capsule()
                                                                    .foregroundColor(.white)
                                                            }
                                                            .overlay {
                                                                Text(nextOccurrence.end, style: .relative)
                                                                    .font(.callout.bold())
                                                                    .padding(.horizontal, 12)
                                                                    .padding(.vertical, 2)
                                                                    .blendMode(.destinationOut)
                                                            }
                                                            .compositingGroup()
                                                    }
                                                }
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing) {
                                                Text(timeSlot.startTime.formatted(.dateTime.hour().minute()))
                                                    .font(.headline)
                                                    .foregroundStyle(.white)
                                                Text(timeSlot.endTime.formatted(.dateTime.hour().minute()))
                                                    .font(.headline)
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal)
                                        .background(
                                            (timeSlot.subject?.color.color ?? Color.blue).gradient
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                context.delete(timeSlot)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    WidgetCenter.shared.reloadAllTimelines()
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .frame(width: viewWidth, alignment: .top)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition($scrollPosition)
                    .scrollTargetBehavior(.paging)
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                viewWidth = geo.size.width
                            }
                            .onChange(of: geo.size.width) {
                                viewWidth = geo.size.width
                            }
                            .frame(height: 0)
                    }
                }
                .task {
                    scrollPosition.scrollTo(id: currentDay, anchor: .center)
                }
                .onAppear {
                    index = Date.now.weekDay.id < 6 ? Date.now.weekDay.id : 1
                    currentTimeSlot = timeSlots.currentOrNextTimeSlot
                    scheduleNextUpdate()
                }
                .onDisappear {
                    timer?.invalidate()
                    timeUpdateTimer.upstream.connect().cancel()
                }
                .onReceive(timeUpdateTimer) { time in
                    currentTime = time
                    if let current = currentTimeSlot,
                       current.nextOccurrence.start <= time {
                        currentTimeSlot = timeSlots.currentOrNextTimeSlot
                    }
                }
                .navigationTitle("Timetable")
            } else {
                ScrollView {
                    VStack {
                        Picker("Weekday", selection: $index) {
                            ForEach(Weekday.weekdays, id: \.id) { weekday in
                                Text(weekday.name)
                            }
                        }
                        .pickerStyle(.segmented)

                        ForEach(timeSlots
                            .filter { $0.weekday == Weekday(rawValue: index) }
                            .sorted { $0.isEarlier(than: $1) },
                            id: \.id)
                        { timeSlot in
                            HStack {
                                VStack(alignment: .leading) {
                                    if let subject = timeSlot.subject {
                                        Text(subject.displayName)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                    if let location = timeSlot.location, !location.isEmpty {
                                        Text(location)
                                            .font(.subheadline)
                                            .foregroundStyle(.white.secondary)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(timeSlot.startTime.formatted(.dateTime.hour().minute()))
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.trailing)
                                    Text(timeSlot.endTime.formatted(.dateTime.hour().minute()))
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            .padding()
                            .background(
                                (timeSlot.subject?.color.color ?? Color.blue).gradient
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .contextMenu {
                                Button(role: .destructive) {
                                    context.delete(timeSlot)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        WidgetCenter.shared.reloadAllTimelines()
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    index = Date.now.weekDay.id < 6 ? Date.now.weekDay.id : 0
                }
                .navigationTitle("Timetable")
            }
        }
        .onAppear {
            index = Date.now.weekDay.id < 6 ? Date.now.weekDay.id : 0
        }
    }
}

#Preview {
    TimetableScreen()
}
