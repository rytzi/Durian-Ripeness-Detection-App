import 'package:camera/camera.dart';

class UserInput {
  late XFile image1;
  late XFile image2;
  late XFile image3;
  late XFile image4;
  late List<Map<String, dynamic>> aromaData;

  UserInput._privateConstructor();

  static final UserInput _instance = UserInput._privateConstructor();
  static UserInput get instance => _instance;

  void setImage1(XFile image) {
    image1 = image;
  }

  void setImage2(XFile image) {
    image2 = image;
  }

  void setImage3(XFile image) {
    image3 = image;
  }

  void setImage4(XFile image) {
    image4 = image;
  }

  void setAromaData(List<Map<String, dynamic>> data) {
    aromaData = data;
  }
}
