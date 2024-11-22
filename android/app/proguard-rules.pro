# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Prevent obfuscation of methods used by Flutter plugins
-keep class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-keepclassmembers class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
}
-keep class j$.util.stream.Stream { *; }

# Keep Gson serialization and deserialization methods if you're using Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Workaround for Kotlin coroutines
-dontwarn kotlinx.coroutines.**

# Handle Java Streams compatibility (optional but recommended for modern Java versions)
-keep class j$.** { *; }

# Prevent stripping or obfuscating Play Integrity API
-keep class com.google.android.play.integrity.** { *; }

# Preserve classes and fields for reflection-based libraries
-keepattributes InnerClasses,EnclosingMethod

# Add other rules for any plugins or libraries you use

# sqflite - prevent obfuscation of SQLite-related classes and methods
-keep class io.flutter.plugins.sqlite.** { *; }

# provider - keep provider-related classes
-keep class androidx.lifecycle.** { *; }

# curved_navigation_bar - keep navigation bar related classes intact
-keep class com.github.** { *; }

# intl - keep classes related to date, number, and message formatting
-keep class com.ibm.icu.** { *; }

# day_night_switcher - keep related classes intact if necessary
-keep class com.github.** { *; }

# shared_preferences - keep SharedPreferences related classes
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# url_launcher - keep URL launching classes
-keep class io.flutter.plugins.urllauncher.** { *; }

# calendar_date_picker2 - keep related classes intact
-keep class com.applandeo.** { *; }

# flutter_localizations - keep localization classes intact
-keep class androidx.localedata.** { *; }

# flutter_native_splash - keep related classes
-keep class io.flutter.plugins.flutter_native_splash.** { *; }

# permission_handler - keep permission handling classes intact
-keep class com.github.permission_handler.** { *; }

# pull_to_refresh - keep related classes intact
-keep class com.github.** { *; }
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
