import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'home.dart';
import 'produk.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://saivshymrimryymhavia.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhaXZzaHltcmltcnl5bWhhdmlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTUyOTMsImV4cCI6MjA1NDI5MTI5M30.t6PubxMA6g1KM8Ffe8co0NZoUnsDjVArAx0IPRSyxPM',
  );
  runApp(MyApp());
}
        

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Login(), // Ubah halaman awal ke LoginScreen
    );
  }
}