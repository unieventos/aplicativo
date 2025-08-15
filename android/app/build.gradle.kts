import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Lê o arquivo de propriedades da chave
val keystorePropertiesFile = rootProject.file("../key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Versão do NDK atualizada

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    signingConfigs {
        create("release") {
            // Caminho relativo a partir da raiz do projeto
            val keystorePath = "${'$'}{project.rootDir}/../unieventos-release-key.jks"
            val keystoreFile = file(keystorePath)
            
            if (keystoreFile.exists()) {
                storeFile = keystoreFile
                storePassword = "unieventos"
                keyAlias = "unieventos"
                keyPassword = "unieventos"
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
                println("✅ Keystore encontrado em: ${'$'}{keystoreFile.absolutePath}")
            } else {
                // Se não encontrar o keystore, desabilita a assinatura
                println("⚠️  AVISO: Usando configuração de debug para release (não recomendado para produção)")
                initWith(signingConfigs.getByName("debug"))
            }
        }
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode?.toInt() ?: 1
        versionName = flutter.versionName ?: "1.0"
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