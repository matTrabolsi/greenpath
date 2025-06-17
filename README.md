🌿 GreenPath - AI-Powered Plant Care Assistant

GreenPath is a mobile application that uses artificial intelligence to help users identify plants, diagnose plant diseases, get expert advice, and receive personalized watering reminders. Whether you're a plant enthusiast, a home gardener, or an outdoor adventurer, GreenPath is your go-to app for reliable, accessible, and efficient plant care.
🚀 Features

    🌱 Plant Identification: Instantly identify plants using AI-powered image classification.

    🌾 Disease Detection: Diagnose plant diseases with high accuracy through photo analysis.

    💬 Expert Chatbot: Get 24/7 expert advice on plant care via an AI-powered chatbot.

    ⏰ Watering Reminders: Schedule personalized watering tasks with in-app notifications.

    📱 Offline Support: All AI inference is performed on-device with TensorFlow Lite.

    📷 User-Friendly UI: Intuitive green-themed design with simple navigation and clean interfaces.

🧠 AI & Model Architecture

GreenPath leverages deep learning models trained on the PlantVillage dataset to provide highly accurate plant recognition and disease classification.
Experiments Summary
Model	Input Size	Accuracy	Parameters	Model Size
CNN (Standard)	100x100	98.02%	6.5M	25MB
CNN + LSTM	100x100	98.53%	1.7M	7MB
CNN (Standard)	224x224	99.19%	51.6M	175MB
CNN + LSTM	224x224	99.24%	71.5M	170MB

Models were trained using:

    Optimizer: Adamax

    Loss: Sparse categorical crossentropy

    Epochs: Up to 100 with early stopping

    Data Augmentation: Rotation, flipping, shifting, zooming, brightness

📱 Tech Stack
Frontend

    Flutter for cross-platform mobile development

    Dart for UI and state management

    Key packages:

        tflite_flutter

        image_picker

        http

        hive (local storage)

        flutter_local_notifications

Backend

    FastAPI for chatbot API

    Python for ML model development and deployment

    TensorFlow / Keras for model training

    OpenCV for image preprocessing

🧪 Evaluation Metrics

Each model was evaluated using:

    Accuracy

    Precision

    Recall

    F1-Score

Sample result for best-performing model:

    Accuracy: 99.24%

    Precision: 0.99

    Recall: 0.98

    F1-score: 0.99

📊 System Design

    Plant and disease identification via TensorFlow Lite models

    Chatbot interaction handled asynchronously through FastAPI

    Modular app screens: Home, Identify Plant, Diagnose Disease, Chatbot, Add Reminder, View Reminders

    Local data storage for reminders and offline AI support

🧩 UML & GUI Designs

    UML Use Case, Sequence, Activity, and Class Diagrams

    Clean and minimal UI inspired by nature’s green palette

    Five distinct screen designs for intuitive user flow

📚 Related Work

GreenPath improves on existing apps like:

    Agrio – Strong in pest control but complex for non-farmers

    PlantSnap – Excellent plant ID, lacks disease detection

    PlantMinder – Great UI, but missing AI features

GreenPath combines the best of all: AI-based ID + Disease Detection + Reminders + Chatbot.
🧑‍💻 Authors

    Mahmoud Abdullah Fouad Trabolsi – GitHub

    Yosef Eyad Saed Al-Sheikh Qasem – GitHub

📝 License

This project is for academic and educational purposes only. Contact the authors for reuse permissions or collaborations.
📎 References

    PlantVillage Dataset: Kaggle

    "Using Deep Learning for Image-Based Plant Disease Detection" – Frontiers in Plant Science

    Agrio: https://agrio.app

    PlantSnap: https://www.plantsnap.com
