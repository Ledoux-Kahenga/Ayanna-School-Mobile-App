# Keep AndroidX classes
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# Keep startup classes specifically
-keep class androidx.startup.** { *; }
-keep interface androidx.startup.** { *; }

# Keep class members used by reflection
-keepclassmembers class * {
    @androidx.startup.Initializer *;
}

# Prevent stripping of initialization provider
-keep class androidx.startup.InitializationProvider { *; }

# Keep all classes that extend ContentProvider
-keep class * extends android.content.ContentProvider { *; }

# Keep Flutter plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep MultiDex
-keep class androidx.multidex.** { *; }
-dontwarn androidx.multidex.**

# Keep application class
-keep class com.example.ayanna_school.MainApplication { *; }