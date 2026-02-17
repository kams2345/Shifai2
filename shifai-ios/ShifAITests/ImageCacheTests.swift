import XCTest
@testable import ShifAI

final class ImageCacheTests: XCTestCase {

    let cache = ImageCache.shared

    override func setUp() {
        cache.clearAll()
    }

    func testSetAndGet() {
        let data = "test".data(using: .utf8)!
        cache.set(data, forKey: "chart_1")
        let result = cache.get("chart_1")
        XCTAssertEqual(result, data)
    }

    func testMissingKeyReturnsNil() {
        let result = cache.get("nonexistent_key")
        XCTAssertNil(result)
    }

    func testClearMemory() {
        let data = "test".data(using: .utf8)!
        cache.set(data, forKey: "chart_clear")
        cache.clearMemory()
        // Disk still has it
        let result = cache.get("chart_clear")
        XCTAssertNotNil(result)
    }

    func testClearAll() {
        let data = "test".data(using: .utf8)!
        cache.set(data, forKey: "chart_all")
        cache.clearAll()
        let result = cache.get("chart_all")
        XCTAssertNil(result)
    }

    func testDiskSizeZeroWhenEmpty() {
        cache.clearAll()
        XCTAssertEqual(cache.diskSize, 0)
    }

    func testDiskSizeIncreasesAfterSet() {
        let data = Data(repeating: 0xFF, count: 1000)
        cache.set(data, forKey: "large_chart")
        XCTAssertGreaterThan(cache.diskSize, 0)
    }

    func testMultipleKeys() {
        cache.set("a".data(using: .utf8)!, forKey: "key1")
        cache.set("b".data(using: .utf8)!, forKey: "key2")
        XCTAssertNotNil(cache.get("key1"))
        XCTAssertNotNil(cache.get("key2"))
    }

    func testOverwriteKey() {
        cache.set("old".data(using: .utf8)!, forKey: "key")
        cache.set("new".data(using: .utf8)!, forKey: "key")
        XCTAssertEqual(cache.get("key"), "new".data(using: .utf8))
    }

    func testEmptyData() {
        let data = Data()
        cache.set(data, forKey: "empty")
        XCTAssertNotNil(cache.get("empty"))
    }

    func testCacheIsSingleton() {
        XCTAssertTrue(ImageCache.shared === ImageCache.shared)
    }
}
