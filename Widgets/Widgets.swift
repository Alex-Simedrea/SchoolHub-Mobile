//
//  Widgets.swift
//  Widgets
//
//  Created by Alexandru Simedrea on 03.11.2024.
//

import SwiftData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    var modelContext: ModelContext
    
    func placeholder(in context: Context) -> TimetableEntry {
        TimetableEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimetableEntry) -> ()) {
        let entry = TimetableEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let timeSlots = try modelContext.fetch(FetchDescriptor<TimeSlot>())
            let currentDay = Date.now.weekDay
            
            let todaySlots = timeSlots
                .filter { $0.weekday == currentDay }
                .sorted { $0.isEarlier(than: $1) }
            
            if todaySlots.isEmpty || (todaySlots.last?.nextOccurrence.end ?? .now) < .now {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
                let timeline = Timeline(
                    entries: [TimetableEntry(date: .now)],
                    policy: .after(
                        Calendar.current.startOfDay(for: tomorrow)
                    )
                )
                completion(timeline)
                return
            }
            
            var entries: [TimetableEntry] = []
            for slot in todaySlots {
                let nextOccurrence = slot.nextOccurrence
                
                if nextOccurrence.end >= .now {
                    entries.append(TimetableEntry(date: nextOccurrence.start))
                    entries.append(TimetableEntry(date: nextOccurrence.end))
                }
            }
            
            if entries.isEmpty {
                entries.append(TimetableEntry(date: .now))
            }
            
            entries.sort { $0.date < $1.date }
            
            if let lastSlot = todaySlots.last {
                let timeline = Timeline(
                    entries: entries,
                    policy: .after(lastSlot.nextOccurrence.end)
                )
                completion(timeline)
            } else {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
                let timeline = Timeline(
                    entries: entries,
                    policy: .after(
                        Calendar.current.startOfDay(for: tomorrow)
                    )
                )
                completion(timeline)
            }
            
        } catch {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
            let timeline = Timeline(
                entries: [TimetableEntry(date: .now)],
                policy: .after(
                    Calendar.current.startOfDay(for: tomorrow)
                )
            )
            completion(timeline)
        }
    }
}

struct TimetableEntry: TimelineEntry {
    let date: Date
}

struct WidgetsEntryView: View {
    var entry: Provider.Entry
    @Query private var subjects: [Subject]
    @Query private var timeSlots: [TimeSlot]
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    
    var currentTimeSlot: TimeSlot? {
        timeSlots.currentOrNextTimeSlot
    }
    
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
    
    var visibleTimeSlots: [TimeSlot] {
        let todaySlots = timeSlots
            .filter { $0.weekday.rawValue == currentDay }
            .sorted { $0.isEarlier(than: $1) }
        
        // If we have 6 or fewer slots, show them all
        if todaySlots.count <= 6 {
            return todaySlots
        }
        
        // Find the index of the first non-ended slot
        let currentIndex = todaySlots.firstIndex(where: { slot in
            return !slot.endTime.isTimeEarlier(than: .now)
        }) ?? 0
        
        // Calculate the range of slots to show
        let startIndex = min(currentIndex, todaySlots.count - 6)
        let endIndex = min(startIndex + 6, todaySlots.count)
        
        return Array(todaySlots[startIndex ..< endIndex])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(Weekday(rawValue: currentDay)?.name ?? "")")
                .font(.headline.bold())
            
            ForEach(visibleTimeSlots, id: \.id) { timeSlot in
                HStack {
                    VStack(alignment: .leading) {
                        if let subject = timeSlot.subject {
                            Text(subject.displayName)
                                .font(.callout.bold())
                                .foregroundStyle(.white)
                        }
//                        if let location = timeSlot.location, !location.isEmpty {
//                            Text(location)
//                                .font(.subheadline)
//                                .foregroundStyle(.white.opacity(0.8))
//                        }
                    }
                    if timeSlot == currentTimeSlot {
                        if let nextOccurrence = currentTimeSlot?.nextOccurrence {
                            if !(nextOccurrence.start < .now) {
                                Text("•")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text("Next Up")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("•")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text(
                                    nextOccurrence.end,
                                    style: .relative
                                )
                                .font(.callout.bold())
                                .foregroundStyle(.secondary)
                                .contentTransition(.interpolate)
                            }
                        }
                    }

                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(timeSlot.startTime.formatted(.dateTime.hour().minute()))
                            .font(.footnote)
                            .foregroundStyle(.white)
                        Text(timeSlot.endTime.formatted(.dateTime.hour().minute()))
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal)
                .background(
                    (timeSlot.subject?.color.color ?? Color.blue)
                        .gradient
                        .opacity(renderingMode == .accented ? 0.2 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            if timeSlots.filter({ $0.weekday.rawValue == currentDay }).count > 6 {
                Text("+ more classes today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(0)
        .animation(.default, value: visibleTimeSlots)
    }
}

struct Widgets: Widget {
    @Environment(\.modelContext) private var modelContext
    let kind: String = "Widgets"
    var container: ModelContainer
    
    init() {
        do {
            container = try .init(for: Subject.self, configurations: .init())
        } catch {
            fatalError("failed to create model container")
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider(modelContext: container.mainContext)
        ) { entry in
            if #available(iOS 17.0, *) {
                WidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(container)
            } else {
                WidgetsEntryView(entry: entry)
                    .padding()
                    .background()
                    .modelContainer(container)
            }
        }
        .configurationDisplayName("Timetable Widget")
        .description("Displays your timetable for the current day.")
        .supportedFamilies([.systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemSmall) {
    Widgets()
} timeline: {
    TimetableEntry(date: .now)
}
