//
//  TimetableScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 01.11.2024.
//

import SwiftData
import SwiftUI

struct TimetableScreen: View {
    @Query private var timeSlots: [TimeSlot]
    @Environment(\.modelContext) private var context
    @State private var index = 0
    @Namespace private var namespace
    @State private var viewWidth: CGFloat = 0
    @State private var viewHeight: CGFloat = 0

    private var currentWeekday: Weekday {
        Weekday.weekdays[index]
    }

    func maxTimeSlotsInADay() -> Int {
        let timeSlotsByWeekday = Dictionary(grouping: timeSlots, by: \.weekday)
        return timeSlotsByWeekday.values.map(\.count).max() ?? 0

//        let ceva = []
//        ceva.max()
    }

    var remainingTimeSlotsUntilMax: Int {
        maxTimeSlotsInADay() - timeSlots.filter { $0.weekday == .monday }.count
    }

    var body: some View {
//        ScrollView(.vertical) {
//        GeometryReader { _ in
        NavigationStack {
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
                            Spacer(minLength: 0) // Add spacer between buttons, but not after the last one
                        }
                        //                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .animation(.smooth(duration: 0.3), value: index)
                .frame(maxWidth: .infinity)
                //            ScrollView {
//                    GeometryReader {
//                        let size = $0.size
                //                    let _  = print("geo size \(size.width)")

                LoopingScrollView(
                    width: viewWidth,
                    spacing: 0,
                    items: Weekday.weekdays,
                    currentIndex: $index
                ) { weekday in
//                            ScrollView {
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
//                            }
                }

//                        .frame(height: viewHeight == 0 ? 100 : viewHeight)
                .scrollTargetBehavior(.paging)

//                        Color.clear
//                            .onAppear {
//                                viewWidth = size.width
//                            }
//                            .onChange(of: size.width) {
//                                viewWidth = size.width
//                            }
//                    }
//                    .frame(height: viewHeight)
            }

            //                Text("current index: \(index)")
            //            }
            //            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Timetable")
        }
//            Color.clear
//                .onAppear {
//                    viewHeight = geo.size.height
//                }
//        }
    }
}

#Preview {
    TimetableScreen()
}
