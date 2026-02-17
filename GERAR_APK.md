# 📱 Gerar APK - RepFlow

## 🎯 Passo a Passo

### 1. Verificar Configurações do Android

Primeiro, vamos verificar se está tudo configurado:

```bash
flutter doctor
```

Deve mostrar:
- ✅ Flutter (Channel stable)
- ✅ Android toolchain
- ✅ Android Studio (opcional)

---

### 2. Configurar Nome e Ícone do App

#### Editar `android/app/src/main/AndroidManifest.xml`:

Procure por `android:label` e mude para:
```xml
android:label="RepFlow"
```

#### Adicionar ícone (opcional):
- Coloque um ícone em `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- Ou use o padrão do Flutter

---

### 3. Configurar Permissões de Internet

Verifique se `android/app/src/main/AndroidManifest.xml` tem:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

### 4. Gerar APK de Debug (Teste Rápido)

Para testar rapidamente:

```bash
flutter build apk --debug
```

O APK estará em:
```
build/app/outputs/flutter-apk/app-debug.apk
```

---

### 5. Gerar APK de Release (Produção)

#### Opção A: APK Universal (funciona em todos os dispositivos)

```bash
flutter build apk --release
```

O APK estará em:
```
build/app/outputs/flutter-apk/app-release.apk
```

#### Opção B: APKs Separados por Arquitetura (menor tamanho)

```bash
flutter build apk --split-per-abi --release
```

Gera 3 APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM - mais comum)
- `app-x86_64-release.apk` (Intel)

---

### 6. Gerar App Bundle (Para Google Play Store)

Se for publicar na Play Store:

```bash
flutter build appbundle --release
```

O arquivo estará em:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 🔐 Assinar o APK (Opcional mas Recomendado)

### Criar Keystore

```bash
keytool -genkey -v -keystore ~/repflow-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias repflow
```

Preencha as informações solicitadas.

### Configurar no Projeto

Crie `android/key.properties`:

```properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=repflow
storeFile=C:/caminho/para/repflow-key.jks
```

### Editar `android/app/build.gradle`

Adicione antes de `android {`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Dentro de `android {`, adicione:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

---

## 📦 Comandos Resumidos

### APK de Teste (Debug)
```bash
flutter build apk --debug
```

### APK de Produção (Release)
```bash
flutter build apk --release
```

### APK Otimizado (Menor tamanho)
```bash
flutter build apk --split-per-abi --release
```

### App Bundle (Play Store)
```bash
flutter build appbundle --release
```

---

## 📱 Instalar no Celular

### Via USB:

1. Ative "Depuração USB" no celular
2. Conecte o celular no PC
3. Execute:

```bash
flutter install
```

Ou instale o APK manualmente:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Via Arquivo:

1. Copie o APK para o celular
2. Abra o arquivo no celular
3. Permita instalação de fontes desconhecidas
4. Instale

---

## ⚙️ Configurações Importantes

### Versão do App

Edite `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- `1.0.0` = Versão visível (Major.Minor.Patch)
- `+1` = Build number (incrementar a cada build)

### Nome do Pacote

Em `android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId "com.seudominio.repflow"
    minSdkVersion 21
    targetSdkVersion 33
    versionCode 1
    versionName "1.0.0"
}
```

---

## 🐛 Problemas Comuns

### Erro: "Android SDK not found"
```bash
flutter config --android-sdk C:\Users\SEU_USUARIO\AppData\Local\Android\Sdk
```

### Erro: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### Erro: "Execution failed for task ':app:lintVitalRelease'"
Adicione em `android/app/build.gradle`:

```gradle
android {
    lintOptions {
        checkReleaseBuilds false
    }
}
```

---

## 📊 Tamanhos Esperados

- **Debug APK**: ~50-80 MB
- **Release APK**: ~20-40 MB
- **Split APK (arm64)**: ~15-25 MB
- **App Bundle**: ~15-30 MB

---

## ✅ Checklist Final

Antes de gerar o APK de produção:

- [ ] Testou todas as funcionalidades
- [ ] Configurou nome do app
- [ ] Configurou ícone (opcional)
- [ ] Configurou versão em `pubspec.yaml`
- [ ] Removeu prints de debug
- [ ] Testou em modo release: `flutter run --release`
- [ ] Gerou APK: `flutter build apk --release`
- [ ] Testou APK no celular
- [ ] Verificou permissões necessárias

---

## 🚀 Publicar na Play Store (Opcional)

1. Crie conta no Google Play Console
2. Pague taxa única de $25
3. Crie novo app
4. Faça upload do App Bundle (.aab)
5. Preencha informações (descrição, screenshots, etc)
6. Configure preço (grátis ou pago)
7. Envie para revisão

---

## 📝 Notas

- APK de debug é maior e mais lento
- APK de release é otimizado e menor
- App Bundle é o formato recomendado para Play Store
- Split APKs reduzem tamanho mas precisa escolher arquitetura certa

---

## 🎉 Pronto!

Execute:

```bash
flutter build apk --release
```

E seu APK estará em:
```
build/app/outputs/flutter-apk/app-release.apk
```

Copie para o celular e instale! 🚀
