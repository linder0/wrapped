//
//  Slide2View.swift
//  REDOINGWRAPPED
//
//  Created by Linda Xue on 8/7/25.
//

import SwiftUI

struct Slide2View: View {
    @State private var isLoading: Bool = true
    @State private var receivedMessages: Int = 0
    @State private var sentMessages: Int = 0
    @State private var responseRate: Double = 0.0

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Main mysterious heading
                Text("you sure are mysterious,")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                } else {
                    // Response rate reveal
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Text("of the messages received by you,")
                                .font(.title2)
                                .multilineTextAlignment(.center)

                            Text("you only responded to")
                                .font(.title2)
                                .multilineTextAlignment(.center)

                            Text("\(String(format: "%.1f", responseRate))%")
                                .font(.system(size: 80, weight: .black, design: .rounded))
                                .foregroundColor(.purple)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: responseRate)

                            Text("of them.")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.purple.opacity(0.1))
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)


                        // Stats breakdown
                        VStack(spacing: 16) {
                            Text("📊 The Numbers")
                                .font(.title2)
                                .bold()

                            HStack(spacing: 32) {
                                VStack(spacing: 8) {
                                    Text("\(receivedMessages)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.blue)

                                    Text("messages\nreceived")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                }

                                VStack(spacing: 8) {
                                    Text("→")
                                        .font(.system(size: 24, weight: .light))
                                        .foregroundColor(.gray)
                                }

                                VStack(spacing: 8) {
                                    Text("\(sentMessages)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.green)

                                    Text("messages\nsent")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Text(getResponseDescription())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.1))
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .padding()
        .onAppear {
            loadResponseStats()
        }
    }

    private func loadResponseStats() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let reader = ChatDBReader() {
                let stats = reader.getResponseRateStats()

                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.receivedMessages = stats.receivedCount
                        self.sentMessages = stats.sentCount
                        self.responseRate = stats.responseRate
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



    private func getResponseDescription() -> String {
        if responseRate >= 150 {
            return "You respond more than once for every message you receive - a true conversation enthusiast!"
        } else if responseRate >= 100 {
            return "You respond to most messages you receive - great at keeping conversations going!"
        } else if responseRate >= 75 {
            return "You respond to most messages - pretty social!"
        } else if responseRate >= 50 {
            return "You're selective about your responses - quality over quantity!"
        } else if responseRate >= 25 {
            return "You choose your words carefully - the mysterious type!"
        } else {
            return "You're very selective with responses - truly enigmatic!"
        }
    }
}

#Preview {
    Slide2View()
}
