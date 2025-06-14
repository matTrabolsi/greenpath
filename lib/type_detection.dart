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
    }
  } catch (e) {
    // print("Failed to delete image in dispose(): $e");
  }
}


  Future<void> _loadLabels() async{
    try{
      final String jsonString = await rootBundle.loadString('assets/label_type_map.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _labelMap = jsonMap.map((key, value) => MapEntry(int.parse(key), Map<String, String>.from(value))); 

    } catch (e) {
      // print("failed to load label map: $e");
    }
  }

  Future<void> _loadModel() async {
        try {
      _interpreter = await Interpreter.fromAsset('assets/plant_type_model.tflite');
      _modelLoaded = true;

    } catch (e) {
      // print("Failed to load model: $e");
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

      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    
      var input = List.generate(1, (_) => List.generate(224, (y) => List.generate(224, (x) {
      var pixel = resizedImage.getPixel(x, y); 
      return [
        pixel.r / 255.0,
        pixel.g / 255.0,
        pixel.b / 255.0  
      ];
    })));

      var output = List.filled(11, 0.0).reshape([1, 11]);

      _interpreter.run(input, output);

      List<double> probabilities = List<double>.from(output[0]);
      int predictedIndex = 0;
      double maxProbability = probabilities[0];

      for (int i = 0; i < probabilities.length; i++) {
        double prob = probabilities[i];
        if (prob > maxProbability) {
          maxProbability = prob;
          predictedIndex = i;
        }
      }

      setState(() {
        _predictionResultDescription = _labelMap[predictedIndex]?['description']?? "Unknown";
        _predictionResultName = _labelMap[predictedIndex]?['name']?? "Unknown";
        _isLoading = false;
      });
      
      
    } catch (e) {
      // print("Error during model execution: $e");
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
       
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _image!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      height: 350,
                    ),
                  ),

                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
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
