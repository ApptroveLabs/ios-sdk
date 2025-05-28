import Foundation

final class SKANNetworkService {
    static let shared = SKANNetworkService()
    
    private var appKeys: String {
        guard let key = TrackierSDK.getAppToken() else {
            Logger.error(message: "Trackier SDK not initialized or app token not available")
            return ""
        }
        return key
    }
    
    private let session: URLSession
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0
    
    init(session: URLSession = .shared) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchConfig(completion: @escaping (Result<SKANConfig, Error>) -> Void) {
        fetchConfig(attempt: 1, completion: completion)
    }
    
    private func fetchConfig(attempt: Int, completion: @escaping (Result<SKANConfig, Error>) -> Void) {
        guard !appKeys.isEmpty else {
            completion(.failure(SKANError.configurationMissing))
            return
        }
        
        let urlString = Constants.SKANURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: urlString) else {
            Logger.error(message: "Invalid SKAN URL from Constants: \(urlString)")
            completion(.failure(SKANError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TrackierSDK/1.6.60 (iOS)", forHTTPHeaderField: "User-Agent")
        
        let body: [String: String] = ["appKey": appKeys]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
            Logger.debug(message: "Request body: \(String(data: jsonData, encoding: .utf8) ?? "Failed to decode body")")
        } catch {
            Logger.error(message: "Failed to serialize appKey JSON: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        Logger.debug(message: "Attempt \(attempt) to fetch SKAN config with URL: \(url.absoluteString)")
        Logger.debug(message: "Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                Logger.error(message: "Network error fetching SKAN config (attempt \(attempt)): \(error.localizedDescription)")
                if attempt < self.maxRetries {
                    Logger.debug(message: "Retrying fetch in \(self.retryDelay) seconds...")
                    DispatchQueue.global().asyncAfter(deadline: .now() + self.retryDelay) {
                        self.fetchConfig(attempt: attempt + 1, completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.error(message: "Invalid response received (not HTTP, attempt \(attempt))")
                completion(.failure(SKANError.invalidResponse))
                return
            }
            
            Logger.debug(message: "Received response with status: \(httpResponse.statusCode)")
            Logger.debug(message: "Response headers: \(httpResponse.allHeaderFields)")
            
            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                Logger.debug(message: "Raw SKAN config response: \(rawResponse)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                Logger.error(message: "Server error with status code: \(httpResponse.statusCode)")
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    Logger.error(message: "Error response body: \(errorResponse)")
                }
                completion(.failure(SKANError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                Logger.error(message: "No data received from server")
                completion(.failure(SKANError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder.skanDecoder
                let apiResponse = try decoder.decode(SKANResponse.self, from: data)
                Logger.debug(message: "Decoded API response - Success: \(apiResponse.success), Message: \(apiResponse.message ?? "none")")
                
                guard apiResponse.success, let config = apiResponse.data else {
                    Logger.error(message: "API reported failure: \(apiResponse.message ?? "Unknown error")")
                    completion(.failure(SKANError.invalidResponse))
                    return
                }
                
                try config.validate()
                Logger.debug(message: "Successfully fetched and validated config - ID: \(config.id), AID: \(config.aid)")
                completion(.success(config))
            } catch {
                Logger.error(message: "Failed to decode or validate SKAN config: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
