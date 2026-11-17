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

# Generic signature & annotation attributes for reflection/serialization
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



# Flutter Play Core deferred components (not used by IronFlow; emitted by R8 missing_rules.txt)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
