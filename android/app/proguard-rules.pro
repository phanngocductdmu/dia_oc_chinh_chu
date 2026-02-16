# ML Kit Text Recognition - Keep all language recognizer classes
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# Firebase MLKit Common
-keep class com.google.mlkit.common.model.DownloadConditions { *; }
-keep class com.google.mlkit.common.model.RemoteModel { *; }
-keep class com.google.mlkit.common.sdkinternal.** { *; }
-keep class com.google.mlkit.common.internal.** { *; }
