import XCTest
@testable import ShifAI

final class SyncEngineTests: XCTestCase {

    // MARK: - Version Conflict Detection

    func testVersionConflict_LocalHigher_NoConflict() {
        let localVersion = 5
        let serverVersion = 3
        let conflict = SyncEngine.detectConflict(localVersion: localVersion, serverVersion: serverVersion)
        XCTAssertFalse(conflict, "Local ahead should not conflict (push needed)")
    }

    func testVersionConflict_ServerHigher_NoConflict() {
        let localVersion = 3
        let serverVersion = 5
        let conflict = SyncEngine.detectConflict(localVersion: localVersion, serverVersion: serverVersion)
        XCTAssertFalse(conflict, "Server ahead should not conflict (pull needed)")
    }

    func testVersionConflict_SameVersion_NoConflict() {
        let conflict = SyncEngine.detectConflict(localVersion: 5, serverVersion: 5)
        XCTAssertFalse(conflict, "Same version = in sync, no conflict")
    }

    func testVersionConflict_Diverged_Conflict() {
        // Both modified since last sync — true conflict
        let conflict = SyncEngine.detectConflict(
            localVersion: 5, serverVersion: 5,
            localModified: true, serverModified: true
        )
        XCTAssertTrue(conflict, "Both modified at same version = conflict")
    }

    // MARK: - Merge Strategy

    func testMergeStrategy_LastWriteWins_SelectsNewer() {
        let localEntry = SyncEntry(id: "e1", updatedAt: Date(timeIntervalSinceNow: -60))
        let serverEntry = SyncEntry(id: "e1", updatedAt: Date())

        let winner = SyncEngine.mergeLastWriteWins(local: localEntry, server: serverEntry)
        XCTAssertEqual(winner.updatedAt, serverEntry.updatedAt, "Newer entry should win")
    }

    func testMergeStrategy_LocalNewer_SelectsLocal() {
        let localEntry = SyncEntry(id: "e1", updatedAt: Date())
        let serverEntry = SyncEntry(id: "e1", updatedAt: Date(timeIntervalSinceNow: -120))

        let winner = SyncEngine.mergeLastWriteWins(local: localEntry, server: serverEntry)
        XCTAssertEqual(winner.updatedAt, localEntry.updatedAt, "Local newer should win")
    }

    // MARK: - Sync State

    func testSyncState_RequiresPush_WhenLocalAhead() {
        let action = SyncEngine.determineSyncAction(
            localVersion: 5, serverVersion: 3,
            localModified: true, serverModified: false
        )
        XCTAssertEqual(action, .push)
    }

    func testSyncState_RequiresPull_WhenServerAhead() {
        let action = SyncEngine.determineSyncAction(
            localVersion: 3, serverVersion: 5,
            localModified: false, serverModified: true
        )
        XCTAssertEqual(action, .pull)
    }

    func testSyncState_InSync_WhenBothSameVersion() {
        let action = SyncEngine.determineSyncAction(
            localVersion: 5, serverVersion: 5,
            localModified: false, serverModified: false
        )
        XCTAssertEqual(action, .inSync)
    }
}

// MARK: - Test Helpers

struct SyncEntry {
    let id: String
    let updatedAt: Date
}
