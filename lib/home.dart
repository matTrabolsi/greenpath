import 'package:flutter/material.dart';
import 'package:greengath/disease_detection.dart';
import 'package:greengath/noti_service.dart';
import 'package:greengath/reminder_list.dart';
import 'package:greengath/type_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:greengath/chatbot.dart'; // update path if needed


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;

Future<void> _pickImageAndNavigate(
    BuildContext context, Widget Function(File) pageBuilder) async {
  setState(() => _isLoading = true);

  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    // Wait for 1 second before navigating (simulate processing)
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    Navigator.push(
      context,
      PageRouteBuilder(

        pageBuilder: (_, __, ___) => pageBuilder(File(pickedFile.path)),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  } else {
    setState(() => _isLoading = false);
    print("No image selected.");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Green Path',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 25, 15, 25),
                  height: 130,
                  
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: Container(
                            decoration: 
                            BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
            
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300]!,
                                  offset: const Offset(4, 4),
                                  blurRadius: 15,
                                  spreadRadius: 0.5,
                                ),
                                BoxShadow(
                                  color: Colors.grey[200]!,
                                  offset: const Offset(-4, -4),
                                  blurRadius: 10,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                      child:Material(
                        color: Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReminderListPage()),
                          );
                        },
                        child: Ink.image(
                          image: const AssetImage('assets/four.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      ),
                    ),
                  ),
                
              
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            decoration: 
                            BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
            
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[350]!,
                                  offset: const Offset(4, 4),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.grey[350]!,
                                  offset: const Offset(-4, -4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child:Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(26),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (_) => const AddReminderPage()),
                              // );
                              NotiService().showNotification(
                                id: 22,
                                title: "Yosef",
                                body: "I hate flutter",
                              );
                              
                            },
                            child: Ink.image(
                              image: const AssetImage('assets/plus.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                          ),
                          ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  height: 260,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
            
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[350]!,
                                  offset: const Offset(4, 4),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.grey[350]!,
                                  offset: const Offset(-4, -4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child:Material(
                              borderRadius: BorderRadius.circular(26),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: InkWell(
                                onTap: () => _pickImageAndNavigate(context, (file) => TypeDetection(imageFile: file)),
                                child: Ink.image(
                                  image: const AssetImage('assets/one.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            decoration: 
                            BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
            
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[350]!,
                                  offset: const Offset(4, 4),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.grey[350]!,
                                  offset: const Offset(-4, -4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child:Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(26),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              
                              child: InkWell(
                                onTap: () => _pickImageAndNavigate(context, (file) => DiseaseDetection(imageFile: file)),
                                child: Ink.image(
                                  image: const AssetImage('assets/two.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15,0),
                    child: Container(
                            decoration: 
                            BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
            
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300]!,
                                  offset: const Offset(4, 4),
                                  blurRadius: 15,
                                  spreadRadius: 0.5,
                                ),
                                BoxShadow(
                                  color: Colors.grey[200]!,
                                  offset: const Offset(-4, -4),
                                  blurRadius: 10,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                      child:Material(
                      borderRadius: BorderRadius.circular(26),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (_, __, ___) => ChatBotPage(initialMessage: "Hi"),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );

                        },
                        child: Ink.image(
                          image: const AssetImage('assets/bot.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
    );
  }
}
