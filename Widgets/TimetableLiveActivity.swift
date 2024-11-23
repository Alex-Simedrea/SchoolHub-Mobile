//
//  TimetableLiveActivity.swift
//  WidgetsExtension
//
//  Created by Alexandru Simedrea on 12.11.2024.
//

import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

struct TimetableAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let currentTimeSlot: TimeSlot
        let nextTimeSlot: TimeSlot
    }
}

struct TimetableLiveActivityView: View {
    var currentTimeSlot: TimeSlot
    var nextTimeSlot: TimeSlot

    var body: some View {
        VStack {
            Text("Current: \(currentTimeSlot.subject?.name ?? "")")
            Text("Next: \(nextTimeSlot.subject?.name ?? "")")
        }
    }
}

@DynamicIslandExpandedContentBuilder
private func expandedContent(currentTimeSlot: TimeSlot, nextTimeSlot: TimeSlot) -> DynamicIslandExpandedContent<some View> {
    DynamicIslandExpandedRegion(.leading) {
        VStack {
            Image(
                systemName: currentTimeSlot.subject?.symbolName ?? "book"
            )
            .foregroundStyle(
                currentTimeSlot.subject?.color.color ?? .blue
            )
            Text(currentTimeSlot.subject?.name ?? "")
        }
    }

    DynamicIslandExpandedRegion(.bottom) {
        VStack {
            Image(
                systemName: nextTimeSlot.subject?.symbolName ?? "book"
            )
            .foregroundStyle(
                nextTimeSlot.subject?.color.color ?? .blue
            )
            Text(nextTimeSlot.subject?.name ?? "")
        }
    }
}

struct TimetableLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimetableAttributes.self) { context in
            TimetableLiveActivityView(
                currentTimeSlot: context.state.currentTimeSlot,
                nextTimeSlot: context.state.nextTimeSlot
            )
        } dynamicIsland: { context in
            DynamicIsland {
                expandedContent(
                    currentTimeSlot: context.state.currentTimeSlot,
                    nextTimeSlot: context.state.nextTimeSlot
                )
            } compactLeading: {
                Image(
                    systemName: context.state.currentTimeSlot.subject?.symbolName ?? "book"
                )
                .foregroundStyle(
                    context.state.currentTimeSlot.subject?.color.color ?? .blue
                )
            } compactTrailing: {
                Text("ceva")
            } minimal: {
                Image(
                    systemName: context.state.currentTimeSlot.subject?.symbolName ?? "book"
                )
                .foregroundStyle(
                    context.state.currentTimeSlot.subject?.color.color ?? .blue
                )
            }
            .contentMargins(.trailing, 8, for: .expanded)
        }
        .supplementalActivityFamilies([.small, .medium])
    }
}
