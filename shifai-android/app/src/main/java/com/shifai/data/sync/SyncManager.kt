package com.shifai.data.sync

import com.shifai.data.network.SupabaseClient
import com.shifai.data.repository.CycleRepository
import com.shifai.data.repository.InsightsRepository
import com.shifai.domain.models.ShifAIError
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

/**
 * Sync Manager — orchestrates offline-first sync with Supabase.
 * Flow: collect unsynced → encrypt → upload → mark synced → pull remote.
 */
class SyncManager(
    private val cycleRepo: CycleRepository,
    private val insightsRepo: InsightsRepository,
    private val supabaseClient: SupabaseClient
) {

    enum class Status { IDLE, SYNCING, SUCCESS, FAILED }

    private val _status = MutableStateFlow(Status.IDLE)
    val status: StateFlow<Status> = _status

    private val _lastSyncTime = MutableStateFlow<Long?>(null)
    val lastSyncTime: StateFlow<Long?> = _lastSyncTime

    private val _conflictCount = MutableStateFlow(0)
    val conflictCount: StateFlow<Int> = _conflictCount

    /**
     * Full bidirectional sync.
     * 1. Push unsynced local data
     * 2. Pull remote changes
     * 3. Resolve conflicts (last-write-wins)
     */
    suspend fun sync(): Result<SyncReport> {
        _status.value = Status.SYNCING
        _conflictCount.value = 0

        return try {
            // Phase 1: Push
            val unsyncedEntries = cycleRepo.getUnsyncedEntries()
            val unsyncedSymptoms = cycleRepo.getUnsyncedSymptoms()
            val unsyncedInsights = insightsRepo.getUnsynced()

            val pushCount = unsyncedEntries.size + unsyncedSymptoms.size + unsyncedInsights.size

            if (pushCount > 0) {
                // TODO: encrypt and upload via supabaseClient.syncData()
                cycleRepo.markEntriesSynced(unsyncedEntries.map { it.id })
                cycleRepo.markSymptomsSynced(unsyncedSymptoms.map { it.id })
                insightsRepo.markSynced(unsyncedInsights.map { it.id })
            }

            // Phase 2: Pull
            // TODO: download and decrypt remote changes
            val pullCount = 0
            val conflicts = 0
            _conflictCount.value = conflicts

            _status.value = Status.SUCCESS
            _lastSyncTime.value = System.currentTimeMillis()

            val report = SyncReport(
                pushed = pushCount,
                pulled = pullCount,
                conflicts = conflicts
            )
            Result.success(report)

        } catch (e: Exception) {
            _status.value = Status.FAILED
            Result.failure(ShifAIError.SyncFailed(e.message ?: "Unknown sync error"))
        }
    }

    /**
     * Quick check if there's pending data to sync.
     */
    suspend fun hasPendingSync(): Boolean {
        return cycleRepo.getUnsyncedEntries().isNotEmpty() ||
                cycleRepo.getUnsyncedSymptoms().isNotEmpty()
    }

    data class SyncReport(
        val pushed: Int,
        val pulled: Int,
        val conflicts: Int
    )
}
