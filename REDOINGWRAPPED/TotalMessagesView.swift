//
//  TotalMessagesView.swift
//  REDOINGWRAPPED
//
//  Created by Linda Xue on 8/7/25.
//
import SwiftUI

struct MessageDayCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct TotalMessagesView: View {


    @State private var totalMessages: Int = 0
    @State private var mostActiveDay: String = "—"
    @State private var mostActiveCount: Int = 0
    @State private var dailyCounts: [(date: Date, count: Int)] = []
    @State private var daysWithMessages: Int = 0
    @State private var averageMessagesPerDay: Double = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Text("📤 Total Messages Sent")
                .font(.largeTitle)
                .padding(.top)

            Text("\(totalMessages)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.blue)

            Text("That's ~\(String(format: "%.1f", averageMessagesPerDay)) per active day across \(daysWithMessages) days with messages.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Divider()

            Text("📅 Most Active Day")
                .font(.title2)

            Text("\(mostActiveDay) — \(mostActiveCount) messages")
                .font(.headline)
                .foregroundColor(.purple)

            NavigationLink("View Full Chart") {
                let transformedCounts = dailyCounts.map { MessageDayCount(date: $0.date, count: $0.count) }
                DailyMessageGraphView(dailyCounts: transformedCounts)
            }

            .buttonStyle(.borderedProminent)
            .padding(.top)


            Spacer()
        }
        .padding()
        .onAppear {
            loadStats()
        }
    }

    private func loadStats() {
        if let reader = ChatDBReader() {
            totalMessages = reader.getTotalSentMessages()

            let dailyCountsData = reader.getDailyMessageCounts()
            daysWithMessages = dailyCountsData.count

            // Calculate average messages per active day
            if daysWithMessages > 0 {
                averageMessagesPerDay = Double(totalMessages) / Double(daysWithMessages)
            } else {
                averageMessagesPerDay = 0.0
            }

            if let top = dailyCountsData.first {
                mostActiveDay = top.date
                mostActiveCount = top.count
            }
        }
    }
}
