package com.shifai.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import java.time.LocalDate
import java.util.UUID

/**
 * Room Entity — mirrors backend predictions table.
 */
@Entity(
    tableName = "predictions",
    indices = [Index(value = ["predicted_date"])]
)
data class PredictionEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val type: String,
    @ColumnInfo(name = "predicted_date") val predictedDate: LocalDate,
    val confidence: Float = 0f,
    @ColumnInfo(name = "actual_date") val actualDate: LocalDate? = null,
    val source: String = "rule_based",
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis()
)

/**
 * DAO for predictions.
 */
@Dao
interface PredictionDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(prediction: PredictionEntity)

    @Query("SELECT * FROM predictions ORDER BY predicted_date DESC")
    fun observeAll(): Flow<List<PredictionEntity>>

    @Query("SELECT * FROM predictions WHERE type = :type ORDER BY predicted_date DESC LIMIT 1")
    suspend fun getLatest(type: String): PredictionEntity?

    @Query("SELECT * FROM predictions WHERE predicted_date >= :fromDate ORDER BY predicted_date ASC")
    suspend fun getUpcoming(fromDate: LocalDate): List<PredictionEntity>

    @Query("UPDATE predictions SET actual_date = :actual WHERE id = :id")
    suspend fun setActualDate(id: String, actual: LocalDate)

    @Query("SELECT * FROM predictions WHERE actual_date IS NOT NULL")
    suspend fun getVerified(): List<PredictionEntity>

    @Query("SELECT * FROM predictions WHERE is_synced = 0")
    suspend fun getUnsynced(): List<PredictionEntity>

    @Delete
    suspend fun delete(prediction: PredictionEntity)
}

/**
 * Room Entity — sync_logs for conflict tracking.
 */
@Entity(
    tableName = "sync_logs",
    indices = [Index(value = ["synced_at"])]
)
data class SyncLogEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val action: String,
    @ColumnInfo(name = "entity_type") val entityType: String,
    @ColumnInfo(name = "entity_id") val entityId: String,
    val status: String = "pending",
    @ColumnInfo(name = "error_message") val errorMessage: String? = null,
    @ColumnInfo(name = "synced_at") val syncedAt: Long = System.currentTimeMillis()
)

/**
 * DAO for sync logs.
 */
@Dao
interface SyncLogDao {

    @Insert
    suspend fun insert(log: SyncLogEntity)

    @Query("SELECT * FROM sync_logs ORDER BY synced_at DESC LIMIT :limit")
    suspend fun getRecent(limit: Int = 50): List<SyncLogEntity>

    @Query("SELECT * FROM sync_logs WHERE status = 'failed' ORDER BY synced_at DESC")
    suspend fun getFailed(): List<SyncLogEntity>

    @Query("SELECT COUNT(*) FROM sync_logs WHERE status = 'pending'")
    suspend fun pendingCount(): Int

    @Query("UPDATE sync_logs SET status = :status WHERE id = :id")
    suspend fun updateStatus(id: String, status: String)

    @Query("DELETE FROM sync_logs WHERE synced_at < :before")
    suspend fun deleteOlderThan(before: Long)
}
