plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.devtools.ksp")
}

android {
    namespace = "com.shifai"
    compileSdk = rootProject.extra["compileSdk"] as Int

    defaultConfig {
        applicationId = "com.shifai.app"
        minSdk = rootProject.extra["minSdk"] as Int
        targetSdk = rootProject.extra["targetSdk"] as Int
        versionCode = 1
        versionName = "0.1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // Supabase config (from local.properties or CI secrets)
        buildConfigField("String", "SUPABASE_URL", "\"${project.findProperty("SUPABASE_URL") ?: ""}\"")
        buildConfigField("String", "SUPABASE_ANON_KEY", "\"${project.findProperty("SUPABASE_ANON_KEY") ?: ""}\"")
        buildConfigField("String", "SUPABASE_REGION", "\"eu-west-1\"") // EU ONLY
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }
}

dependencies {
    val composeVersion = rootProject.extra["composeVersion"]
    val roomVersion = rootProject.extra["roomVersion"]
    val lifecycleVersion = rootProject.extra["lifecycleVersion"]
    val navigationVersion = rootProject.extra["navigationVersion"]

    // ─── Core ───
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:$lifecycleVersion")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:$lifecycleVersion")
    implementation("androidx.activity:activity-compose:1.8.2")

    // ─── Compose UI ───
    implementation(platform("androidx.compose:compose-bom:2024.02.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.navigation:navigation-compose:$navigationVersion")

    // ─── Database: Room + SQLCipher ───
    implementation("androidx.room:room-runtime:$roomVersion")
    implementation("androidx.room:room-ktx:$roomVersion")
    ksp("androidx.room:room-compiler:$roomVersion")
    implementation("net.zetetic:android-database-sqlcipher:${rootProject.extra["sqlcipherVersion"]}")

    // ─── Security ───
    implementation("androidx.biometric:biometric:${rootProject.extra["biometricVersion"]}")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")

    // ─── ML: TensorFlow Lite ───
    implementation("org.tensorflow:tensorflow-lite:${rootProject.extra["tensorflowLiteVersion"]}")

    // ─── Network: Supabase ───
    implementation("io.github.jan-tennert.supabase:postgrest-kt:${rootProject.extra["supabaseVersion"]}")
    implementation("io.github.jan-tennert.supabase:gotrue-kt:${rootProject.extra["supabaseVersion"]}")
    implementation("io.github.jan-tennert.supabase:storage-kt:${rootProject.extra["supabaseVersion"]}")
    implementation("com.squareup.okhttp3:okhttp:${rootProject.extra["okHttpVersion"]}")

    // ─── Monitoring ───
    implementation("io.sentry:sentry-android:${rootProject.extra["sentryVersion"]}")

    // ─── Widgets: Glance ───
    implementation("androidx.glance:glance-appwidget:${rootProject.extra["glanceVersion"]}")
    implementation("androidx.glance:glance-material3:${rootProject.extra["glanceVersion"]}")

    // ─── WorkManager (background sync) ───
    implementation("androidx.work:work-runtime-ktx:2.9.0")

    // ─── Testing ───
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.10.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation(platform("androidx.compose:compose-bom:2024.02.00"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
