import Foundation

/// Supabase API Client — centralized network layer.
/// All requests go through this client with auth headers, cert pinning, and error handling.
actor SupabaseClient {

    static let shared = SupabaseClient()

    private let baseURL: URL
    private let anonKey: String
    private let session: URLSession

    private var accessToken: String?

    private init() {
        self.baseURL = URL(string: AppConfig.supabaseURL)!
        self.anonKey = AppConfig.supabaseAnonKey
        self.session = NetworkSecurityManager.shared.pinnedSession
    }

    // MARK: - Auth

    func setAccessToken(_ token: String?) {
        self.accessToken = token
    }

    // MARK: - REST API

    func fetch<T: Decodable>(
        from table: String,
        query: [String: String] = [:],
        as type: T.Type
    ) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent("rest/v1/\(table)"), resolvingAgainstBaseURL: false)!
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        applyHeaders(&request)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try JSONDecoder.supabase.decode(T.self, from: data)
    }

    func insert(
        into table: String,
        body: [String: Any]
    ) async throws -> Data {
        let url = baseURL.appendingPathComponent("rest/v1/\(table)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        applyHeaders(&request)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return data
    }

    func update(
        table: String,
        id: String,
        body: [String: Any]
    ) async throws -> Data {
        var components = URLComponents(url: baseURL.appendingPathComponent("rest/v1/\(table)"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "id", value: "eq.\(id)")]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "PATCH"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyHeaders(&request)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return data
    }

    func delete(from table: String, id: String) async throws {
        var components = URLComponents(url: baseURL.appendingPathComponent("rest/v1/\(table)"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "id", value: "eq.\(id)")]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        applyHeaders(&request)

        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    // MARK: - Edge Functions

    func invokeFunction(
        _ name: String,
        body: [String: Any]? = nil
    ) async throws -> Data {
        let url = baseURL.appendingPathComponent("functions/v1/\(name)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        applyHeaders(&request)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return data
    }

    // MARK: - Storage

    func uploadBlob(bucket: String, path: String, data: Data) async throws -> String {
        let url = baseURL.appendingPathComponent("storage/v1/object/\(bucket)/\(path)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        applyHeaders(&request)

        let (responseData, response) = try await session.data(for: request)
        try validateResponse(response)

        if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
           let key = json["Key"] as? String {
            return key
        }
        return path
    }

    // MARK: - Private

    private func applyHeaders(_ request: inout URLRequest) {
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode)
        }
    }
}

// MARK: - Errors

enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case unauthorized
    case conflict
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Réponse invalide du serveur"
        case .httpError(let code): return "Erreur HTTP \(code)"
        case .decodingFailed: return "Erreur de décodage"
        case .unauthorized: return "Non autorisé"
        case .conflict: return "Conflit de synchronisation"
        case .serverError: return "Erreur serveur"
        }
    }
}

// MARK: - JSON Decoder

extension JSONDecoder {
    static let supabase: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
