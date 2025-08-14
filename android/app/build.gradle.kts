plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --- PASSO 1: Adicione este bloco para ler o arquivo de propriedades da chave ---
def keystorePropertiesFile = rootProject.file("../key.properties") // O arquivo está na raiz do projeto Flutter
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
// --------------------------------------------------------------------------

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    // --- PASSO 2: Adicione esta seção de signingConfigs ---
    // Ela define as configurações de assinatura que usaremos.
    signingConfigs {
        release {
            if (keystoreProperties.getProperty("storeFile") != null) {
                storeFile file(keystoreProperties.getProperty("storeFile"))
                storePassword keystoreProperties.getProperty("storePassword")
                keyAlias keystoreProperties.getProperty("keyAlias")
                keyPassword keystoreProperties.getProperty("keyPassword")
            }
        }
    }
    // -------------------------------------------------------

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --- PASSO 3: Modifique a sua seção buildTypes existente ---
    // Removemos o "TODO" e dizemos ao Gradle para usar a nossa nova configuração 'release'.
    buildTypes {
        release {
            // Signing with our release keys.
            signingConfig signingConfigs.release
        }
    }
    // ------------------------------------------------------------
}

flutter {
    source = "../.."
}