package com.shifai.data.local

import androidx.room.TypeConverter
import com.shifai.domain.models.*

/**
 * Room Type Converters — handle complex types in Room entities.
 * Registered in @Database annotation.
 */
class Converters {

    // ─── CyclePhase ───

    @TypeConverter
    fun fromCyclePhase(phase: CyclePhase?): String? = phase?.name

    @TypeConverter
    fun toCyclePhase(value: String?): CyclePhase? =
        value?.let { CyclePhase.valueOf(it) }

    // ─── SymptomCategory ───

    @TypeConverter
    fun fromSymptomCategory(category: SymptomCategory?): String? = category?.name

    @TypeConverter
    fun toSymptomCategory(value: String?): SymptomCategory? =
        value?.let { SymptomCategory.valueOf(it) }

    // ─── BodyZone ───

    @TypeConverter
    fun fromBodyZone(zone: BodyZone?): String? = zone?.name

    @TypeConverter
    fun toBodyZone(value: String?): BodyZone? =
        value?.let { BodyZone.valueOf(it) }

    // ─── PainType ───

    @TypeConverter
    fun fromPainType(type: PainType?): String? = type?.name

    @TypeConverter
    fun toPainType(value: String?): PainType? =
        value?.let { PainType.valueOf(it) }

    // ─── InsightType ───

    @TypeConverter
    fun fromInsightType(type: InsightType?): String? = type?.name

    @TypeConverter
    fun toInsightType(value: String?): InsightType? =
        value?.let { InsightType.valueOf(it) }

    // ─── PredictionType ───

    @TypeConverter
    fun fromPredictionType(type: PredictionType?): String? = type?.name

    @TypeConverter
    fun toPredictionType(value: String?): PredictionType? =
        value?.let { PredictionType.valueOf(it) }

    // ─── SyncStatus ───

    @TypeConverter
    fun fromSyncStatus(status: SyncStatus?): String? = status?.name

    @TypeConverter
    fun toSyncStatus(value: String?): SyncStatus? =
        value?.let { SyncStatus.valueOf(it) }

    // ─── CycleType ───

    @TypeConverter
    fun fromCycleType(type: CycleType?): String? = type?.name

    @TypeConverter
    fun toCycleType(value: String?): CycleType? =
        value?.let { CycleType.valueOf(it) }

    // ─── List<String> ───

    @TypeConverter
    fun fromStringList(list: List<String>?): String? =
        list?.joinToString(",")

    @TypeConverter
    fun toStringList(value: String?): List<String>? =
        value?.split(",")?.filter { it.isNotEmpty() }

    // ─── List<Condition> ───

    @TypeConverter
    fun fromConditionList(list: List<Condition>?): String? =
        list?.joinToString(",") { it.name }

    @TypeConverter
    fun toConditionList(value: String?): List<Condition>? =
        value?.split(",")?.filter { it.isNotEmpty() }?.map { Condition.valueOf(it) }
}
