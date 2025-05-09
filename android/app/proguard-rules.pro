# Keep TensorFlow Lite GPU delegate classes (as suggested by missing_rules.txt)
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# Also keep other TensorFlow Lite GPU classes if necessary
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
