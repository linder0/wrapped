//
//  Slide1View.swift
//  REDOINGWRAPPED
//
//  Created by Linda Xue on 8/7/25.
//

import SwiftUI

struct Slide1View: View {
    @State private var totalMessages: Int = 0
    @State private var isLoading: Bool = true
    @State private var mostActiveDay: String = ""
    @State private var mostActiveCount: Int = 0
    @State private var dailyMessages: [(date: String, count: Int)] = []

    // Thresholds for messaging activity
    private let highActivityThreshold = 5000  // Messages per year
    private let lowActivityThreshold = 1000   // Messages per year

        var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Main heading
                Text("This year you talked...")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                // Conditional message based on activity
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        Text(getActivityMessage())
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(getActivityColor())
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.6), value: totalMessages)

                        Text(getSubMessage())
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .italic()
                    }
                }

                // Message count reveal
                if !isLoading {
                    VStack(spacing: 16) {
                        Text("In fact, you sent")
                            .font(.title)
                            .fontWeight(.medium)

                        Text("\(totalMessages)")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(.blue)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: totalMessages)

                        Text("texts from your phone")
                            .font(.title)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.1))
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // New "you sure can yap" section
                    VStack(spacing: 16) {
                        Text("you sure can yap,")
                            .font(.title)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)

                        if !mostActiveDay.isEmpty {
                            Text("your most active day was **\(formatDate(mostActiveDay))**, you sent **\(mostActiveCount)** messages!")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.orange.opacity(0.1))
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // Daily messages section
                    if !dailyMessages.isEmpty {
                        VStack(spacing: 16) {
                            Text("📅 All Your Messaging Days")
                                .font(.title2)
                                .bold()
                                .padding(.top)

                            Text("Here's how chatty you were each day:")
                                .foregroundColor(.secondary)

                            LazyVStack(spacing: 8) {
                                ForEach(Array(dailyMessages.prefix(20).enumerated()), id: \.element.date) { index, dayData in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(formatDate(dayData.date))
                                                .font(.headline)
                                                .foregroundColor(.primary)

                                            Text(getDayOfWeek(from: dayData.date))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("\(dayData.count)")
                                                .font(.title3)
                                                .bold()
                                                .foregroundColor(.blue)

                                            Text("messages")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        // Visual bar indicator
                                        Rectangle()
                                            .fill(Color.blue.opacity(0.6))
                                            .frame(width: CGFloat(dayData.count) / CGFloat(maxDailyCount) * 60, height: 4)
                                            .cornerRadius(2)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.05))
                                    )
                                }
                            }
                            .padding(.horizontal)

                            if dailyMessages.count > 20 {
                                Text("... and \(dailyMessages.count - 20) more days!")
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green.opacity(0.1))
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .padding()
        .onAppear {
            loadMessageCount()
        }
    }

        private var maxDailyCount: Int {
        dailyMessages.map { $0.count }.max() ?? 1
    }

    private func loadMessageCount() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let reader = ChatDBReader() {
                let count = reader.getTotalSentMessages()
                let dailyData = reader.getDailyMessageCounts()

                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.totalMessages = count
                        self.dailyMessages = dailyData

                        if let top = dailyData.first {
                            self.mostActiveDay = top.date
                            self.mostActiveCount = top.count
                        }

                        self.isLoading = false
                    }
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
        outputFormatter.dateFormat = "MM-dd-yyyy"

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

    private func getActivityMessage() -> String {
        if totalMessages >= highActivityThreshold {
            return "a lot."
        } else if totalMessages <= lowActivityThreshold {
            return "too little."
        } else {
            return "quite a bit."
        }
    }

    private func getSubMessage() -> String {
        if totalMessages >= highActivityThreshold {
            return "ur so popular! 🌟"
        } else if totalMessages <= lowActivityThreshold {
            return "do you have friends? 🤔"
        } else {
            return "not bad, not bad 👍"
        }
    }

    private func getActivityColor() -> Color {
        if totalMessages >= highActivityThreshold {
            return .green
        } else if totalMessages <= lowActivityThreshold {
            return .orange
        } else {
            return .blue
        }
    }
}

#Preview {
    Slide1View()
}
