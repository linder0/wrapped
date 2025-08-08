//
//  Slide3View.swift
//  REDOINGWRAPPED
//
//  Created by Linda Xue on 8/7/25.
//

import SwiftUI
import Contacts

struct Slide3View: View {
    @State private var isLoading: Bool = true
    @State private var totalMessages: Int = 0
    @State private var responseRate: Double = 0.0
    @State private var totalContacts: Int = 0
    @State private var mostActiveDay: String = ""
    @State private var mostActiveCount: Int = 0
    @State private var daysWithMessages: Int = 0
    @State private var averagePerDay: Double = 0.0
    @State private var topContacts: [(name: String, count: Int)] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("📱 Your Pally Wrapped")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    Text("2024 Messaging Summary")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                if isLoading {
                    ProgressView("Generating your summary...")
                        .padding()
                } else {
                    // Main Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {

                        // Total Messages
                        StatCard(
                            icon: "📤",
                            title: "Messages Sent",
                            value: "\(totalMessages)",
                            subtitle: getActivityLevel(),
                            color: .blue
                        )

                        // Contacts Messaged
                        StatCard(
                            icon: "👥",
                            title: "Contacts Messaged",
                            value: "\(totalContacts)",
                            subtitle: "different pals",
                            color: .green
                        )

                        // Response Rate
                        StatCard(
                            icon: "🎭",
                            title: "Response Rate",
                            value: "\(String(format: "%.1f", responseRate))%",
                            subtitle: getMysteriousLevel(),
                            color: .purple
                        )

                        // Average Per Day
                        StatCard(
                            icon: "📅",
                            title: "Daily Average",
                            value: String(format: "%.1f", averagePerDay),
                            subtitle: "per active day",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)

                    // Most Active Day Highlight
                    if !mostActiveDay.isEmpty {
                        VStack(spacing: 12) {
                            Text("🔥 Most Active Day")
                                .font(.title2)
                                .bold()

                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatDate(mostActiveDay))
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(getDayOfWeek(from: mostActiveDay))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(mostActiveCount)")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.red)

                                    Text("messages")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.red.opacity(0.1))
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }

                    // Top Contacts Section
                    if !topContacts.isEmpty {
                        VStack(spacing: 16) {
                            Text("🤝 Top Messaging Buddies")
                                .font(.title2)
                                .bold()

                            ForEach(Array(topContacts.prefix(3).enumerated()), id: \.element.name) { index, contact in
                                HStack {
                                    Text("\(getMedal(for: index))")
                                        .font(.title2)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(contact.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text("\(contact.count) messages")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    // Progress bar
                                    Rectangle()
                                        .fill(getContactColor(for: index))
                                        .frame(width: CGFloat(contact.count) / CGFloat(maxContactCount) * 60, height: 6)
                                        .cornerRadius(3)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.05))
                                )
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.yellow.opacity(0.1))
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }

                    // Fun Summary
                    VStack(spacing: 12) {
                        Text("✨ Your Messaging Personality")
                            .font(.title2)
                            .bold()

                        Text(getPersonalitySummary())
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                    .padding(.horizontal)

                    // Footer
                    VStack(spacing: 8) {
                        Text("Made with 💜 by Pally Wrapped")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Share your results with friends!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding(.top, 16)
                }

                Spacer(minLength: 40)
            }
        }
        .padding()
        .onAppear {
            loadAllStats()
        }
    }

    private var maxContactCount: Int {
        topContacts.map { $0.count }.max() ?? 1
    }

    private func loadAllStats() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let reader = ChatDBReader() {
                let messageCount = reader.getTotalSentMessages()
                let responseStats = reader.getResponseRateStats()
                let contactsCount = reader.getTotalUniqueContacts()
                let dailyData = reader.getDailyMessageCounts()
                let rawContacts = reader.getMostMessagedContacts(limit: 3)

                // Calculate averages
                let activeDays = dailyData.count
                let avgPerDay = activeDays > 0 ? Double(messageCount) / Double(activeDays) : 0.0

                // Get top contact names with proper lookup
                let contacts: [(name: String, count: Int)] = rawContacts.map {
                    let name = lookupContactName(by: $0.sender)
                    return (name: name, count: $0.count)
                }

                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.totalMessages = messageCount
                        self.responseRate = responseStats.responseRate
                        self.totalContacts = contactsCount
                        self.daysWithMessages = activeDays
                        self.averagePerDay = avgPerDay
                        self.topContacts = contacts

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

    private func getActivityLevel() -> String {
        if totalMessages >= 5000 {
            return "super chatty!"
        } else if totalMessages >= 1000 {
            return "pretty active"
        } else {
            return "selective texter"
        }
    }

    private func getMysteriousLevel() -> String {
        if responseRate >= 100 {
            return "very responsive"
        } else if responseRate >= 75 {
            return "pretty social"
        } else if responseRate >= 50 {
            return "balanced"
        } else {
            return "mysterious"
        }
    }

    private func getMedal(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "🏅"
        }
    }

    private func getContactColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .blue
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

    private func getPersonalitySummary() -> String {
        let chatLevel = getActivityLevel()
        let mysteryLevel = getMysteriousLevel()

        return "You're a \(chatLevel) texter who's \(mysteryLevel) when it comes to replying. You've connected with \(totalContacts) different people and had \(daysWithMessages) days of active conversations. Your messaging style is uniquely you!"
    }

    private func lookupContactName(by number: String) -> String {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        let target = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = number  // Use the phone number as fallback instead of "Unknown"

        try? store.enumerateContacts(with: request) { contact, stop in
            for phone in contact.phoneNumbers {
                let normalized = phone.value.stringValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                if normalized == target {
                    let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                    result = fullName.isEmpty ? number : fullName
                    stop.pointee = true
                    return
                }
            }
        }
        return result
    }
}

// Reusable Stat Card Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.largeTitle)

            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(color)

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    Slide3View()
}
