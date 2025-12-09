# Add these lines to keep the classes of the libraries you use
-keep class com.itextpdf.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.** { *; }
-keep class androidx.** { *; }
-keep class org.apache.commons.** { *; }
-keep class com.example.myapp.** { *; }
-keep class com.razorpay.** { *; }
-keep class com.razorpay.**$ { *; }
-dontwarn io.flutter.embedding.*
-ignorewarnings

# Google Sign-In ProGuard rules
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.api.client.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions


