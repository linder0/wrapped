//
//  TopWordsView.swift
//  REDOINGWRAPPED
//
//  Created by Linda Xue on 8/7/25.
//

import SwiftUI

struct TopWordsView: View {
    @State private var topWords: [(word: String, count: Int)] = []

    var body: some View {
        ScrollView { // ✅ allows scrolling and prevents overflow blocking
            VStack(spacing: 24) {
                Text("✍️ Most Used Words")
                    .font(.largeTitle)
                    .bold()

                if topWords.isEmpty {
                    Text("No word data found.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(Array(topWords.enumerated()), id: \.element.word) { index, item in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.headline)
                                .frame(width: 40, alignment: .trailing)

                            Text(item.word)
                                .font(.system(size: 22))
                                .bold()

                            Spacer()

                            Text("\(item.count) uses")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }

                Button("Get Top Words") {
                    if let reader = ChatDBReader() {
                        topWords = reader.getTopUsedWords()
                    }
                }
                .buttonStyle(.borderedProminent)

                Spacer(minLength: 40) // ✅ give room at the bottom
            }
            .padding()
        }
        .navigationTitle("Top Words") // ✅ shows back button
    }
}
