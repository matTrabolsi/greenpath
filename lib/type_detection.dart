import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greengath/chatbot.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


class TypeDetection extends StatefulWidget {
  final File imageFile;
  const TypeDetection({super.key, required this.imageFile});

  @override
  State<TypeDetection> createState() => _TypeDetection();
}

class _TypeDetection extends State<TypeDetection> {
  bool _isLoading = true;
  File? _image;
  String? _predictionResultDescription;
  String? _predictionResultName;
  late Interpreter _interpreter;
  bool _modelLoaded = false;
  Map<int, Map<String, String>> _labelMap = {};

  @override
  void initState() {
    super.initState();
    _loadLabels().then((_) {
      _loadModel().then((_) {
        if (_modelLoaded) {
          setState(() {
            _image = widget.imageFile;
          });
          _runModelOnImage(widget.imageFile);
        }
      });
    });
  }

  @override
void dispose() {
  _deleteTempImage();
  super.dispose();
}

Future<void> _deleteTempImage() async {
  try {
    if (widget.imageFile.existsSync()) {
      await widget.imageFile.delete();
      print("🗑️ Temp image file deleted in dispose().");
    }
  } catch (e) {
    print("⚠️ Failed to delete image in dispose(): $e");
  }
}


  Future<void> _loadLabels() async{
    try{
      final String jsonString = await rootBundle.loadString('assets/label_type_map.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _labelMap = jsonMap.map((key, value) => MapEntry(int.parse(key), Map<String, String>.from(value))); 
      print("label map loaded.");
    } catch (e) {
      print("failed to load label map: $e");
    }
  }

  Future<void> _loadModel() async {
        try {
      _interpreter = await Interpreter.fromAsset('assets/plant_type_model.tflite');
      _modelLoaded = true;
      print("✅ Model loaded successfully.");
    } catch (e) {
      print("❌ Failed to load model: $e");
    }

  }

  Future<void> _runModelOnImage(File imageFile) async {
    try {
      final rawBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(rawBytes);

      if (image == null) {
        setState(() {
          _predictionResultName = "Failed to decode image.";
        });
        return;
      }

      // Resize to 100x100
      img.Image resizedImage = img.copyResize(image, width: 100, height: 100);

      // Normalize pixel values and prepare input
      var input = List.generate(1, (_) => List.generate(100, (y) => List.generate(100, (x) {
      var pixel = resizedImage.getPixel(x, y); // This is a PixelUint8, not an int
      return [
        pixel.r / 255.0, // Red component normalized
        pixel.g / 255.0, // Green component normalized
        pixel.b / 255.0  // Blue component normalized
      ];
    })));


      // Output: 10 classes
      var output = List.filled(11, 0.0).reshape([1, 11]);

      // Run inference
      _interpreter.run(input, output);

      // Get predicted index
      List<double> probabilities = List<double>.from(output[0]);
      // Find the max probability and its index
      int predictedIndex = 0;
      double maxProbability = probabilities[0];

      for (int i = 0; i < probabilities.length; i++) {
        double prob = probabilities[i];
        // print('Class $i: ${_labelMap[i]?['name'] ?? 'Unknown'} → Confidence: ${prob.toStringAsFixed(4)}');

        if (prob > maxProbability) {
          maxProbability = prob;
          predictedIndex = i;
        }
      }


      // If confidence is too low, assign index 11 (e.g., Unknown)
      // if (maxProbability < 0.75) {
      //   print("⚠️ Low confidence! Assigning index 10 for unknown.");
      //   predictedIndex = 10;
      // }

      setState(() {
        _predictionResultDescription = _labelMap[predictedIndex]?['description']?? "Unknown";
        _predictionResultName = _labelMap[predictedIndex]?['name']?? "Unknown";
        _isLoading = false;
      });
      
      
    } catch (e) {
      print("Error during model execution: $e");
      setState(() {
        _predictionResultName = "Model execution failed.";
         _isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plant Type Detection"), backgroundColor: Colors.grey.shade100,),
      
body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  // Full-width image with rounded corners ONLY on image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _image!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      height: 350,
                    ),
                  ),

                  // Bottom-center result name on top of image
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _predictionResultName ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 18,

                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _predictionResultDescription ?? "",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 88, 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatBotPage(
                        initialMessage: _predictionResultName ?? "Unknown", // or combine with description if needed
                      ),
                    ),
                  );
                },

                  child: const Text(
                    "Talk to Chatbot",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

    );
  }
}
