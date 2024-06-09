import 'dart:io';

import 'package:autoupdate_sample/file.dart';
import 'package:autoupdate_sample/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';


class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  String log='';
  double progressValue=0;


  late FileHelper updateDataFile;
  late FileHelper replaceDataFile;
  late FileHelper replaceActionFile;

  final String upgradePath = ".\\FakeServer\\NewData\\";
  final String downgradePath = ".\\FakeServer\\OldData\\";


  @override
  void initState() {

    String updateDataPath = '.\\updateData.dat';
    String replaceDataPath = '.\\replaceData.dat';
    String replaceActionPath = '.\\replace.bat';

    updateDataFile = FileHelper(updateDataPath);
    replaceDataFile = FileHelper(replaceDataPath);
    replaceActionFile = FileHelper(replaceActionPath);
    super.initState();
  }


  void calculateProgress (double totalTask,double finished){
    setState(() {
      progressValue= (finished/totalTask);
    });
  }

  void updateLog(String newLog){
    setState(() {
      log += newLog;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade600,
      body: Stack(
        children: [
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 24,
            color: Colors.deepPurpleAccent,
          ),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Text('APLIKASI BARU',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w800),),
                const SizedBox(height: 24,),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () async {
                          await updateData(upgradePath);
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                        ),
                        child: const Text("Upgrade App")
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await updateData(downgradePath);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade700,
                        ),
                        child: const Text("Downgrade App")
                    ),
                  ],
                ),
                const SizedBox(height: 48,),
                Container(
                  color: Colors.black12,
                    padding: const EdgeInsets.all(16),
                    height: 400,
                    child: SingleChildScrollView(child: Row(
                      children: [
                        Expanded(child: Text(log,style: const TextStyle(color: Colors.black87,fontSize: 14))),
                      ],
                    )))
              ],
            ),
          ),
        ],
      ),
    );
  }

  String replaceActionString(String item){

    String fileName = item.split('\\').last;
    String deleteAction = 'del $item';
    String renameAction = 'rename $item.new $fileName';

    String actions = '''
    $deleteAction
    $renameAction
    ''';
    return actions;
  }

  String createReplaceActions(String replaceList){

    String killApp = '''
    set "processName=${appInfo.appName}.exe"
    taskkill /IM %processName% /F
    
    :waitForAppToClose
    tasklist /FI "IMAGENAME eq %processName%" 2>NUL | find /I "%processName%" >NUL
    if "%ERRORLEVEL%"=="0" (
        echo waiting Application closed...
        timeout /t 5 /nobreak > NUL
        goto waitForAppToClose
    )
    ''';
    String removeTempFiles = '''
    del ${replaceDataFile.path};
    del ${replaceActionFile.path};
    ''';
    String openApp = 'start ${appInfo.appName}.exe';

    String result = '''
    $killApp
    $replaceList
    $openApp
    $removeTempFiles
    ''';

    return result;
  }

  Future<void> updateData(String downloadPath) async {

    updateLog('Update Data Path : ${updateDataFile.path} \n');
    updateLog('Replace Data Path : ${replaceDataFile.path} \n');
    updateLog('Action Data Path : ${replaceActionFile.path} \n');

    List<String> result = await updateDataFile.readToList();
    updateLog('Total Line ${result.length} \n');
    double taskDone = 0;
    double totalTask = result.length.toDouble();

    String replaceDataList = '';
    String actionReplaceList = '';

    for (var item in result) {

      // Delay just for download process simulation
      await Future.delayed(const Duration(milliseconds: 200));

      // this Copy just for simulation download file
      // name the new file with extension '.new' in the same path of the old file
      String action = 'copy ${downloadPath+item} $item.new';
      updateLog('$action \n');
      var task = await shell.run(action);
      updateLog('${task.outText} \n');

      // Create batch to replace files
      replaceDataList+='$item\n';
      actionReplaceList+='${replaceActionString(item)}\n';
      replaceDataFile.write(replaceDataList);
      replaceActionFile.write(createReplaceActions(actionReplaceList));

      //simulating download progress calculation
      taskDone++;
      calculateProgress(totalTask, taskDone);

    }
    showCompleteDialog();
  }

  void showCompleteDialog(){
    showDialog(context: context, builder: (BuildContext context){
      return CupertinoAlertDialog(
        title: const Text("Update Success"),
        content: const Text("Please dont close, we will restart the app"),
        actions: [
          CupertinoDialogAction(onPressed: (){
            onRestartApp();
          }, child: const Text("Restart App")),
        ],
      );
    });
  }
  void onRestartApp(){
    shell.run('start "" cmd /c .\\replace.bat');
  }
}
