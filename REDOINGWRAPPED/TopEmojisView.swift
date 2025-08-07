////
////  TopEmojisView.swift
////  REDOINGWRAPPED
////
////  Created by Linda Xue on 8/7/25.
////
//
//import SwiftUI
//
//struct TopEmojisView: View {
//    @State private var topEmojis: [(emoji: String, count: Int)] = []
//
//    var body: some View {
//        VStack(spacing: 24) {
//            Text("🥇 Most Used Emojis")
//                .font(.largeTitle)
//                .bold()
//
//            if topEmojis.isEmpty {
//                Text("No emoji data found.")
//                    .foregroundColor(.gray)
//            } else {
//                ForEach(Array(topEmojis.enumerated()), id: \.element.emoji) { index, item in
//                    HStack {
//                        Text("#\(index + 1)")
//                            .font(.headline)
//                            .frame(width: 40, alignment: .trailing)
//
//                        Text(item.emoji)
//                            .font(.system(size: 40))
//
//                        Spacer()
//
//                        Text("\(item.count) uses")
//                            .foregroundColor(.secondary)
//                    }
//                    .padding(.horizontal)
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            if let reader = ChatDBReader() {
//                topEmojis = reader.getTopUsedEmojis()
//            }
//        }
//    }
//}
