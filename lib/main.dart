import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:prectice7/pedometer.dart';

void main() => runApp(MyApp());

final WalkService walkService = Get.put(WalkService());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: MainPage(),
  );
}

class MainPage extends StatelessWidget {

  MainPage({super.key});

  final ReceivePort receivePort = ReceivePort();

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription: 'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    FlutterForegroundTask.startService(
        notificationTitle: "걸음수",
        notificationText: walkService.currentSteps.value.toString(),
        callback: startCallback
    );


    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'walkServicePort');
  }

  bool isRun = false;

  @override
  Widget build(BuildContext context) {
    Get.put(WalkService());
    _initForegroundTask();
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(title: Text("Foreground Task 2023"),),
        body: Center(
          child: GetBuilder<WalkService>(
            builder: (controller){
              return Text(controller.currentSteps.value.toString());
            },
          )
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  SendPort? _sendPort;

  int minute = -1;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    final port = IsolateNameServer.lookupPortByName('walkServicePort');
    _sendPort = port;
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    int updateStep = walkService.currentSteps.value;

    if (minute == -1) {
      minute = DateTime.now().minute;
    }
    if (minute != DateTime.now().minute) {
      walkService.resetStepTimer();
      print('reset');
    }
    minute = DateTime.now().minute;

    FlutterForegroundTask.updateService(
      notificationTitle: "걸음수",
      notificationText: updateStep.toString(),
    );
    _sendPort?.send(updateStep);
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {}
}
