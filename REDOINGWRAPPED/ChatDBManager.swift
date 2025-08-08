import Foundation
import SQLite3

class ChatDBReader {
    var db: OpaquePointer?

    init?() {
        do {
            let home = FileManager.default.homeDirectoryForCurrentUser
            let original = home.appendingPathComponent("Library/Messages/chat.db")
            let temp = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("chat_copy.db")

            try? FileManager.default.removeItem(at: temp)
            try FileManager.default.copyItem(at: original, to: temp)

            if sqlite3_open(temp.path, &db) != SQLITE_OK {
                print("❌ Failed to open chat.db")
                return nil
            }
        } catch {
            print("❌ Error copying chat.db: \(error)")
            return nil
        }
    }

    deinit {
        sqlite3_close(db)
    }

    func fetchLastMessages(limit: Int = 100) {
        let query = """
        SELECT
            datetime(message.date / 1000000000 + strftime('%s','2001-01-01'), 'unixepoch') AS date,
            message.text,
            handle.id AS sender
        FROM message
        LEFT JOIN handle ON message.handle_id = handle.rowid
        ORDER BY message.date DESC
        LIMIT \(limit);
        """

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let dateCStr = sqlite3_column_text(stmt, 0)
                let textCStr = sqlite3_column_text(stmt, 1)
                let handleCStr = sqlite3_column_text(stmt, 2)

                let date = dateCStr != nil ? String(cString: dateCStr!) : "unknown"
                let text = textCStr != nil ? String(cString: textCStr!) : ""
                let handle = handleCStr != nil ? String(cString: handleCStr!) : "unknown"

                print("📩 \(date) | \(handle): \(text)")
            }
            sqlite3_finalize(stmt)
        } else {
            print("❌ SQL error: \(String(cString: sqlite3_errmsg(db)))")
        }
    }

    func getMostMessagedContacts(limit: Int = 10) -> [(sender: String, count: Int)] {
        let query = """
        SELECT handle.id, COUNT(message.rowid) as message_count
        FROM message
        LEFT JOIN handle ON message.handle_id = handle.rowid
        WHERE handle.id IS NOT NULL
        GROUP BY handle.id
        ORDER BY message_count DESC
        LIMIT \(limit);
        """

        var stmt: OpaquePointer?
        var results: [(String, Int)] = []

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let senderCStr = sqlite3_column_text(stmt, 0)
                let count = sqlite3_column_int(stmt, 1)

                let sender = senderCStr != nil ? String(cString: senderCStr!) : "Unknown"
                results.append((sender: sender, count: Int(count)))
            }
            sqlite3_finalize(stmt)
        } else {
            print("❌ SQL error: \(String(cString: sqlite3_errmsg(db)))")
        }

        return results
    }
    func getTotalSentMessages() -> Int {
        let query = """
        SELECT COUNT(*) FROM message
        WHERE is_from_me = 1;
        """

        var stmt: OpaquePointer?
        var count = 0

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
            sqlite3_finalize(stmt)
        } else {
            print("❌ SQL error: \(String(cString: sqlite3_errmsg(db)))")
        }

        return count
    }
        func getTotalUniqueContacts() -> Int {
        let query = """
        SELECT COUNT(DISTINCT handle.id) as unique_contacts
        FROM message
        LEFT JOIN handle ON message.handle_id = handle.rowid
        WHERE handle.id IS NOT NULL;
        """

        var stmt: OpaquePointer?
        var count = 0

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
            sqlite3_finalize(stmt)
        } else {
            print("❌ SQL error: \(String(cString: sqlite3_errmsg(db)))")
        }

        return count
    }

    func getTotalReceivedMessages() -> Int {
        let query = """
        SELECT COUNT(*) FROM message
        WHERE is_from_me = 0;
        """

        var stmt: OpaquePointer?
        var count = 0

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
            sqlite3_finalize(stmt)
        } else {
            print("❌ SQL error: \(String(cString: sqlite3_errmsg(db)))")
        }

        return count
    }

    func getResponseRateStats() -> (receivedCount: Int, sentCount: Int, responseRate: Double) {
        let receivedCount = getTotalReceivedMessages()
        let sentCount = getTotalSentMessages()

        let responseRate = receivedCount > 0 ? (Double(sentCount) / Double(receivedCount)) * 100.0 : 0.0

        return (receivedCount: receivedCount, sentCount: sentCount, responseRate: responseRate)
    }

    func getDailyMessageCounts() -> [(date: String, count: Int)] {
        let query = """
        SELECT
            date(datetime(date / 1000000000 + strftime('%s','2001-01-01'), 'unixepoch')) AS day,
            COUNT(*) as count
        FROM message
        WHERE is_from_me = 1
        GROUP BY day
        ORDER BY count DESC;
        """

        var stmt: OpaquePointer?
        var results: [(String, Int)] = []

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let dateCStr = sqlite3_column_text(stmt, 0)
                let count = sqlite3_column_int(stmt, 1)

                if let dateCStr = dateCStr {
                    let date = String(cString: dateCStr)
                    results.append((date, Int(count)))
                }
            }
            sqlite3_finalize(stmt)
        } else {
            print("❌ SQL error: \(String(cString: sqlite3_errmsg(db)))")
        }

        return results
    }
    private func getDBPath() -> String? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = documentsDirectory.appendingPathComponent("chat_copy.db").path
        return dbPath
    }
    // COMMENTED OUT: Emoji functionality
    /*
    func getTopUsedEmojis(limit: Int = 5) -> [(emoji: String, count: Int)] {
            guard let dbPath = getDBPath() else {
                print("❌ No database path")
                return []
            }

            var db: OpaquePointer?
            guard sqlite3_open(dbPath, &db) == SQLITE_OK else {
                print("❌ Failed to open database")
                return []
            }
            defer { sqlite3_close(db) }

            let query = """
                SELECT text FROM message WHERE text IS NOT NULL;
            """
            var statement: OpaquePointer?
            var emojiCount: [String: Int] = [:]

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let cString = sqlite3_column_text(statement, 0) {
                        let message = String(cString: cString)
                        for char in message {
                            if char.isEmoji {
                                let emoji = String(char)
                                emojiCount[emoji, default: 0] += 1
                            }
                        }
                    }
                }
                sqlite3_finalize(statement)
            }

            let sorted = emojiCount.sorted { $0.value > $1.value }
            return Array(sorted.prefix(limit).map { (emoji: $0.key, count: $0.value) })
        }
    */
    }
