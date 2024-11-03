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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct WidgetsEntryView: View {
    var entry: Provider.Entry
    @Query private var subjects: [Subject]
    @Query private var timeSlots: [TimeSlot]
    @Environment(\.widgetFamily) private var family
    var currentDay: Int {
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
                    (timeSlot.subject?.color.color ?? Color.blue).gradient
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(0)
    }
}

struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(for: [Subject.self])
            } else {
                WidgetsEntryView(entry: entry)
                    .padding()
                    .background()
                    .modelContainer(for: [Subject.self])
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemSmall) {
    Widgets()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
