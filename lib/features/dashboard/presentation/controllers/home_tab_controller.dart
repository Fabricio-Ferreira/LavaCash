import 'package:get/get.dart';

class HomeTabController extends GetxController {
  final RxInt currentTab = 0.obs;

  void setTab(int index) {
    currentTab.value = index;
  }
}
