import Foundation

/// Image Cache — in-memory + disk caching for chart and insight images.
/// Prevents redundant rendering of cycle charts.
final class ImageCache {

    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, NSData>()
    private let cacheDir: URL
    private let maxDiskSize = 50_000_000  // 50 MB

    private init() {
        cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("shifai_images")

        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        memoryCache.countLimit = 50
        memoryCache.totalCostLimit = 10_000_000  // 10 MB
    }

    // MARK: - Read

    func get(_ key: String) -> Data? {
        // Check memory first
        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached as Data
        }

        // Check disk
        let fileURL = cacheDir.appendingPathComponent(key.md5Hash)
        if let data = FileManager.default.contents(atPath: fileURL.path) {
            memoryCache.setObject(data as NSData, forKey: key as NSString)
            return data
        }

        return nil
    }

    // MARK: - Write

    func set(_ data: Data, forKey key: String) {
        memoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)

        let fileURL = cacheDir.appendingPathComponent(key.md5Hash)
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Clear

    func clearMemory() {
        memoryCache.removeAllObjects()
    }

    func clearDisk() {
        try? FileManager.default.removeItem(at: cacheDir)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    func clearAll() {
        clearMemory()
        clearDisk()
    }

    // MARK: - Stats

    var diskSize: Int {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: cacheDir.path)) ?? []
        return files.reduce(0) { total, file in
            let attrs = try? FileManager.default.attributesOfItem(atPath: cacheDir.appendingPathComponent(file).path)
            return total + (attrs?[.size] as? Int ?? 0)
        }
    }
}

private extension String {
    var md5Hash: String {
        // Simple hash for cache key (not cryptographic)
        let hash = self.utf8.reduce(0) { ($0 &<< 5) &- $0 &+ Int($1) }
        return String(format: "%08x", abs(hash))
    }
}
