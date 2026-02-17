package com.shifai.data.local

import android.content.Context
import androidx.room.*
import net.sqlcipher.database.SQLiteDatabase
import net.sqlcipher.database.SupportFactory
import java.util.Date

// MARK: - Room Entities

@Entity(tableName = "cycle_entries")
data class CycleEntryEntity(
    @PrimaryKey val id: String,
    val date: Long, // epoch millis
    @ColumnInfo(name = "cycle_day") val cycleDay: Int,
    val phase: String,
    @ColumnInfo(name = "flow_intensity") val flowIntensity: Int?,
    @ColumnInfo(name = "cervical_mucus") val cervicalMucus: String?,
    @ColumnInfo(name = "basal_temp") val basalTemp: Double?,
    val notes: String?,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis(),
    @ColumnInfo(name = "updated_at") val updatedAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "symptom_logs")
data class SymptomLogEntity(
    @PrimaryKey val id: String,
    val date: Long,
    @ColumnInfo(name = "symptom_type") val symptomType: String,
    val intensity: Int,
    @ColumnInfo(name = "body_zone") val bodyZone: String?,
    @ColumnInfo(name = "pain_type") val painType: String?,
    val notes: String?,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "insights")
data class InsightEntity(
    @PrimaryKey val id: String,
    val type: String,
    val title: String,
    val body: String,
    val reasoning: String?,
    val confidence: Double?,
    @ColumnInfo(name = "is_read") val isRead: Boolean = false,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "predictions")
data class PredictionEntity(
    @PrimaryKey val id: String,
    val type: String,
    @ColumnInfo(name = "predicted_date") val predictedDate: Long,
    @ColumnInfo(name = "confidence_range") val confidenceRange: Int,
    val confidence: Double,
    val reasoning: String?,
    @ColumnInfo(name = "actual_date") val actualDate: Long?,
    @ColumnInfo(name = "user_feedback") val userFeedback: String?,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "user_profile")
data class UserProfileEntity(
    @PrimaryKey val id: String = "default",
    val age: Int?,
    @ColumnInfo(name = "avg_cycle_length") val avgCycleLength: Int?,
    val conditions: String?, // JSON array
    @ColumnInfo(name = "tracked_symptoms") val trackedSymptoms: String?, // JSON array
    val locale: String = "fr",
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis(),
    @ColumnInfo(name = "updated_at") val updatedAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "sync_log")
data class SyncLogEntity(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "sync_type") val syncType: String,
    @ColumnInfo(name = "blob_version") val blobVersion: Int,
    @ColumnInfo(name = "synced_at") val syncedAt: Long,
    val status: String,
    @ColumnInfo(name = "error_message") val errorMessage: String?
)

// MARK: - DAOs

@Dao
interface CycleEntryDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entry: CycleEntryEntity)

    @Update
    suspend fun update(entry: CycleEntryEntity)

    @Query("DELETE FROM cycle_entries WHERE id = :id")
    suspend fun delete(id: String)

    @Query("SELECT * FROM cycle_entries ORDER BY date DESC")
    suspend fun getAll(): List<CycleEntryEntity>

    @Query("SELECT * FROM cycle_entries WHERE date = :dateMillis LIMIT 1")
    suspend fun getByDate(dateMillis: Long): CycleEntryEntity?

    @Query("SELECT * FROM cycle_entries ORDER BY date DESC LIMIT :count")
    suspend fun getLast(count: Int): List<CycleEntryEntity>

    @Query("SELECT * FROM cycle_entries WHERE date BETWEEN :fromMillis AND :toMillis ORDER BY date ASC")
    suspend fun getByDateRange(fromMillis: Long, toMillis: Long): List<CycleEntryEntity>
}

