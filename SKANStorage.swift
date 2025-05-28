//
//  SKANStorage.swift
//
//
//  Created by Satyam Jha on 26/03/25.
//

final class SKANStorage {
    static let shared = SKANStorage()
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("com.trackier.skan")
    }
    
    init() {
        decoder.dateDecodingStrategy = .iso8601 // Add this to handle dates correctly
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            Logger.error(message: "Failed to create SKAN cache directory: \(error.localizedDescription)")
        }
    }
    
    func saveConfig(_ config: SKANConfig, aid: String) {
        let fileURL = cacheDirectory.appendingPathComponent("config_\(aid).json")
        do {
            let data = try encoder.encode(config)
            try data.write(to: fileURL, options: [.atomic])
            Logger.debug(message: "Saved SKAN config for aid: \(aid)")
        } catch {
            Logger.error(message: "Failed to save SKAN config: \(error.localizedDescription)")
        }
    }
    
    func loadConfig(aid: String) -> SKANConfig? {
        let fileURL = cacheDirectory.appendingPathComponent("config_\(aid).json")
        guard let data = try? Data(contentsOf: fileURL) else {
            Logger.debug(message: "No cached SKAN config found for aid: \(aid)")
            return nil
        }
        do {
            let config = try decoder.decode(SKANConfig.self, from: data)
            Logger.debug(message: "Loaded cached SKAN config for aid: \(aid)")
            return config
        } catch {
            Logger.error(message: "Failed to decode SKAN config: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearConfig(aid: String) {
        let fileURL = cacheDirectory.appendingPathComponent("config_\(aid).json")
        do {
            try fileManager.removeItem(at: fileURL)
            Logger.debug(message: "Cleared SKAN config for aid: \(aid)")
        } catch {
            Logger.debug(message: "No SKAN config to clear for aid: \(aid)")
        }
    }
    
    func saveLastUpdateTimestamp(_ timestamp: Date, aid: String) {
        let fileURL = cacheDirectory.appendingPathComponent("last_update_\(aid).plist")
        do {
            let timestampValue = timestamp.timeIntervalSince1970
            let data = try PropertyListSerialization.data(fromPropertyList: timestampValue, format: .binary, options: 0)
            try data.write(to: fileURL, options: [.atomic])
            Logger.debug(message: "Saved last update timestamp for aid: \(aid)")
        } catch {
            Logger.error(message: "Failed to save last update timestamp: \(error.localizedDescription)")
        }
    }
    
    func loadLastUpdateTimestamp(aid: String) -> Date? {
        let fileURL = cacheDirectory.appendingPathComponent("last_update_\(aid).plist")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        do {
            let timestampValue = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            if let interval = timestampValue as? TimeInterval {
                return Date(timeIntervalSince1970: interval)
            }
            return nil
        } catch {
            Logger.error(message: "Failed to load last update timestamp: \(error.localizedDescription)")
            return nil
        }
    }
}
