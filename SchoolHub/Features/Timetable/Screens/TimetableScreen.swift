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
    @Namespace private var namespace
    @State private var viewWidth: CGFloat = 0
    @State private var viewHeight: CGFloat = 0

//    private var currentWeekday: Weekday {
//        Weekday.weekdays[index]
//    }

    func maxTimeSlotsInADay() -> Int {
        let timeSlotsByWeekday = Dictionary(grouping: timeSlots, by: \.weekday)
        return timeSlotsByWeekday.values.map(\.count).max() ?? 0
    }

    var remainingTimeSlotsUntilMax: Int {
        maxTimeSlotsInADay() - timeSlots.filter { $0.weekday == .monday }.count
    }

    var body: some View {
        NavigationStack {
            if !ProcessInfo.processInfo.isOnMac {
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
                .frame(height: 0)
                ScrollView {
                    HStack {
                        ForEach(Weekday.weekdays, id: \.id) { weekday in
                            Button {
                                index = weekday.id - 1
                            } label: {
                                if index == weekday.id - 1 {
                                    Text(weekday.name)
                                        .padding()
                                        .cornerRadius(8)
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                } else {
                                    Text(weekday.shortName.prefix(1))
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
                                if index == weekday.id - 1 {
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
                    .padding(.horizontal)
                    .animation(.smooth(duration: 0.3), value: index)
                    .frame(maxWidth: .infinity)

                    LoopingScrollView(
                        width: viewWidth,
                        spacing: 0,
                        items: Weekday.weekdays,
                        currentIndex: $index
                    ) { weekday in
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
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }

                            if weekday == .monday {
                                ForEach(0 ..< maxTimeSlotsInADay() - timeSlots.filter { $0.weekday == .monday }.count, id: \.self) { _ in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Free")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text("00:00")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                            Text("00:00")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(Color.blue.gradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .opacity(0)
                                }
                            }
                        }
                        .padding()
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .scrollTargetBehavior(.paging)
                    .onAppear {
                        index = Date.now.weekDay.id < 6 ? Date.now.weekDay.id - 1 : 0
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
                                    }
                                    if let location = timeSlot.location, !location.isEmpty {
                                        Text(location)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(timeSlot.startTime.formatted(.dateTime.hour().minute()))
                                        .font(.headline)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.trailing)
                                    Text(timeSlot.endTime.formatted(.dateTime.hour().minute()))
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
                    index = Date.now.weekDay.id < 6 ? Date.now.weekDay.id : 1
                }
                .navigationTitle("Timetable")
//                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    TimetableScreen()
}
