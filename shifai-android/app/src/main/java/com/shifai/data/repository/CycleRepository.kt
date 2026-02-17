package com.shifai.data.repository

import com.shifai.data.local.CycleEntryDao
import com.shifai.data.local.CycleEntryEntity
import com.shifai.data.local.SymptomLogDao
import com.shifai.data.local.SymptomLogEntity
import com.shifai.data.network.SupabaseClient
import com.shifai.domain.models.CyclePhase
import kotlinx.coroutines.flow.Flow
import java.time.LocalDate

/**
 * Cycle Repository — single source of truth for cycle data.
 * Offline-first: write to Room first, sync to Supabase later.
 */
class CycleRepository(
    private val cycleDao: CycleEntryDao,
    private val symptomDao: SymptomLogDao,
    private val supabaseClient: SupabaseClient
) {

    // ─── Observe ───

    fun observeEntries(): Flow<List<CycleEntryEntity>> = cycleDao.observeAll()

    // ─── Read ───

    suspend fun getEntryByDate(date: LocalDate): CycleEntryEntity? =
        cycleDao.getByDate(date)

    suspend fun getRecentEntries(count: Int = 30): List<CycleEntryEntity> =
        cycleDao.getRecent(count)

    suspend fun getDateRange(start: LocalDate, end: LocalDate): List<CycleEntryEntity> =
        cycleDao.getRange(start, end)

    suspend fun getSymptomsForEntry(entryId: String): List<SymptomLogEntity> =
        symptomDao.getByEntry(entryId)

    // ─── Write ───

    suspend fun saveEntry(entry: CycleEntryEntity) {
        cycleDao.upsert(entry.copy(isSynced = false))
    }

    suspend fun saveSymptom(symptom: SymptomLogEntity) {
        symptomDao.upsert(symptom.copy(isSynced = false))
    }

    suspend fun deleteSymptom(symptom: SymptomLogEntity) {
        symptomDao.delete(symptom)
    }

    // ─── Sync ───

    suspend fun getUnsyncedEntries(): List<CycleEntryEntity> =
        cycleDao.getUnsynced()

    suspend fun getUnsyncedSymptoms(): List<SymptomLogEntity> =
        symptomDao.getUnsynced()

    suspend fun markEntriesSynced(ids: List<String>) {
        cycleDao.markSynced(ids)
    }

    suspend fun markSymptomsSynced(ids: List<String>) {
        symptomDao.markSynced(ids)
    }

    // ─── Stats ───

    suspend fun entryCount(): Int = cycleDao.count()

    suspend fun symptomCount(): Int = symptomDao.count()

    // ─── Danger Zone ───

    suspend fun deleteAllData() {
        cycleDao.deleteAll()
        // Symptoms cascade via foreign key
    }
}
