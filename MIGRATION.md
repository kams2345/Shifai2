# Database Migrations — ShifAI

## Schema Versioning

Both platforms use versioned migrations for schema changes.

| Version | Change | Date |
|---------|--------|------|
| 1 | Initial schema: cycle_entries, symptom_logs | Launch |
| 2 | Add insights table | Sprint 12 |
| 3 | Add predictions table | Sprint 15 |
| 4 | Add sync_status columns to all tables | Sprint 20 |

## iOS (GRDB)

```swift
// DatabaseManager.swift
var migrator = DatabaseMigrator()

migrator.registerMigration("v1") { db in
    try db.create(table: "cycle_entries") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("date", .date).notNull().unique()
        t.column("phase", .text).notNull()
        t.column("flowIntensity", .integer).notNull().defaults(to: 0)
        t.column("mood", .integer)
        t.column("energy", .integer)
        t.column("sleep", .double)
        t.column("stress", .integer)
        t.column("notes", .text)
    }
}

migrator.registerMigration("v2") { db in
    try db.create(table: "insights") { ... }
}

migrator.registerMigration("v3") { db in
    try db.create(table: "predictions") { ... }
}

migrator.registerMigration("v4") { db in
    try db.alter(table: "cycle_entries") { t in
        t.add(column: "syncStatus", .text).defaults(to: "pending")
        t.add(column: "lastSyncedAt", .date)
    }
}
```

## Android (Room)

```kotlin
// AppDatabase.kt
@Database(
    entities = [CycleEntryEntity::class, SymptomLogEntity::class, 
                InsightEntity::class, PredictionEntity::class],
    version = 4,
    exportSchema = true
)
abstract class AppDatabase : RoomDatabase()

val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("CREATE TABLE IF NOT EXISTS insights (...)")
    }
}

val MIGRATION_2_3 = object : Migration(2, 3) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("CREATE TABLE IF NOT EXISTS predictions (...)")
    }
}

val MIGRATION_3_4 = object : Migration(3, 4) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("ALTER TABLE cycle_entries ADD COLUMN sync_status TEXT DEFAULT 'pending'")
        db.execSQL("ALTER TABLE cycle_entries ADD COLUMN last_synced_at INTEGER")
    }
}
```

## Migration Rules

1. **Never delete columns** — mark as deprecated instead
2. **Always provide default values** for new columns
3. **Test migrations** on pre-populated databases
4. **Export Room schemas** for CI validation (`exportSchema = true`)
5. **GRDB migrations are sequential** — never skip a version
