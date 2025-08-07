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

    var body: some View {
        VStack(spacing: 24) {
            Text("📤 Total Messages Sent")
                .font(.largeTitle)
                .padding(.top)

            Text("\(totalMessages)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.blue)

            Text("That’s ~\(totalMessages / 365) per day. We hope your thumbs are OK.")
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

            let dailyCounts = reader.getDailyMessageCounts()
            if let top = dailyCounts.first {
                mostActiveDay = top.date
                mostActiveCount = top.count
            }
        }
    }
}
