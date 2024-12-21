//
//  TimetableLiveActivity.swift
//  WidgetsExtension
//
//  Created by Alexandru Simedrea on 12.11.2024.
//

#if !targetEnvironment(macCatalyst)
import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

struct TimetableAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let displayName: String
        let color: String
        let symbolName: String
        let startTime: String?
        let endTime: String?

        let nextTimeSlot: NextTimeSlot?

        struct NextTimeSlot: Codable, Hashable {
            let displayName: String
            let color: String
            let symbolName: String
        }
    }
}

struct TimetableLiveActivityView: View {
    let context: ActivityViewContext<TimetableAttributes>

    var currentColor: Color { SubjectColor(rawValue: context.state.color)?.color ?? .blue }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Current class info
                HStack {
                    Image(systemName: context.state.symbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 24)
                        .foregroundStyle(.white)

//                        .foregroundColor(
//                            SubjectColor(rawValue: context.state.color)?.color ?? .blue
//                        )

                    Text(context.state.displayName)
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Spacer()

                    if context.state.startTime == nil {
                        if let endTime = context.state.endTime,
                           let endDate = ISO8601DateFormatter().date(
                               from: endTime
                           )
                        {
                            let uiFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .bold)
                            let fontAttributes = [NSAttributedString.Key.font: uiFont]
                            let time = endDate.timeIntervalSinceNow
                            let maxString = Self.maxStringFor(time)
                            let width = (maxString as NSString).size(withAttributes: fontAttributes).width

                            Text(endDate, style: .timer)
                                .font(.callout.bold())
                                .frame(width: width + 10)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .foregroundColor(.white)
                                }
                                .multilineTextAlignment(.center)
                                .foregroundStyle(currentColor)
                        }
                    } else if let startTime = context.state.startTime,
                              let startDate = ISO8601DateFormatter().date(
                                  from: startTime
                              ) {
                        Text("Next up - \(startDate, style: .timer)")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.trailing)
                            .opacity(0.8)
                    }
                }

                if let next = context.state.nextTimeSlot {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: next.symbolName)
                                .foregroundStyle(.white)

                            Text("\(next.displayName)")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Text("Next up")
                            .font(.callout)
                            .foregroundStyle(.white)
                    }
                    .bold()
                    .opacity(0.8)
                }
            }
            Spacer()
        }
        .padding()
        .padding(.vertical, context.state.nextTimeSlot == nil ? 8 : 0)
        .background(currentColor.gradient)
    }

    static func maxStringFor(_ time: TimeInterval) -> String {
        if time < 600 { // 9:99
            return "0:00"
        }

        if time < 3600 { // 59:59
            return "00:00"
        }

        if time < 36000 { // 9:59:59
            return "0:00:00"
        }

        return "00:00:00" // 99:59:59
    }
}

