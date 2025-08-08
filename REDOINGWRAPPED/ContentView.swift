import SwiftUI
import Contacts

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Pally Wrapped")
                        .font(.largeTitle)
                        .padding(.top)

                    NavigationLink("Slide 1 - Messaging Activity", destination: Slide1View())
                    NavigationLink("Slide 2 - Mysterious Response Rate", destination: Slide2View())
                    NavigationLink("Slide 3 - Your Wrapped Summary ✨", destination: Slide3View())
//                    NavigationLink("Social Superconnector", destination: TopContactsView())
//                    NavigationLink("Total Messages Sent", destination: TotalMessagesView())
//                    NavigationLink("Messages Per Day", destination: MessagesPerDayView())

                    // Add more stat views here
                }
                .padding()
            }
            .navigationTitle("Pally Wrapped")
        }
    }
}



//OLD TOP CONTACTS
//import SwiftUI
//import Contacts
//
//struct ContactMessageCount: Identifiable {
//    let id = UUID()
//    let nameOrNumber: String
//    let messageCount: Int
//}
//
//struct ContentView: View {
//    @State private var topContacts: [ContactMessageCount] = []
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Your Top 5 Messaged Contacts")
//                .font(.title)
//                .padding()
//
//            ForEach(topContacts) { contact in
//                HStack {
//                    Text(contact.nameOrNumber)
//                        .font(.headline)
//                    Spacer()
//                    Text("\(contact.messageCount) messages")
//                        .foregroundColor(.gray)
//                }
//                .padding(.horizontal)
//            }
//
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            requestContactsAccessIfNeeded()
//
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let reader = ChatDBReader() {
//                    let topRaw = reader.getMostMessagedContacts(limit: 5)
//
//                    var results: [ContactMessageCount] = []
//
//                    for (sender, count) in topRaw {
//                        let name = lookupContactName(by: sender)
//                        results.append(ContactMessageCount(nameOrNumber: name, messageCount: count))
//                    }
//
//                    DispatchQueue.main.async {
//                        topContacts = results
//                    }
//                } else {
//                    print("❌ Could not open chat.db")
//                }
//            }
//        }
//    }
//
//    // MARK: - Permissions
//    func requestContactsAccessIfNeeded() {
//        let store = CNContactStore()
//        store.requestAccess(for: .contacts) { granted, error in
//            if granted {
//                print("✅ Contacts access granted.")
//            } else {
//                print("❌ Contacts access denied: \(String(describing: error))")
//            }
//        }
//    }
//
//    // MARK: - Contact Lookup
//    func lookupContactName(by phoneNumber: String) -> String {
//        let store = CNContactStore()
//        let keys = [
//            CNContactGivenNameKey,
//            CNContactFamilyNameKey,
//            CNContactPhoneNumbersKey
//        ] as [CNKeyDescriptor]
//
//        let request = CNContactFetchRequest(keysToFetch: keys)
//        let target = normalize(phoneNumber: phoneNumber)
//
//        var match: CNContact? = nil
//
//        do {
//            try store.enumerateContacts(with: request) { contact, stop in
//                for number in contact.phoneNumbers {
//                    let normalized = normalize(phoneNumber: number.value.stringValue)
//                    if normalized == target {
//                        match = contact
//                        stop.pointee = true
//                        return
//                    }
//                }
//            }
//        } catch {
//            print("❌ Contact fetch error: \(error)")
//        }
//
//        if let c = match {
//            let fullName = "\(c.givenName) \(c.familyName)".trimmingCharacters(in: .whitespaces)
//            return fullName.isEmpty ? phoneNumber : fullName
//        } else {
//            return phoneNumber
//        }
//    }
//
//    func normalize(phoneNumber: String) -> String {
//        return phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
//    }
//}

//
//
////CONFIRMING CONTACT LINKAGE SHIT:
//import SwiftUI
//import Contacts
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("Contact Lookup")
//                .font(.title)
//                .padding()
//
//            Button("Lookup Number") {
//                Task {
//                    let number = "+1 (415) 555-3695"  // Replace with test number
//                    if let contact = lookupContact(by: number) {
//                        print("✅ Found: \(contact.givenName) \(contact.familyName)")
//
//                        if let imageData = contact.imageData,
//                           let image = NSImage(data: imageData) {
//                            print("🖼️ Contact has image (size: \(image.size))")
//                        } else {
//                            print("ℹ️ No image for this contact.")
//                        }
//                    } else {
//                        print("❌ No contact found for number: \(number)")
//                    }
//                }
//            }
//            .padding()
//        }
//        .onAppear {
//            requestContactsAccessIfNeeded()
//
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let reader = ChatDBReader() {
//                    reader.fetchLastMessages()
//
//                    let top = reader.getMostMessagedContacts()
//                    print("🥇 Top Messaged Contacts:")
//                    for (sender, count) in top {
//                        let name = lookupContact(by: sender)?.givenName ?? "Unknown"
//                        print("📱 \(name): \(count) messages")
//                    }
//                } else {
//                    print("❌ Could not open chat.db")
//                }
//            }
//        }
//    }
//
//    // MARK: - Request Permissions
//    func requestContactsAccessIfNeeded() {
//        let store = CNContactStore()
//        store.requestAccess(for: .contacts) { granted, error in
//            if granted {
//                print("✅ Contacts access granted.")
//            } else {
//                print("❌ Contacts access denied: \(String(describing: error))")
//            }
//        }
//    }
//
//    // MARK: - Lookup Contact
//    func lookupContact(by phoneNumber: String) -> CNContact? {
//        let store = CNContactStore()
//        let keys = [
//            CNContactGivenNameKey,
//            CNContactFamilyNameKey,
//            CNContactPhoneNumbersKey,
//            CNContactImageDataKey
//        ] as [CNKeyDescriptor]
//
//        let request = CNContactFetchRequest(keysToFetch: keys)
//        let target = normalize(phoneNumber: phoneNumber)
//
//        var match: CNContact? = nil
//
//        do {
//            try store.enumerateContacts(with: request) { contact, stop in
//                for number in contact.phoneNumbers {
//                    let normalized = normalize(phoneNumber: number.value.stringValue)
//                    if normalized == target {
//                        match = contact
//                        stop.pointee = true
//                        return
//                    }
//                }
//            }
//        } catch {
//            print("❌ Contact fetch error: \(error)")
//        }
//
//        return match
//    }
//
//    func normalize(phoneNumber: String) -> String {
//        return phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
//    }
//}
//
//#Preview {
//    ContentView()
//}