@Dao
interface SymptomLogDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(log: SymptomLogEntity)

    @Update
    suspend fun update(log: SymptomLogEntity)

    @Query("DELETE FROM symptom_logs WHERE id = :id")
    suspend fun delete(id: String)

    @Query("SELECT * FROM symptom_logs WHERE date BETWEEN :startMillis AND :endMillis ORDER BY created_at DESC")
    suspend fun getByDate(startMillis: Long, endMillis: Long): List<SymptomLogEntity>

    @Query("SELECT * FROM symptom_logs WHERE date BETWEEN :fromMillis AND :toMillis ORDER BY date ASC")
    suspend fun getByDateRange(fromMillis: Long, toMillis: Long): List<SymptomLogEntity>

    @Query("SELECT * FROM symptom_logs WHERE symptom_type = :type ORDER BY date DESC")
    suspend fun getByType(type: String): List<SymptomLogEntity>

    @Query("SELECT symptom_type, COUNT(*) as count FROM symptom_logs GROUP BY symptom_type ORDER BY count DESC LIMIT :limit")
    suspend fun getMostFrequent(limit: Int): List<SymptomFrequency>
}

data class SymptomFrequency(
    @ColumnInfo(name = "symptom_type") val symptomType: String,
    val count: Int
)

@Dao
interface InsightDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(insight: InsightEntity)

    @Query("SELECT * FROM insights ORDER BY created_at DESC LIMIT :limit")
    suspend fun getRecent(limit: Int): List<InsightEntity>

    @Query("SELECT * FROM insights WHERE is_read = 0 ORDER BY created_at DESC")
    suspend fun getUnread(): List<InsightEntity>

    @Query("UPDATE insights SET is_read = 1 WHERE id = :id")
    suspend fun markAsRead(id: String)
}

@Dao
interface PredictionDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(prediction: PredictionEntity)

    @Query("SELECT * FROM predictions ORDER BY created_at DESC LIMIT 1")
    suspend fun getLatest(): PredictionEntity?

    @Query("SELECT * FROM predictions ORDER BY created_at DESC")
    suspend fun getAll(): List<PredictionEntity>

    @Query("UPDATE predictions SET user_feedback = :feedback WHERE id = :id")
    suspend fun submitFeedback(id: String, feedback: String)
}

@Dao
interface UserProfileDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdate(profile: UserProfileEntity)

    @Query("SELECT * FROM user_profile WHERE id = 'default' LIMIT 1")
    suspend fun getProfile(): UserProfileEntity?

    @Query("DELETE FROM user_profile")
    suspend fun deleteAll()
}

@Dao
interface SyncLogDao {
    @Insert
    suspend fun insert(log: SyncLogEntity)

    @Query("SELECT * FROM sync_log ORDER BY synced_at DESC LIMIT 1")
    suspend fun getLatest(): SyncLogEntity?
}

// MARK: - Database

@Database(
    entities = [
        CycleEntryEntity::class,
        SymptomLogEntity::class,
        InsightEntity::class,
        PredictionEntity::class,
        UserProfileEntity::class,
        SyncLogEntity::class
    ],
    version = 1,
    exportSchema = true
)
abstract class ShifAIDatabase : RoomDatabase() {
    abstract fun cycleEntryDao(): CycleEntryDao
    abstract fun symptomLogDao(): SymptomLogDao
    abstract fun insightDao(): InsightDao
    abstract fun predictionDao(): PredictionDao
    abstract fun userProfileDao(): UserProfileDao
    abstract fun syncLogDao(): SyncLogDao

    companion object {
        @Volatile
        private var INSTANCE: ShifAIDatabase? = null

        /**
         * Creates encrypted Room database using SQLCipher
         * @param context Application context
         * @param dbKey Derived database key from master key (32 bytes)
         */
        fun getDatabase(context: Context, dbKey: ByteArray): ShifAIDatabase {
            return INSTANCE ?: synchronized(this) {
                val passphrase = dbKey
                val factory = SupportFactory(passphrase)

                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    ShifAIDatabase::class.java,
                    "shifai_encrypted.db"
                )
                    .openHelperFactory(factory)
                    .fallbackToDestructiveMigration()
                    .build()

                INSTANCE = instance
                instance
            }
        }

        /**
         * GDPR Article 17 — Right to erasure
         * Wipes all user data from the database
         */
        suspend fun wipeAllData() {
            INSTANCE?.let { db ->
                db.clearAllTables()
            }
        }
    }
}
