import 'package:autoupdate_sample/app.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:process_run/process_run.dart';

late final Shell shell;
late final PackageInfo appInfo;

Future<void> main() async {
  shell = Shell();
  appInfo = await PackageInfo.fromPlatform();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white,),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(color:Colors.white,fontSize: 16,fontWeight: FontWeight.w700),
              fixedSize: const Size(200, 50)
          )
        ),
        useMaterial3: true,
      ),
      home: const AppScreen()
    );
  }
}


