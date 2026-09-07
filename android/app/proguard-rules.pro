# R8 rules for the release build.
#
# google_mlkit_text_recognition's Android plugin references the optional
# Chinese / Devanagari / Japanese / Korean recogniser classes so a host app can
# opt into those scripts. FemFit ships only the bundled Latin model (ADR 012),
# so those classes are absent on purpose and R8 (full mode) reports them as
# "Missing class ..." errors during :app:minifyReleaseWithR8. Debug builds do
# not minify, which is why the debug smoke builds never showed this.
# Suppressing the warnings is the plugin's documented resolution; the Latin
# recogniser is unaffected.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep the recogniser option classes we DO ship so reflection-free
# initialisation stays intact after shrinking.
-keep class com.google.mlkit.vision.text.latin.** { *; }
