Time(Duration duration) {
  String time = "";
  String temp = "";
  double inttime = duration.inSeconds.toDouble();
  temp = (inttime ~/ (60 * 60)).toString();
  if (temp != '0') {
    time = temp;
    time += ":";
  }
  inttime %= (60 * 60);
  time += (inttime ~/ 60).toString(); //toInt -> toString
  time += ":";
  inttime %= 60;
  time += (inttime.toInt()).toString();
  return time;
}
