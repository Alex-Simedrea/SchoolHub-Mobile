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
            let currentTimeSlot = timeSlots.currentOrNextTimeSlot

            if let currentTimeSlot = currentTimeSlot {
                let nextOccurrence = currentTimeSlot.nextOccurrence
                var updateDate: Date
                if nextOccurrence.start < .now {
                    updateDate = nextOccurrence.end
                } else {
                    updateDate = nextOccurrence.start
                }

                let timeline = Timeline(entries: [TimetableEntry(date: .now)], policy: .after(updateDate))
                completion(timeline)
                return
            }

            let timeline = Timeline(
                entries: [TimetableEntry(date: .now)],
                policy: .after(
                    Calendar.current.date(byAdding: .hour, value: 24, to: .now)!
                )
            )
            completion(timeline)
        } catch {
            let timeline = Timeline(
                entries: [TimetableEntry(date: .now)],
                policy: .after(
                    Calendar.current.date(byAdding: .hour, value: 24, to: .now)!
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

    var maxSlots: Int {
        switch family {
        case .systemLarge: return 6
        default: return 8
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(Weekday(rawValue: currentDay)?.name ?? "")")
                .font(.headline.bold())
//            Text(entry.date, format: .dateTime)
            ForEach(timeSlots
                .filter { $0.weekday.rawValue == currentDay }
                .sorted { $0.isEarlier(than: $1) },
                id: \.id)
            { timeSlot in
                HStack {
                    VStack(alignment: .leading) {
                        if let subject = timeSlot.subject {
                            Text(subject.displayName)
                                .font(.callout.bold())
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
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(0)
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
