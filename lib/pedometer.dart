import 'dart:async';

import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:pedometer/pedometer.dart';
import 'package:get_storage/get_storage.dart';

class WalkService extends GetxController{
  late Stream<StepCount> _stepCountStream;

  static final String KEY = 'pastSteps2';

  RxInt currentSteps = 0.obs;
  RxInt totalSteps = 0.obs;
  RxInt pastSteps = 0.obs;

  String get getCurrentSteps => currentSteps.value.toString();

  final GetStorage box = GetStorage();

  @override
  void onInit(){
    super.onInit();
    initPlatformState();
    init();
  }

  void init() async{
    await GetStorage.init();
  }

  // Future<int> getCurrentStep() {
  //   return Future<int>.value(_currentSteps);
  // }

  void updateStep(StepCount event) async {
    totalSteps.value = event.steps;

    int? value = box.read(KEY);

    if (value == null || value==0) {
      pastSteps.value = totalSteps.value;
      box.write(KEY, totalSteps.value);
    } else {
      pastSteps.value = value;
    }
    currentSteps.value = totalSteps.value - pastSteps.value ;
    update();
    print('currrent22 ${currentSteps.value}, ${pastSteps.value}, ${value}');
  }


  void resetStepTimer() async {
    pastSteps.value = totalSteps.value;
    currentSteps.value = 0;
    box.write(KEY, totalSteps.value);
    print('currrent33 ${currentSteps.value}, ${pastSteps.value}');
    update();
  }

  void onStepCountError(error) {
    currentSteps.value = 0;
  }

  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(updateStep).onError(onStepCountError);
  }
}
