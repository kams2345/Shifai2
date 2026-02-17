package com.shifai.data.local

import androidx.room.*
import com.shifai.domain.models.CyclePhase
import kotlinx.coroutines.flow.Flow
import java.time.LocalDate
import java.util.UUID

/**
 * Room Entity — mirrors backend cycle_entries table.
 */
@Entity(
    tableName = "cycle_entries",
    indices = [Index(value = ["date"], unique = true)]
)
data class CycleEntryEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val date: LocalDate,
    @ColumnInfo(name = "cycle_day") val cycleDay: Int,
    val phase: CyclePhase,
    @ColumnInfo(name = "flow_intensity") val flowIntensity: Int = 0,
    @ColumnInfo(name = "mood_score") val moodScore: Int = 5,
    @ColumnInfo(name = "energy_score") val energyScore: Int = 5,
    @ColumnInfo(name = "sleep_hours") val sleepHours: Float = 0f,
    @ColumnInfo(name = "stress_level") val stressLevel: Int = 5,
    val notes: String = "",
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "updated_at") val updatedAt: Long = System.currentTimeMillis()
)

/**
 * DAO — CRUD + queries for cycle entries.
 */
@Dao
interface CycleEntryDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(entry: CycleEntryEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(entries: List<CycleEntryEntity>)

    @Query("SELECT * FROM cycle_entries WHERE date = :date LIMIT 1")
    suspend fun getByDate(date: LocalDate): CycleEntryEntity?

    @Query("SELECT * FROM cycle_entries ORDER BY date DESC")
    fun observeAll(): Flow<List<CycleEntryEntity>>

    @Query("SELECT * FROM cycle_entries ORDER BY date DESC LIMIT :limit")
    suspend fun getRecent(limit: Int): List<CycleEntryEntity>

    @Query("SELECT * FROM cycle_entries WHERE date BETWEEN :start AND :end ORDER BY date ASC")
    suspend fun getRange(start: LocalDate, end: LocalDate): List<CycleEntryEntity>

    @Query("SELECT * FROM cycle_entries WHERE is_synced = 0")
    suspend fun getUnsynced(): List<CycleEntryEntity>

    @Query("UPDATE cycle_entries SET is_synced = 1 WHERE id IN (:ids)")
    suspend fun markSynced(ids: List<String>)

    @Delete
    suspend fun delete(entry: CycleEntryEntity)

    @Query("DELETE FROM cycle_entries")
    suspend fun deleteAll()

    @Query("SELECT COUNT(*) FROM cycle_entries")
    suspend fun count(): Int
}
