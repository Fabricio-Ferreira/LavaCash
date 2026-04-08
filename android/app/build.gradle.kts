import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystoreFile: Boolean =
    keystorePropertiesFile.exists().also { exists: Boolean ->
        if (exists) {
            keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
        }
    }

val releaseStorePassword: String =
    System.getenv("LAVACASH_STORE_PASSWORD")
        ?: (keystoreProperties["storePassword"] as String? ?: "")
val releaseKeyPassword: String =
    System.getenv("LAVACASH_KEY_PASSWORD")
        ?: (keystoreProperties["keyPassword"] as String? ?: "")

fun isUnsetOrPlaceholderPassword(raw: String): Boolean {
    val t = raw.trim()
    return t.isEmpty() || t.equals("CHANGE_ME", ignoreCase = true)
}

val releaseJks: java.io.File? =
    if (hasReleaseKeystoreFile) {
        val path = (keystoreProperties["storeFile"] as String?)?.trim()
        if (path.isNullOrEmpty()) {
            null
        } else {
            rootProject.file(path)
        }
    } else {
        null
    }

val hasValidReleaseSigning: Boolean =
    hasReleaseKeystoreFile &&
        releaseJks != null &&
        releaseJks.exists() &&
        !isUnsetOrPlaceholderPassword(releaseStorePassword) &&
        !isUnsetOrPlaceholderPassword(releaseKeyPassword)

if (hasReleaseKeystoreFile && !hasValidReleaseSigning) {
    logger.warn(
        "LavaCash: assinatura de release indisponível (senhas em falta, CHANGE_ME, ou " +
            ".jks ausente). O build release usará o keystore de debug. " +
            "Preenche android/key.properties ou exporta LAVACASH_STORE_PASSWORD e " +
            "LAVACASH_KEY_PASSWORD.",
    )
}

android {
    namespace = "com.lavacash.app.lava_cash"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    signingConfigs {
        if (hasValidReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")!!
                keyPassword = releaseKeyPassword
                storeFile = releaseJks!!
                storePassword = releaseStorePassword
            }
        }
    }

    defaultConfig {
        applicationId = "com.lavacash.app.lava_cash"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            signingConfig =
                signingConfigs.getByName(
                    if (hasValidReleaseSigning) "release" else "debug",
                )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
