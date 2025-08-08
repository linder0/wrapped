//
//  MessagesPerDayView.swift
//  REDOINGWRAPPED
//
//  Created by Linda Xue on 8/7/25.
//

import SwiftUI

struct MessagesPerDayView: View {
    @State private var dailyMessages: [(date: String, count: Int)] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("📅 Messages Per Day")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                if isLoading {
                    ProgressView("Loading daily message data...")
                        .padding()
                } else if dailyMessages.isEmpty {
                    Text("No message data found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Text("Total days with messages: \(dailyMessages.count)")
                        .foregroundColor(.secondary)
                        .padding(.bottom)

                    LazyVStack(spacing: 8) {
                        ForEach(Array(dailyMessages.enumerated()), id: \.element.date) { index, dayData in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatDate(dayData.date))
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(getDayOfWeek(from: dayData.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(dayData.count)")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.blue)

                                    Text("messages")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                // Visual bar indicator
                                Rectangle()
                                    .fill(Color.blue.opacity(0.6))
                                    .frame(width: CGFloat(dayData.count) / CGFloat(maxMessageCount) * 100, height: 4)
                                    .cornerRadius(2)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Messages Per Day")
        .onAppear {
            loadDailyMessages()
        }
    }

    private var maxMessageCount: Int {
        dailyMessages.map { $0.count }.max() ?? 1
    }

    private func loadDailyMessages() {
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            if let reader = ChatDBReader() {
                let results = reader.getDailyMessageCounts()

                DispatchQueue.main.async {
                    self.dailyMessages = results
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }

    private func getDayOfWeek(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = formatter.date(from: dateString) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: date)
        }
        return ""
    }
}

#Preview {
    NavigationView {
        MessagesPerDayView()
    }
}
