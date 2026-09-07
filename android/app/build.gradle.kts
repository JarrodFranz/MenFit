import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (knowledge/engineering/release_and_distribution.md).
//
// `android/key.properties` is gitignored and written once by
// `scripts/create_upload_keystore.ps1`. It names the upload keystore and its
// passwords. Every tester-facing build MUST be signed with that one key:
// Android refuses to update an installed app whose signer changed, and a
// tester who has to uninstall loses their locally stored health data.
//
// When the file is absent (fresh clone, CI without the secret) release builds
// fall back to the debug key so `flutter run --release` still works, and the
// build prints a warning so the fallback is never silent.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.jarrodfranz.menfit"
    // permission_handler_android requires compileSdk 37, and the SDK
    // manager installs API 37 under Android's new *minor* versioning as
    // `platforms/android-37.0` (source.properties says ApiLevel=37.0).
    // AGP resolves the platform by the hash string `android-37`, so a plain
    // `compileSdk = 37` fails with "Failed to find target with hash string
    // 'android-37'". `compileSdkMinor` is how AGP 9 addresses a minor
    // platform version; together these resolve `android-37.0`.
    compileSdk = 37
    compileSdkMinor = 0
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Permanent application id (decided 2026-09-05). Registered in
        // Firebase and matches the iOS bundle id; never change it - installed
        // testers and store listings are keyed on it.
        applicationId = "com.jarrodfranz.menfit"
        // You can update the following values to match your application needs.
        // Health Connect requires minSdk 26
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "WARNING: android/key.properties not found - release build " +
                        "is DEBUG-SIGNED and must not be distributed to testers. " +
                        "Run scripts/create_upload_keystore.ps1 once.",
                )
                signingConfig = signingConfigs.getByName("debug")
            }
            // R8 runs on release builds. The rules file suppresses "Missing
            // class" errors for ML Kit's optional non-Latin recognisers, which
            // MenFit deliberately does not bundle (ADR 012) - without it
            // :app:minifyReleaseWithR8 fails while debug builds pass.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
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
