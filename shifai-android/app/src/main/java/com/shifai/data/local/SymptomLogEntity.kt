package com.shifai.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import java.util.UUID

/**
 * Room Entity — mirrors backend symptom_logs table.
 */
@Entity(
    tableName = "symptom_logs",
    foreignKeys = [ForeignKey(
        entity = CycleEntryEntity::class,
        parentColumns = ["id"],
        childColumns = ["cycle_entry_id"],
        onDelete = ForeignKey.CASCADE
    )],
    indices = [Index(value = ["cycle_entry_id"])]
)
data class SymptomLogEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    @ColumnInfo(name = "cycle_entry_id") val cycleEntryId: String,
    val category: String,
    @ColumnInfo(name = "symptom_type") val symptomType: String,
    val intensity: Int,
    @ColumnInfo(name = "body_zone") val bodyZone: String? = null,
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis()
)

/**
 * DAO — CRUD for symptom logs.
 */
@Dao
interface SymptomLogDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(log: SymptomLogEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(logs: List<SymptomLogEntity>)

    @Query("SELECT * FROM symptom_logs WHERE cycle_entry_id = :entryId")
    suspend fun getByEntry(entryId: String): List<SymptomLogEntity>

    @Query("SELECT * FROM symptom_logs WHERE cycle_entry_id = :entryId")
    fun observeByEntry(entryId: String): Flow<List<SymptomLogEntity>>

    @Query("SELECT DISTINCT category FROM symptom_logs")
    suspend fun getCategories(): List<String>

    @Query("SELECT * FROM symptom_logs WHERE category = :category ORDER BY created_at DESC")
    suspend fun getByCategory(category: String): List<SymptomLogEntity>

    @Query("SELECT * FROM symptom_logs WHERE is_synced = 0")
    suspend fun getUnsynced(): List<SymptomLogEntity>

    @Query("UPDATE symptom_logs SET is_synced = 1 WHERE id IN (:ids)")
    suspend fun markSynced(ids: List<String>)

    @Delete
    suspend fun delete(log: SymptomLogEntity)

    @Query("DELETE FROM symptom_logs WHERE cycle_entry_id = :entryId")
    suspend fun deleteByEntry(entryId: String)

    @Query("SELECT COUNT(*) FROM symptom_logs")
    suspend fun count(): Int
}
