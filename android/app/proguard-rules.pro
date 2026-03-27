-keepattributes Signature
-keepattributes *Annotation*

-keep class com.google.gson.reflect.TypeToken { *; }
-keep class com.google.gson.** { *; }

-keep class com.dexterous.flutterlocalnotifications.** { *; }

-keep class androidx.lifecycle.DefaultLifecycleObserver
-keep class androidx.lifecycle.** { *; }

-dontwarn com.google.gson.**