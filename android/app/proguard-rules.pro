# R8 / ProGuard — release (Java/Kotlin + resources). Dart AOT está em libapp.so;
# use também: flutter build apk --obfuscate --split-debug-info=...

# Preserve line numbers em stack traces (útil para crash reports com mapping upload).
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Flutter embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Plugins que usam reflexão / JNI costumam declarar consumer rules nos AARs;
# estas linhas evitam warnings comuns em apps Kotlin + coroutines.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn edu.umd.cs.findbugs.annotations.SuppressFBWarnings

# Kotlin metadata (reflection / serialization de libs)
-keep class kotlin.Metadata { *; }
