# ---------- Flutter runtime ----------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ---------- ML Kit text recognition ----------
# We ship only the Latin recognizer; keep it and silence unshipped script recognizers.
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ---------- flutter_local_notifications ----------
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }
-keep class * implements java.lang.reflect.Type { *; }
-keepattributes Signature, *Annotation*, InnerClasses, EnclosingMethod
-dontwarn com.google.gson.**

# ---------- flutter_secure_storage ----------
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ---------- local_auth ----------
-keep class androidx.biometric.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }

# ---------- sqflite ----------
-keep class com.tekartik.sqflite.** { *; }

# ---------- image_picker ----------
-keep class io.flutter.plugins.imagepicker.** { *; }

# ---------- Google Play Billing ----------
# The library ships consumer rules, but release builds now minify, and a
# stripped billing class means a paywall that can never complete a purchase.
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# ---------- Google Play Services (ML Kit dep) ----------
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ---------- Common: keep native method signatures & annotations ----------
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepattributes RuntimeVisibleAnnotations, RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations, RuntimeInvisibleParameterAnnotations
