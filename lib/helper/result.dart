class ResultModel {
  late bool CNN = true;
  late bool ANN = true;
  late bool ICA = true;
  late double CNNA = 1;
  late double ANNA = 1;
  late double ICAA = 1;

  ResultModel._privateConstructor();

  static final ResultModel _instance = ResultModel._privateConstructor();
  static ResultModel get instance => _instance;

  void setIsRipeCNN(bool result) {
    CNN = result;
  }

  void setIsRipeANN(bool result) {
    ANN = result;
  }

  void setIsRipeICA(bool result) {
    ICA = result;
  }

  void setCNNA(double percent) {
    CNNA = double.parse(percent.toStringAsFixed(2));
  }

  void setANNA(double percent) {
    ANNA = double.parse(percent.toStringAsFixed(2));
  }

  void setICAA(double percent) {
    ICAA = double.parse(percent.toStringAsFixed(2));
  }
}
