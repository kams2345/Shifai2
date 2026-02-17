package com.shifai.data.repository

import com.shifai.data.local.InsightDao
import com.shifai.data.local.InsightEntity
import kotlinx.coroutines.flow.Flow

/**
 * Insights Repository — manages insight CRUD and feedback.
 * Offline-first, same pattern as CycleRepository.
 */
class InsightsRepository(
    private val insightDao: InsightDao
) {

    // ─── Observe ───

    fun observeAll(): Flow<List<InsightEntity>> = insightDao.observeAll()

    fun observeByType(type: String): Flow<List<InsightEntity>> = insightDao.observeByType(type)

    fun observeUnreadCount(): Flow<Int> = insightDao.observeUnreadCount()

    // ─── Read ───

    suspend fun getUnread(): List<InsightEntity> = insightDao.getUnread()

    // ─── Write ───

    suspend fun save(insight: InsightEntity) {
        insightDao.upsert(insight.copy(isSynced = false))
    }

    suspend fun markRead(id: String) {
        insightDao.markRead(id)
    }

    suspend fun submitFeedback(id: String, feedback: String) {
        insightDao.setFeedback(id, feedback)
    }

    // ─── Sync ───

    suspend fun getUnsynced(): List<InsightEntity> = insightDao.getUnsynced()

    suspend fun markSynced(ids: List<String>) {
        insightDao.markSynced(ids)
    }

    // ─── Danger Zone ───

    suspend fun deleteAll() {
        insightDao.deleteAll()
    }
}