struct TimetableLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimetableAttributes.self) { context in
            var currentColor: Color { SubjectColor(rawValue: context.state.color)?.color ?? .blue }
            TimetableLiveActivityView(context: context)
                .background(currentColor.gradient)
        } dynamicIsland: { context in
            var currentColor: Color { SubjectColor(rawValue: context.state.color)?.color ?? .blue }

            return DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image(systemName: context.state.symbolName)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 45,
//                                height: 40,
                                alignment: .bottomLeading
                            )
                            .frame(maxHeight: 25, alignment: .bottomLeading)
                            .foregroundStyle(currentColor)
                            .padding(.top, 4)
                        //                        Text(context.state.displayName)
                        //                            .font(.headline)
                    }
                    .padding(.leading, 8)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.startTime == nil {
                        Text("Time left")
                            .font(.callout.bold())
                            .frame(height: 30, alignment: .bottomTrailing)
                            .padding(.trailing, 8)
                            .opacity(0.8)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        HStack(alignment: .top) {
                            Text(context.state.displayName)
                                .font(.title3.bold())

                            Spacer()

                            if context.state.startTime == nil {
                                if let endTime = context.state.endTime,
                                   let endDate = ISO8601DateFormatter().date(
                                       from: endTime
                                   )
                                {
                                    Text(endDate, style: .timer)
                                        .font(.headline)
                                        .multilineTextAlignment(.trailing)
                                }
                            } else if let startTime = context.state.startTime,
                                      let startDate = ISO8601DateFormatter().date(
                                        from: startTime
                                      ) {
                                Text("Next up - \(startDate, style: .timer)")
                                    .font(.headline)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        if let next = context.state.nextTimeSlot {
                            var nextColor: Color { SubjectColor(rawValue: next.color)?.color ?? .blue }

                            HStack {
                                Image(systemName: next.symbolName)
                                    .foregroundStyle(nextColor)
                                Text("\(next.displayName)")
                                    .font(.headline)
                                Spacer()
                                Text("Next up")
                                    .font(.callout)
                                    .opacity(0.8)
                            }
                            .padding(.top, 4)
                        }
//                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                // Compact leading UI
                Image(systemName: context.state.symbolName)
                    .foregroundStyle(currentColor)
                    .padding(.leading, 4)
            } compactTrailing: {
                // Compact trailing UI
                if let endTime = context.state.endTime,
                   let endDate = ISO8601DateFormatter().date(
                       from: endTime
                   )
                {
                    let uiFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .bold)
                    let fontAttributes = [NSAttributedString.Key.font: uiFont]
                    let time = endDate.timeIntervalSinceNow
                    let maxString = TimetableLiveActivityView.maxStringFor(time)
                    let width = (maxString as NSString).size(withAttributes: fontAttributes).width

                    Text(endDate, style: .timer)
                        .font(.callout.bold())
                        .frame(width: width)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 4)
                } else if let startTime = context.state.startTime,
                          let startDate = ISO8601DateFormatter().date(
                            from: startTime
                          ) {
                    let uiFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .bold)
                    let fontAttributes = [NSAttributedString.Key.font: uiFont]
                    let time = startDate.timeIntervalSinceNow
                    let maxString = TimetableLiveActivityView.maxStringFor(time)
                    let width = (maxString as NSString).size(withAttributes: fontAttributes).width
                    
                    Text(startDate, style: .timer)
                        .font(.callout.bold())
                        .frame(width: width)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 4)
                }
            } minimal: {
                // Minimal UI
                Image(systemName: context.state.symbolName)
                    .foregroundStyle(currentColor)
            }
        }
//        .contentMargins(.all, 0)
        .supplementalActivityFamilies([.small, .medium])
    }
}

#endif

#Preview("Live Activity", as: .content, using: TimetableAttributes()) {
    TimetableLiveActivity()
} contentStates: {
    TimetableAttributes.ContentState(
        displayName: "Mathematics",
        color: "red",
        symbolName: "function",
        startTime: "2024-12-20T11:00:00Z",
        endTime: nil,
        nextTimeSlot: nil
//        nextTimeSlot: TimetableAttributes.ContentState.NextTimeSlot(
//            displayName: "Physics",
//            color: "red",
//            symbolName: "atom"
//        )
    )
}

#Preview(
    "Live Activity",
    as: .dynamicIsland(.expanded),
    using: TimetableAttributes()
) {
    TimetableLiveActivity()
} contentStates: {
    TimetableAttributes.ContentState(
        displayName: "Mathematics",
        color: "red",
        symbolName: "function",
        startTime: nil,
        endTime: "2024-12-20T11:00:00Z",
        nextTimeSlot: TimetableAttributes.ContentState.NextTimeSlot(
            displayName: "Physics",
            color: "red",
            symbolName: "atom"
        )
    )
}

#Preview(
    "Live Activity",
    as: .dynamicIsland(.compact),
    using: TimetableAttributes()
) {
    TimetableLiveActivity()
} contentStates: {
    TimetableAttributes.ContentState(
        displayName: "Mathematics",
        color: "red",
        symbolName: "function",
        startTime: nil,
        endTime: "2024-12-20T11:00:00Z",
        nextTimeSlot: TimetableAttributes.ContentState.NextTimeSlot(
            displayName: "Physics",
            color: "red",
            symbolName: "atom"
        )
    )
}
