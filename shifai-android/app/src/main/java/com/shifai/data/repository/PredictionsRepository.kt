package com.shifai.data.repository

import com.shifai.data.local.PredictionDao
import com.shifai.data.local.PredictionEntity
import kotlinx.coroutines.flow.Flow
import java.time.LocalDate

/**
 * Predictions Repository — manages prediction CRUD and verification.
 * Offline-first, same pattern as CycleRepository.
 */
class PredictionsRepository(
    private val predictionDao: PredictionDao
) {

    // ─── Observe ───

    fun observeUpcoming(): Flow<List<PredictionEntity>> =
        predictionDao.observeUpcoming(LocalDate.now())

    // ─── Read ───

    suspend fun getNextPrediction(type: String): PredictionEntity? =
        predictionDao.getNext(type, LocalDate.now())

    suspend fun getVerified(limit: Int = 10): List<PredictionEntity> =
        predictionDao.getVerified(limit)

    // ─── Write ───

    suspend fun save(prediction: PredictionEntity) {
        predictionDao.upsert(prediction.copy(isSynced = false))
    }

    suspend fun verify(id: String, actualDate: LocalDate) {
        predictionDao.verify(id, actualDate)
    }

    // ─── Sync ───

    suspend fun getUnsynced(): List<PredictionEntity> =
        predictionDao.getUnsynced()

    suspend fun markSynced(ids: List<String>) {
        predictionDao.markSynced(ids)
    }

    // ─── Analytics ───

    suspend fun averageAccuracy(type: String): Double? {
        val verified = predictionDao.getVerifiedByType(type)
        if (verified.isEmpty()) return null

        val totalDays = verified.mapNotNull { entity ->
            entity.actualDate?.let { actual ->
                kotlin.math.abs(
                    java.time.temporal.ChronoUnit.DAYS.between(entity.predictedDate, actual).toInt()
                )
            }
        }
        return if (totalDays.isNotEmpty()) totalDays.average() else null
    }
}
