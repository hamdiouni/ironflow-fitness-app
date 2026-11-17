import java.io.FileInputStream
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Decode --dart-define and --dart-define-from-file entries (config/dev.json,
// config/staging.json, config/production.json) so Android manifest labels,
// icon variants, and optional flavor applicationIdSuffix stay synchronized
// with the Dart FlavorConfig while keeping `flutter build apk --debug`
// working out of the box.
val dartDefineMap = mutableMapOf<String, String>()
if (project.hasProperty("dart-defines")) {
    val rawDefines = project.property("dart-defines").toString()
    rawDefines.split(",").filter { it.isNotBlank() }.forEach { encoded ->
        try {
            val decoded = String(Base64.getDecoder().decode(encoded), Charsets.UTF_8)
            val idx = decoded.indexOf('=')
            if (idx > 0) {
                dartDefineMap[decoded.substring(0, idx)] = decoded.substring(idx + 1)
            }
        } catch (_: Exception) {}
    }
}
val activeFlavor = dartDefineMap["FLAVOR"]?.lowercase() ?: "production"
val activeAppName = dartDefineMap["APP_NAME"]?.takeIf { it.isNotBlank() } ?: "IronFlow"
val requestedIdSuffix = dartDefineMap["APP_ID_SUFFIX"] ?: ""
val hasFlavorGoogleServices = activeFlavor != "production" &&
    project.file("src/$activeFlavor/google-services.json").exists()

// Release signing is provided outside git via android/key.properties
// (storeFile/keyAlias/keyPassword/storePassword). CI should materialize
// that file from secrets for store builds. When it is absent, local
// release runs fall back to debug signing so `flutter run --release`
// still works on a developer machine; store uploads must use the real
// key.properties-backed config.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val hasReleaseSigning = listOf("storeFile", "keyAlias", "keyPassword", "storePassword")
    .all { !keystoreProperties.getProperty(it).isNullOrBlank() }

android {
    namespace = "com.progressiontracker.progression_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.progressiontracker.progression_tracker"
        if (hasFlavorGoogleServices && requestedIdSuffix.isNotBlank()) {
            applicationIdSuffix = requestedIdSuffix
        }
        resValue("string", "app_name", activeAppName)
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val allowUnsignedRelease =
        (project.findProperty("allowUnsignedRelease")?.toString()?.toBoolean() == true) ||
        (System.getenv("ALLOW_UNSIGNED_RELEASE")?.equals("true", ignoreCase = true) == true) ||
        (dartDefineMap["ALLOW_UNSIGNED_RELEASE"]?.equals("true", ignoreCase = true) == true)
    val isReleaseTaskRequested = gradle.startParameter.taskNames.any { taskName ->
        taskName.contains("Release", ignoreCase = true)
    }
    if (isReleaseTaskRequested && !hasReleaseSigning && !allowUnsignedRelease) {
        throw GradleException(
            "Release build requires android/key.properties (storeFile, storePassword, keyAlias, keyPassword). " +
            "For keyless CI/local R8 verification builds, set ALLOW_UNSIGNED_RELEASE=true or pass --dart-define=ALLOW_UNSIGNED_RELEASE=true."
        )
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Only reachable when ALLOW_UNSIGNED_RELEASE=true is explicitly set for R8 verification.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
