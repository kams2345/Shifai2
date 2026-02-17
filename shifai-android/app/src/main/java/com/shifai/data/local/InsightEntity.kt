package com.shifai.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import java.util.UUID

/**
 * Room Entity — mirrors backend insights table.
 */
@Entity(
    tableName = "insights",
    indices = [Index(value = ["created_at"])]
)
data class InsightEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val type: String,
    val title: String,
    val body: String,
    val confidence: Float = 0f,
    @ColumnInfo(name = "is_read") val isRead: Boolean = false,
    val feedback: String? = null,
    val source: String = "rule_based",
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis()
)

/**
 * DAO — CRUD for insights.
 */
@Dao
interface InsightDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(insight: InsightEntity)

    @Query("SELECT * FROM insights ORDER BY created_at DESC")
    fun observeAll(): Flow<List<InsightEntity>>

    @Query("SELECT * FROM insights WHERE type = :type ORDER BY created_at DESC")
    fun observeByType(type: String): Flow<List<InsightEntity>>

    @Query("SELECT * FROM insights WHERE is_read = 0 ORDER BY created_at DESC")
    suspend fun getUnread(): List<InsightEntity>

    @Query("SELECT COUNT(*) FROM insights WHERE is_read = 0")
    fun observeUnreadCount(): Flow<Int>

    @Query("UPDATE insights SET is_read = 1 WHERE id = :id")
    suspend fun markRead(id: String)

    @Query("UPDATE insights SET feedback = :feedback WHERE id = :id")
    suspend fun setFeedback(id: String, feedback: String)

    @Query("SELECT * FROM insights WHERE is_synced = 0")
    suspend fun getUnsynced(): List<InsightEntity>

    @Query("UPDATE insights SET is_synced = 1 WHERE id IN (:ids)")
    suspend fun markSynced(ids: List<String>)

    @Delete
    suspend fun delete(insight: InsightEntity)

    @Query("DELETE FROM insights")
    suspend fun deleteAll()
}
