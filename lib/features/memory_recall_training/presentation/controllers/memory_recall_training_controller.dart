import 'package:get/get.dart';

class MemoryRecallTrainingController extends GetxController {
  var scentName = '';
  var deviceNumber = 0;
  var fanNumber = 0;
  var round = 0;  
  var userId = 0;
  var chatId = 0;  

  void reset() {
    scentName = '';
    deviceNumber = 0;
    fanNumber = 0;
    round = 0;
    userId = 0;
    chatId = 0;
  }
}
