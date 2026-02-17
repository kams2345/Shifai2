package com.shifai.data.sync

import android.content.Context
import androidx.work.*
import java.util.concurrent.TimeUnit

/**
 * Background Sync Worker — periodic sync via WorkManager.
 * Runs every 6 hours with network constraint.
 * Mirrors iOS BGTaskScheduler pattern.
 */
class SyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            val container = com.shifai.di.AppContainer
            val syncManager = container.syncManager

            val result = syncManager.sync()
            result.fold(
                onSuccess = { report ->
                    android.util.Log.d("SyncWorker", "Synced: pushed=${report.pushed}, pulled=${report.pulled}")
                    Result.success()
                },
                onFailure = { error ->
                    android.util.Log.e("SyncWorker", "Sync failed: ${error.message}")
                    if (runAttemptCount < 3) Result.retry() else Result.failure()
                }
            )
        } catch (e: Exception) {
            android.util.Log.e("SyncWorker", "Worker error: ${e.message}")
            if (runAttemptCount < 3) Result.retry() else Result.failure()
        }
    }

    companion object {
        private const val WORK_NAME = "shifai_periodic_sync"

        /**
         * Schedule periodic sync every 6 hours.
         * Constraints: requires network, no battery low.
         */
        fun schedule(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresBatteryNotLow(true)
                .build()

            val request = PeriodicWorkRequestBuilder<SyncWorker>(
                6, TimeUnit.HOURS,
                30, TimeUnit.MINUTES  // flex interval
            )
                .setConstraints(constraints)
                .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 15, TimeUnit.MINUTES)
                .build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    WORK_NAME,
                    ExistingPeriodicWorkPolicy.KEEP,
                    request
                )
        }

        /**
         * Cancel periodic sync (e.g., when user disables sync).
         */
        fun cancel(context: Context) {
            WorkManager.getInstance(context)
                .cancelUniqueWork(WORK_NAME)
        }
    }
}
