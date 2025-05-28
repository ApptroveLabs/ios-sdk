import Foundation
import StoreKit
import UIKit

final class SKANManager {
    static let shared = SKANManager()

    struct Configuration {
        var minimumRevenueDelta: Double = 1.0
        var maximumUpdateFrequency: TimeInterval = 3600
        var automaticSessionTracking: Bool = true
        var debugMode: Bool = false
        var registerForAttribution: Bool = true
    }

    private var config: SKANConfig?
    private var configuration = Configuration()
    private var currentValues: [Int: SKANCurrentValues] = [
        1: SKANCurrentValues(),
        2: SKANCurrentValues(),
        3: SKANCurrentValues()
    ]

    private let networkService: SKANNetworkService
    private let storage: SKANStorage
    private let queue = DispatchQueue(label: "com.trackier.skan.queue", qos: .utility)
    private var isInitialized = false
    private var isInitializing = false
    private var initializationQueue = DispatchQueue(label: "com.trackier.skan.init.queue")
    private var lastRevenueValue: Double = 0
    private var lastEventId: String?
    private var pendingUpdates: [() -> Void] = []

    init(networkService: SKANNetworkService = .shared, storage: SKANStorage = .shared) {
        self.networkService = networkService
        self.storage = storage
    }

    func configure(config: Configuration = Configuration()) {
        initializationQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.isInitialized || self.isInitializing {
                return
            }
            
            self.isInitializing = true
            self.configuration = config
            
            // Load cached config if available
            self.loadConfig()
            
            // Fetch fresh config from server
            self.fetchConfig { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let config):
                    do {
                        try config.validate()
                        self.config = config
                        self.storage.saveConfig(config, aid: "default")
                        self.logDebug("Fetched and validated SKAN config")
                    } catch {
                        self.logError("SKAN config validation failed: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    self.logError("Failed to fetch SKAN config: \(error.localizedDescription)")
                }
                
                if config.registerForAttribution {
                    self.registerForAttribution()
                }
                
                if config.automaticSessionTracking {
                    self.startSessionTracking()
                }
                
                self.isInitialized = true
                self.isInitializing = false
                
                // Process any pending updates
                self.processPendingUpdates()
            }
        }
    }

    func registerForAttribution() {
        if isSimulator() {
            logWarning("SKAdNetwork registration skipped in simulator")
            return
        }
        if #available(iOS 14.0, *) {
            SKAdNetwork.registerAppForAdNetworkAttribution()
            logDebug("Registered for SKAdNetwork attribution")
        }
    }

    func updateConversionValue(revenue: Double, eventId: String? = nil, completion: ((Bool, Error?) -> Void)? = nil) {
        let updateBlock = { [weak self] in
            guard let self = self else { return }
            
            let now = Date()
            if let lastUpdate = self.currentValues[1]?.lastUpdated,
               now.timeIntervalSince(lastUpdate) < self.configuration.maximumUpdateFrequency,
               abs(revenue - self.lastRevenueValue) < self.configuration.minimumRevenueDelta,
               eventId == self.lastEventId {
                self.logDebug("Skipping SKAN update - too frequent or insignificant change")
                completion?(false, SKANError.updateTooFrequent)
                return
            }

            self.lastRevenueValue = revenue
            self.lastEventId = eventId

            guard let config = self.config else {
                self.logWarning("SKAN config not loaded, using defaults")
                self.updateSystemConversionValues(fine: 0, coarse: .low, lock: false, completion: completion)
                return
            }

            self.updateWindow(window: config.window1, index: 1, revenue: revenue, eventId: eventId)
            self.updateWindow(window: config.window2, index: 2, revenue: revenue, eventId: eventId)
            self.updateWindow(window: config.window3, index: 3, revenue: revenue, eventId: eventId)
            self.updateSystemConversionValues(completion: completion)
        }
        
        if isInitialized {
            queue.async(execute: updateBlock)
        } else {
            pendingUpdates.append(updateBlock)
        }
    }

    @available(iOS 16.1, *)
    func updatePostbackConversionValue(fineValue: Int, coarseValue: SKANCoarseType, lockWindow: Bool, completion: ((Bool, Error?) -> Void)? = nil) {
        let updateBlock = { [weak self] in
            guard let self = self else { return }
            
            // Validate fine value
            guard fineValue >= 0 && fineValue <= 63 else {
                self.logError("Invalid fine value: \(fineValue). Must be between 0 and 63")
                completion?(false, SKANError.invalidConfig(NSError(domain: "SKANManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fine value out of range"])))
                return
            }
            
            var window1 = self.currentValues[1] ?? SKANCurrentValues()
            window1.fine = fineValue
            window1.coarse = coarseValue
            window1.lock = lockWindow
            window1.lastUpdated = Date()
            self.currentValues[1] = window1
            
            if self.isSimulator() {
                self.logWarning("SKAdNetwork update skipped in simulator. Values: Fine=\(fineValue), Coarse=\(coarseValue.rawValue), Lock=\(lockWindow)")
                completion?(true, nil)
                return
            }
            
            SKAdNetwork.updatePostbackConversionValue(
                fineValue,
                coarseValue: coarseValue.skAdNetworkValue,
                lockWindow: lockWindow
            ) { error in
                if let error = error {
                    self.logError("SKAN update failed: \(error.localizedDescription)")
                    completion?(false, SKANError.postbackError(error))
                } else {
                    self.logDebug("SKAN updated successfully (iOS 16.1+) - Fine: \(fineValue), Coarse: \(coarseValue.rawValue), Lock: \(lockWindow)")
                    completion?(true, nil)
                }
            }
        }
        
        if isInitialized {
            queue.async(execute: updateBlock)
        } else {
            pendingUpdates.append(updateBlock)
        }
    }

    func getCurrentValues() -> (fine: Int?, coarse: String?) {
        let window1 = currentValues[1]
        return (window1?.fine, window1?.coarse?.rawValue)
    }

    @available(iOS 16.1, *)
    func testPostback(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        queue.async { [weak self] in
            guard let self = self, let window1 = self.currentValues[1] else {
                self?.logError("Test postback failed: SKAN not configured or no values")
                DispatchQueue.main.async { completion(false, SKANError.configurationMissing) }
                return
            }
            let fineValue = window1.fine ?? 0
            let coarseValue = window1.coarse?.rawValue ?? "none"
            self.logDebug("""
            Simulated SKAN postback to \(url):
            - Fine value: \(fineValue)
            - Coarse value: \(coarseValue)
            - Lock window: \(window1.lock)
            """)
            DispatchQueue.main.async { completion(true, nil) }
        }
    }

    // MARK: - Private Methods
    
    private func processPendingUpdates() {
        guard isInitialized else { return }
        
        let updates = pendingUpdates
        pendingUpdates.removeAll()
        
        for update in updates {
            queue.async(execute: update)
        }
    }

    private func startSessionTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func appDidBecomeActive() {
        if lastEventId == nil {
            updateConversionValue(revenue: 0, eventId: "first_open")
        } else {
            updateConversionValue(revenue: lastRevenueValue, eventId: "session_start")
        }
    }

    private func loadConfig() {
        if let cachedConfig = storage.loadConfig(aid: "default") {
            self.config = cachedConfig
            logDebug("Loaded cached SKAN config")
        }
    }
    
    private func fetchConfig(completion: @escaping (Result<SKANConfig, Error>) -> Void) {
        networkService.fetchConfig { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let config):
                completion(.success(config))
            case .failure(let error):
                self.logError("Failed to fetch SKAN config: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    private func updateWindow(window: SKANWindow, index: Int, revenue: Double, eventId: String?) {
        guard index >= 1 && index <= 3 else { return }
        var currentValue = currentValues[index] ?? SKANCurrentValues()

        if index == 1, let fineValues = window.fineValues {
            if let fine = fineValues.first(where: { $0.matches(eventId: eventId, revenue: revenue) }) {
                currentValue.fine = fine.value
            }
        }

        if let coarseValues = window.coarseValues,
           let coarse = coarseValues.first(where: { $0.matches(eventId: eventId, revenue: revenue) }) {
            currentValue.coarse = coarse.type
            currentValue.lock = window.shouldLock
        }

        currentValue.lastUpdated = Date()
        currentValues[index] = currentValue
    }

    private func updateSystemConversionValues(fine: Int? = nil, coarse: SKANCoarseType? = nil, lock: Bool? = nil, completion: ((Bool, Error?) -> Void)? = nil) {
        let window1 = currentValues[1] ?? SKANCurrentValues()
        let finalFine = fine ?? window1.fine ?? 0
        let finalCoarse = coarse ?? window1.coarse ?? .low
        let finalLock = lock ?? window1.lock

        // Validate fine value
        guard finalFine >= 0 && finalFine <= 63 else {
            logError("Invalid fine value: \(finalFine). Must be between 0 and 63")
            completion?(false, SKANError.invalidConfig(NSError(domain: "SKANManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fine value out of range"])))
            return
        }

        if isSimulator() {
            logWarning("SKAdNetwork update skipped in simulator. Values: Fine=\(finalFine), Coarse=\(finalCoarse.rawValue), Lock=\(finalLock)")
            completion?(true, nil)
            return
        }

        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(
                finalFine,
                coarseValue: finalCoarse.skAdNetworkValue,
                lockWindow: finalLock
            ) { [weak self] error in
                if let error = error {
                    self?.logError("SKAN update failed: \(error.localizedDescription)")
                    completion?(false, SKANError.postbackError(error))
                } else {
                    self?.logDebug("SKAN updated successfully (iOS 16.1+) - Fine: \(finalFine), Coarse: \(finalCoarse.rawValue), Lock: \(finalLock)")
                    completion?(true, nil)
                }
            }
        } else if #available(iOS 15.4, *) {
            SKAdNetwork.updatePostbackConversionValue(finalFine) { [weak self] error in
                if let error = error {
                    self?.logError("SKAN update failed: \(error.localizedDescription)")
                    completion?(false, SKANError.postbackError(error))
                } else {
                    self?.logDebug("SKAN updated (iOS 15.4) - Fine: \(finalFine)")
                    completion?(true, nil)
                }
            }
        } else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(finalFine)
            logDebug("SKAN updated (iOS 14.0) - Fine: \(finalFine)")
            completion?(true, nil)
        } else {
            completion?(false, SKANError.unsupportediOSVersion)
        }

        if let aid = config?.aid {
            storage.saveLastUpdateTimestamp(Date(), aid: aid)
        }
    }

    private func updateSystemConversionValues(completion: ((Bool, Error?) -> Void)? = nil) {
        updateSystemConversionValues(fine: nil, coarse: nil, lock: nil, completion: completion)
    }

    private func logDebug(_ message: String) {
        if configuration.debugMode {
            Logger.debug(message: "[SKAN Debug] \(message)")
        }
    }

    private func logError(_ message: String) {
        Logger.error(message: "[SKAN Error] \(message)")
    }

    private func logWarning(_ message: String) {
        Logger.warning(message: "[SKAN Warning] \(message)")
    }

    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
