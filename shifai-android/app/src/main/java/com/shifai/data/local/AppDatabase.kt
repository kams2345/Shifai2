package com.shifai.data.local

import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import android.content.Context
import net.sqlcipher.database.SupportFactory

/**
 * ShifAI Room Database — encrypted with SQLCipher.
 * All entities stored locally with offline-first architecture.
 */
@Database(
    entities = [
        CycleEntryEntity::class,
        SymptomLogEntity::class,
        InsightEntity::class,
        PredictionEntity::class,
        SyncLogEntity::class
    ],
    version = 1,
    exportSchema = true
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {

    abstract fun cycleEntryDao(): CycleEntryDao
    abstract fun symptomLogDao(): SymptomLogDao
    abstract fun insightDao(): InsightDao
    abstract fun predictionDao(): PredictionDao
    abstract fun syncLogDao(): SyncLogDao

    companion object {
        private const val DATABASE_NAME = "shifai.db"

        @Volatile
        private var INSTANCE: AppDatabase? = null

        /**
         * Get encrypted database instance.
         * Uses SQLCipher with key from Android Keystore.
         */
        fun getInstance(context: Context, passphrase: ByteArray): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: buildDatabase(context, passphrase).also { INSTANCE = it }
            }
        }

        private fun buildDatabase(context: Context, passphrase: ByteArray): AppDatabase {
            val factory = SupportFactory(passphrase)
            return Room.databaseBuilder(
                context.applicationContext,
                AppDatabase::class.java,
                DATABASE_NAME
            )
                .openHelperFactory(factory)
                .fallbackToDestructiveMigration()
                .build()
        }

        /**
         * In-memory database for testing (no encryption).
         */
        fun getTestInstance(context: Context): AppDatabase {
            return Room.inMemoryDatabaseBuilder(
                context.applicationContext,
                AppDatabase::class.java
            )
                .allowMainThreadQueries()
                .build()
        }
    }
}
