# Block Blast 打包APK指南

## 前置条件

1. 安装 Flutter SDK
2. 安装 Android SDK（设置 ANDROID_HOME 环境变量）
3. 安装 Android Studio（推荐）

## 打包步骤

### 1. 进入项目目录
```bash
cd projects/block-blast/app
```

### 2. 获取依赖
```bash
flutter pub get
```

### 3. 打包APK

**Release版本（推荐）：**
```bash
flutter build apk --release
```

**Debug版本（测试用）：**
```bash
flutter build apk --debug
```

### 4. APK位置

打包完成后，APK文件位于：
```
build/app/outputs/flutter-apk/app-release.apk
```

## 快速打包脚本

```bash
#!/bin/bash
cd /path/to/block-blast/app
flutter pub get
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk ../block-blast.apk
echo "APK已生成: block-blast.apk"
```

## 常见问题

### 1. No Android SDK found
```bash
# 设置 ANDROID_HOME
export ANDROID_HOME=/path/to/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### 2. Gradle构建失败
```bash
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### 3. 签名问题
正式发布需要配置签名，详见：
https://docs.flutter.dev/deployment/android
