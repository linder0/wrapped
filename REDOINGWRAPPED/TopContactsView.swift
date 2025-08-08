//
//  TopContactsView.swift
//  REDOINGWRAPPED
//
//  Created by Linda Xue on 8/7/25.
//
import SwiftUI
import Contacts
import Foundation

struct ContactMessageCount: Identifiable {
    let id = UUID()
    let nameOrNumber: String
    let messageCount: Int
}
struct TopContactsView: View {
    @State private var topContacts: [ContactMessageCount] = []
    @State private var totalUniqueContacts: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("🤝 Social Superconnector")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                Text("You were truly a superconnector - messaging **\(totalUniqueContacts)** different pals")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Of those, a few stood out the most:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top)

                VStack(spacing: 16) {
                    ForEach(Array(topContacts.enumerated()), id: \.element.id) { index, contact in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(width: 30, alignment: .trailing)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.nameOrNumber)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("\(contact.messageCount) messages")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Visual bar indicator
                            Rectangle()
                                .fill(Color.blue.opacity(0.6))
                                .frame(width: CGFloat(contact.messageCount) / CGFloat(maxMessageCount) * 80, height: 6)
                                .cornerRadius(3)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .padding()
        .onAppear {
            loadTopContacts()
        }
    }

    private var maxMessageCount: Int {
        topContacts.map { $0.messageCount }.max() ?? 1
    }

    private func loadTopContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let reader = ChatDBReader() {
                let raw = reader.getMostMessagedContacts(limit: 5)
                let uniqueContactsCount = reader.getTotalUniqueContacts()

                let enriched: [ContactMessageCount] = raw.map {
                    let name = lookupContactName(by: $0.sender)
                    return ContactMessageCount(nameOrNumber: name, messageCount: $0.count)
                }

                // ✅ Update UI on main thread
                DispatchQueue.main.async {
                    self.topContacts = enriched
                    self.totalUniqueContacts = uniqueContactsCount
                }
            }
        }
    }


    private func lookupContactName(by number: String) -> String {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        let target = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = "Unknown"

        try? store.enumerateContacts(with: request) { contact, stop in
            for phone in contact.phoneNumbers {
                let normalized = phone.value.stringValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                if normalized == target {
                    result = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                    stop.pointee = true
                    return
                }
            }
        }
        return result
    }
}
