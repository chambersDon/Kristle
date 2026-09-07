import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials come from a local, gitignored android/key.properties file (see
// android/key.properties.example) on developer machines, or from environment variables supplied
// as CI secrets when no such file exists. Neither path ever hardcodes a keystore path or
// password in this file.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun signingProperty(propertiesKey: String, envVar: String): String =
    (keystoreProperties.getProperty(propertiesKey) ?: System.getenv(envVar))
        ?: throw GradleException(
            "Missing release signing value: set '$propertiesKey' in android/key.properties " +
                "(see android/key.properties.example) or export $envVar."
        )

android {
    namespace = "com.rebustechnologies.kristle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = signingProperty("keyAlias", "ANDROID_KEY_ALIAS")
            keyPassword = signingProperty("keyPassword", "ANDROID_KEY_PASSWORD")
            storeFile = file(signingProperty("storeFile", "ANDROID_KEYSTORE_PATH"))
            storePassword = signingProperty("storePassword", "ANDROID_KEYSTORE_PASSWORD")
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rebustechnologies.kristle"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
