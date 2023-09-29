import 'package:flutter/material.dart';
import 'view/detailCashFlow.dart';
import 'view/home.dart';
import 'view/profile.dart';
import 'view/tambahTransaksi.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'Auth/login.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tambahkan Item',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LoginPage(),
    );
  }
}
