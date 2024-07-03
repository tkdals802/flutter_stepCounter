import 'dart:async';

import 'package:get/get.dart';
import 'package:prectice7/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PedometerController extends GetxController {
  late final WalkService walkService = WalkService();
  RxInt _currentStep = 0.obs;

  late int pastYear;
  late int pastMonth;
  late int pastDay;

  @override
  void onInit() {
    super.onInit();
    walkService.initPlatformState();
    // Timer.periodic(const Duration(seconds: 20), (t) {
    //   walkService.resetStepTimer();
    // });
    // Timer.periodic(const Duration(seconds: 1), (t) {
    //   getCurrentStep().then((step) {
    //     _currentStep.value = step;
    //   });
    // });
  }

  // Future<int> getCurrentStep() async {
  //   _currentStep.value = await walkService.getCurrentStep();
  //   return _currentStep.value;
  // }

  String getStep() {
    return _currentStep.value.toString();
  }

}
