//
//  SubjectCard.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 31.10.2024.
//

import SwiftUI

struct SubjectCard: View {
    @State var subject: Subject
    let onHide: () -> Void

    @State private var height: CGFloat = UIFont.preferredFont(forTextStyle: .body).lineHeight * 2

    @State private var isShowingSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: subject.symbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                    .foregroundStyle(.white)

                Spacer()
                Menu {
                    Button(action: {
                        isShowingSheet = true
                    }) {
                        Label("Edit subject", systemImage: "pencil")
                    }
                    if !subject.hidden {
                        Button(role: .destructive, action: {
                            onHide()
                        }) {
                            Label("Hide subject", systemImage: "eye.slash")
                        }
                    }
                    if subject.hidden {
                        Button(action: {
                            onHide()
                        }) {
                            Label("Unhide subject", systemImage: "eye")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .fontWeight(.semibold)
                        .padding(6)
                        .foregroundStyle(.white)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            Spacer()
            Text(subject.displayName)
                .foregroundStyle(.white)
                .font(.body.bold())
                .lineSpacing(-2)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: height, alignment: .bottom)

            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "chart.bar.xaxis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
                    //                        .foregroundStyle(.white)
                    Text("\(subject.grades.average, format: .number)")
                        //                        .foregroundStyle(.white)
                        .font(.caption.bold())
                }
                .foregroundStyle(.white.opacity(0.8))
                HStack(spacing: 3) {
                    Image(systemName: "number")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
                    //                        .foregroundStyle(.white)
                    Text("\(subject.grades.count)")
                        //                        .foregroundStyle(.white)
                        .font(.caption.bold())
                }
                .foregroundStyle(.white.opacity(0.8))
                HStack(spacing: 3) {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
                    //                        .foregroundStyle(.white)
                    Text("\(subject.absences.count)")
                        //                        .foregroundStyle(.white)
                        .font(.caption.bold())
                }
                .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(subject.color.color.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contextMenu {
            Button(action: {
                isShowingSheet = true
            }) {
                Label("Edit subject", systemImage: "pencil")
            }
            if !subject.hidden {
                Button(role: .destructive, action: {
                    onHide()
                }) {
                    Label("Hide subject", systemImage: "eye.slash")
                }
            }
            if subject.hidden {
                Button(action: {
                    onHide()
                }) {
                    Label("Unhide subject", systemImage: "eye")
                }
            }
        } preview: {
            SubjectPreview(subject: subject)
        }
        .sheet(isPresented: $isShowingSheet) {
            SubjectEditScreen(subject: subject)
        }
    }
}

// #Preview {
//    SubjectCard()
// }
