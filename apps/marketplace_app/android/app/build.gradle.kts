import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The upload keystore is described by android/key.properties, which is never
// committed (see key.properties.example and docs/adr/0010-android-app-id-and-release-signing.md).
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

android {
    namespace = "com.leonardomolleker.marketplace"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.leonardomolleker.marketplace"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Only defined when key.properties exists, so debug builds work on a fresh clone.
        if (keyPropertiesFile.exists()) {
            create("release") {
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
                storeFile = keyProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = keyProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Never fall back to the debug key: a release signed with it cannot be
            // published or updated later. Without key.properties the release config
            // does not exist, so the signing config stays unset and the build is
            // stopped by the check below.
            if (keyPropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

// Failing at configuration time would break debug builds too, because Gradle
// configures the whole project whatever variant is requested. The task graph is
// known only after configuration, so we look there for a release task and fail
// only when one is actually going to run.
gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any { it.name.contains("Release") }
    if (buildsRelease && !keyPropertiesFile.exists()) {
        throw GradleException(
            "Release signing is not configured: create android/key.properties " +
                "(see android/key.properties.example and " +
                "docs/adr/0010-android-app-id-and-release-signing.md).",
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
