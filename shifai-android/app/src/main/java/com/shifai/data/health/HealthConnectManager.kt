package com.shifai.data.health

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.MenstruationFlowRecord
import androidx.health.connect.client.records.MenstruationPeriodRecord
import androidx.health.connect.client.records.BasalBodyTemperatureRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

/**
 * Health Connect Manager — reads cycle data from Google Health Connect.
 * Mirrors iOS HealthKitManager.swift.
 */
class HealthConnectManager(private val context: Context) {

    private val client by lazy { HealthConnectClient.getOrCreate(context) }

    val permissions = setOf(
        HealthPermission.getReadPermission(MenstruationFlowRecord::class),
        HealthPermission.getReadPermission(MenstruationPeriodRecord::class),
        HealthPermission.getReadPermission(BasalBodyTemperatureRecord::class),
        HealthPermission.getWritePermission(MenstruationFlowRecord::class),
    )

    // ─── Availability ───

    val isAvailable: Boolean
        get() = HealthConnectClient.getSdkStatus(context) == HealthConnectClient.SDK_AVAILABLE

    // ─── Read Menstrual Data ───

    suspend fun fetchMenstrualFlow(startDate: LocalDate, endDate: LocalDate): List<MenstruationFlowRecord> {
        val request = ReadRecordsRequest(
            recordType = MenstruationFlowRecord::class,
            timeRangeFilter = TimeRangeFilter.between(
                startDate.atStartOfDay(ZoneId.systemDefault()).toInstant(),
                endDate.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant()
            )
        )
        val response = client.readRecords(request)
        return response.records
    }

    // ─── Write Period Data ───

    suspend fun saveMenstrualFlow(date: LocalDate, flow: Int) {
        val record = MenstruationFlowRecord(
            time = date.atStartOfDay(ZoneId.systemDefault()).toInstant(),
            zoneOffset = ZoneId.systemDefault().rules.getOffset(Instant.now()),
            flow = when (flow) {
                1 -> MenstruationFlowRecord.FLOW_LIGHT
                2 -> MenstruationFlowRecord.FLOW_MEDIUM
                3 -> MenstruationFlowRecord.FLOW_HEAVY
                else -> MenstruationFlowRecord.FLOW_UNKNOWN
            }
        )
        client.insertRecords(listOf(record))
    }

    // ─── Sync Import ───

    suspend fun importCycleData(onRecord: suspend (LocalDate, Int) -> Unit) {
        val sixMonthsAgo = LocalDate.now().minusMonths(6)
        val records = fetchMenstrualFlow(sixMonthsAgo, LocalDate.now())

        for (record in records) {
            val date = record.time.atZone(ZoneId.systemDefault()).toLocalDate()
            onRecord(date, record.flow)
        }
    }
}
