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

    var body: some View {
        VStack(spacing: 20) {
            Text("Your Top 5 Messaged Contacts")
                .font(.title)
                .padding()

            ForEach(topContacts) { contact in
                HStack {
                    Text(contact.nameOrNumber)
                        .font(.headline)
                    Spacer()
                    Text("\(contact.messageCount) messages")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadTopContacts()
        }
    }

    private func loadTopContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let reader = ChatDBReader() {
                let raw = reader.getMostMessagedContacts(limit: 5)

                let enriched: [ContactMessageCount] = raw.map {
                    let name = lookupContactName(by: $0.sender)
                    return ContactMessageCount(nameOrNumber: name, messageCount: $0.count)
                }

                // ✅ Update UI on main thread
                DispatchQueue.main.async {
                    self.topContacts = enriched
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
