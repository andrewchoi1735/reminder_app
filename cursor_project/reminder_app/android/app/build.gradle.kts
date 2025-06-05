plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin은 Android/Kotlin 플러그인 이후에 적용
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.reminder_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.reminder_app"
        minSdk = 26 // ✅ 삼성 헬스 SDK 요구사항
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ JDK8+ 기능 사용 허용
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // TODO: 실제 릴리즈 키로 교체
        }
    }

    // ✅ AAR 수동 추가 시, flatDir 지정은 여기 아님! 아래 dependencies → repositories로 빼야 함
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ JDK 라이브러리 desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // ✅ Firebase BoM 및 SDK (필요 시만)
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-analytics")


}

// ✅ 플러그인 밖에 명시: AAR 파일 경로 인식용
repositories {
    google()
    mavenCentral()
    flatDir {
        dirs("../libs") // 📌 AAR 경로를 정확하게 명시
    }
}
