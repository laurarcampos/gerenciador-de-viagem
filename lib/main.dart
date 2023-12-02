import 'package:firebase_app/firebase_options.dart';
import 'package:firebase_app/pages/home_page.dart';
import 'package:firebase_app/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // garante que todos componentes sejam inializados
  WidgetsFlutterBinding.ensureInitialized();
  // conecta app com firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
    ),
    title: 'Firebase APP',
    home: HomePage(),
  ));
}