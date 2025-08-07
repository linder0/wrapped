//
//  DailyMessageGraphView.swift
//  REDOINGWRAPPED
//
//  Created by Linda Xue on 8/7/25.
//

import SwiftUI
import Charts

struct DailyMessageGraphView: View {
    let dailyCounts: [MessageDayCount]

    var body: some View {
        let sortedCounts = dailyCounts.sorted { $0.date < $1.date }

        VStack(spacing: 16) {
            Text("📊 Daily Message Count")
                .font(.title2)
                .bold()
                .padding(.top)

            if sortedCounts.isEmpty {
                Text("No data available.")
                    .foregroundColor(.gray)
            } else {
                ScrollView(.horizontal) {
                    Chart(sortedCounts) { day in
                        BarMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Messages", day.count)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(width: CGFloat(sortedCounts.count) * 8, height: 240)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 30)) { value in
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}
