# ProGuard & R8 Optimization and Keep Rules for IronFlow

# Flutter Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Prevent R8 from removing Flutter JNI entrypoints
-keepclasseswithmembers class * {
    native <methods>;
}

# Keep Flutter generated plugins
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Hive & TypeAdapters
-keep class io.hive.** { *; }
-keep class * extends io.hive.TypeAdapter { *; }
-keepnames class * extends io.hive.TypeAdapter
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Desugaring
-dontwarn java.lang.invoke.**
-dontwarn java.time.**

# AndroidX & Kotlin
-keepattributes SourceFile,LineNumberTable
-dontwarn kotlin.**
-dontwarn androidx.**

