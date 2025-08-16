plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") 
}

android {
    namespace = "com.example.wise_workout_app"
    compileSdk = flutter.compileSdkVersion

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            storeFile = file("wiseworkout.jks")
            storePassword = "wiseworkoutpass"
            keyAlias = "wiseworkout"
            keyPassword = "wiseworkoutpass"
        }
    }

    defaultConfig {
        applicationId = "com.example.wise_workout_app"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue("string", "default_web_client_id", "723848267249-o0045ev3rv760lifvak38eaionfv1qlm.apps.googleusercontent.com")
        resValue("string", "facebook_app_id", "1707909883492321")
        resValue("string", "facebook_client_token", "bd9cab71b7816705bf6313f3f073925d")

        manifestPlaceholders["facebookAppId"] = "1707909883492321"
        manifestPlaceholders["facebookClientToken"] = "bd9cab71b7816705bf6313f3f073925d"
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}


