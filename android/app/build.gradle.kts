plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // Flutter plugin must come last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.semproject"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Fix NDK error

    defaultConfig {
        applicationId = "com.example.semproject"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ Enable desugaring
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // ✅ Required for Java 8+ features
}
