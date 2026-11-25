import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseException? initializationError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error) {
    initializationError = error;
  }

  runApp(InventoryApp(initializationError: initializationError));
}
