import 'package:get/get.dart';
import 'package:skribbl_clone/model/message.dart';

class ChatController extends GetxController {
  var chatMessages = <Message>[].obs;
  var connectedUser = 0.obs;
}
