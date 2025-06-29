plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.oilab_frontend"
    compileSdk = 34  // Changed from 35 to 34 for stability
    ndkVersion = "25.1.8937393"  // Use more stable NDK version

    compileOptions {
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.oilab_frontend"
        minSdk = 21
        targetSdk = 34  // Match with compileSdk
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Remove debug signing for release builds
            minifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Suppress obsolete source/target warnings by setting Java toolchain
    java {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(11))
        }
    }

    // Add packaging options to avoid conflicts
    packagingOptions {
        pickFirst("**/libc++_shared.so")
        pickFirst("**/libjsc.so")
    }
}

flutter {
    source = "../.."
}

// Configure tasks globally
tasks.withType<JavaCompile> {
    options.release.set(11)
}

dependencies {
    // Firebase BOM for version management
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    
    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Add these common dependencies if needed
    implementation("androidx.lifecycle:lifecycle-process:2.6.2")
    implementation("androidx.startup:startup-runtime:1.1.1")
}