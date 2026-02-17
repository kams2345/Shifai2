// Top-level build file for ShifAI Android
// Configured per architecture.md specifications

plugins {
    id("com.android.application") version "8.3.0" apply false
    id("com.android.library") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "2.3.10" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.0" apply false
    id("com.google.devtools.ksp") version "2.0.0-1.0.21" apply false
}

// Dependency versions (centralized)
extra.apply {
    // Android
    set("minSdk", 26)           // Android 8.0
    set("targetSdk", 34)        // Android 14
    set("compileSdk", 34)

    // Kotlin
    set("kotlinVersion", "2.0.0")

    // AndroidX
    set("composeVersion", "1.6.0")
    set("roomVersion", "2.6.1")
    set("lifecycleVersion", "2.7.0")
    set("navigationVersion", "2.7.6")

    // Security
    set("sqlcipherVersion", "4.5.6")
    set("biometricVersion", "1.2.0-alpha05")

    // ML
    set("tensorflowLiteVersion", "2.14.0")

    // Network
    set("supabaseVersion", "2.3.0")
    set("okHttpVersion", "4.12.0")

    // Monitoring
    set("sentryVersion", "7.3.0")

    // Glance (Widgets)
    set("glanceVersion", "1.0.0")
}
