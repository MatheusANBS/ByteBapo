# Android APK Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure and document signed Android APK releases using local keystore properties.

**Architecture:** Gradle reads `android/key.properties` for release signing; docs explain keystore creation, versioning, and APK build commands.

**Tech Stack:** Flutter Android, Gradle Kotlin DSL, keytool.

---

## File Structure

- Modify: `android/app/build.gradle.kts`
- Modify: `.gitignore`
- Add: `android/key.properties.example`
- Add: `docs/RELEASE_ANDROID.md`
- Modify: `docs/TECHNICAL.md`

### Task 1: Configure Release Signing

**Files:**
- Modify: `android/app/build.gradle.kts`
- Add: `android/key.properties.example`
- Modify: `.gitignore`

- [ ] Add property loading at the top of `build.gradle.kts`.

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

- [ ] Add release signing config and use it in `release`.

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

- [ ] Add example properties.

```properties
storePassword=change-me
keyPassword=change-me
keyAlias=bytepapo
storeFile=../bytepapo-release.jks
```

- [ ] Ignore secrets.

```gitignore
android/key.properties
*.jks
*.keystore
```

- [ ] Commit.

```powershell
git add android/app/build.gradle.kts android/key.properties.example .gitignore
git commit -m "build: configure android release signing"
```

### Task 2: Document APK Release

**Files:**
- Add: `docs/RELEASE_ANDROID.md`
- Modify: `docs/TECHNICAL.md`

- [ ] Create release docs with keystore, versioning, and build commands.

```powershell
keytool -genkey -v -keystore android/bytepapo-release.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias bytepapo
flutter build apk --release
```

- [ ] Document version policy.

```yaml
version: MAJOR.MINOR.PATCH+BUILD
```

- [ ] Add link from `docs/TECHNICAL.md`.

- [ ] Validate docs and Gradle syntax.

```powershell
flutter build apk --release
```

Expected: with real `android/key.properties`, APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.

- [ ] Commit.

```powershell
git add docs/RELEASE_ANDROID.md docs/TECHNICAL.md
git commit -m "docs: add android apk release process"
```
