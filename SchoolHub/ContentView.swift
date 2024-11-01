//
//  ContentView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 12.10.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RootScreen()
            .environmentObject(Auth.shared)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Subject.self])
}

/*

 NavigationView {
 ScrollView {
 VStack(alignment: .leading, spacing: 16) {
 HStack(spacing: 4) {
 Image(systemName: "chart.bar.fill")
 .fontWeight(.medium)
 .foregroundStyle(Color(.blue))
 Text("Grades")
 .font(.system(size: 15, weight: .semibold))
 .foregroundStyle(Color(.blue))
 }
 HStack(alignment: .top) {
 VStack(spacing: 0) {
 Text("10")
 .font(.title2)
 .fontWeight(.bold)
 Text("overall average")
 .font(.system(size: 14))
 .foregroundStyle(.secondary)
 .multilineTextAlignment(.center)
 .lineSpacing(-10)
 }
 .frame(maxWidth: .infinity)
 Divider()
 VStack(spacing: 0) {
 Text("3")
 .font(.title2)
 .fontWeight(.bold)
 Text("this week")
 .font(.system(size: 14))
 .foregroundStyle(.secondary)
 .multilineTextAlignment(.center)
 .lineSpacing(-10)
 }
 .frame(maxWidth: .infinity)
 Divider()
 VStack(spacing: 0) {
 Text("12")
 .font(.title2)
 .fontWeight(.bold)
 Text("this month")
 .font(.system(size: 14))
 .foregroundStyle(.secondary)
 .multilineTextAlignment(.center)
 .lineSpacing(-10)
 }
 .frame(maxWidth: .infinity)
 }
 }
 .frame(maxWidth: .infinity, alignment: .leading)
 .padding()
 .background(Color(.secondarySystemGroupedBackground))
 .cornerRadius(10)
 VStack(alignment: .leading, spacing: 16) {
 HStack(spacing: 4) {
 Image(systemName: "calendar")
 .fontWeight(.medium)
 .foregroundStyle(Color(red: 1, green: 0.4, blue: 0))
 Text("Absences")
 .font(.system(size: 15, weight: .semibold))
 .foregroundStyle(Color(red: 1, green: 0.4, blue: 0))
 }
 HStack {
 VStack(spacing: 0) {
 Text("0")
 .font(.title2)
 .fontWeight(.bold)
 Text("this week")
 .font(.system(size: 14))
 .foregroundStyle(.secondary)
 .multilineTextAlignment(.center)
 .lineSpacing(-10)
 }
 .frame(maxWidth: .infinity)
 Divider()
 VStack(spacing: 0) {
 Text("4")
 .font(.title2)
 .fontWeight(.bold)
 Text("this month")
 .font(.system(size: 14))
 .foregroundStyle(.secondary)
 .multilineTextAlignment(.center)
 .lineSpacing(-10)
 }
 .frame(maxWidth: .infinity)
 Divider()
 VStack(spacing: 0) {
 Text("14")
 .font(.title2)
 .fontWeight(.bold)
 Text("this year")
 .font(.system(size: 14))
 .foregroundStyle(.secondary)
 .multilineTextAlignment(.center)
 .lineSpacing(-10)
 }
 .frame(maxWidth: .infinity)
 }
 }
 .frame(maxWidth: .infinity, alignment: .leading)
 .padding()
 .background(Color(.secondarySystemGroupedBackground))
 .cornerRadius(10)
 }
 .padding(Edge.Set.horizontal)
 .navigationTitle("Dashboard")
 .background(Color(.systemGroupedBackground))
 .refreshable {
 print("ceva")
 }
 }
 */
