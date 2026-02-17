# ShifAI ProGuard Rules

# ─── Supabase / Ktor ───
-keep class io.github.jan.supabase.** { *; }
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**

# ─── Room ───
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-keepclassmembers class * { @androidx.room.* <methods>; }

# ─── SQLCipher ───
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# ─── TensorFlow Lite ───
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# ─── Glance Widgets ───
-keep class androidx.glance.** { *; }

# ─── Sentry ───
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# ─── App Models ───
-keep class com.shifai.domain.models.** { *; }
-keep class com.shifai.data.local.** { *; }

# ─── Compose ───
-dontwarn androidx.compose.**
-keep class androidx.compose.** { *; }

# ─── Serialization ───
-keepattributes *Annotation*
-keepclassmembers class * {
    @kotlinx.serialization.Serializable *;
}
