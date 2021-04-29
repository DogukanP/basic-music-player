import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobil_proje/constants.dart';

int playingindex = -1;

Widget img(img, int index, bool isit) {
  if (img == null) {
    return ClipOval(
        child: Icon(
      Icons.music_note,
      color: (playingindex != index || isit) ? Colors.white : blueC,
    ));
  }
  if (img == "unknown") {
    return ClipOval(
        child: Icon(
      Icons.music_note,
      color: (playingindex != index || isit) ? Colors.white : blueC,
      size: 50.0,
    ));
  }
  File pic = new File.fromUri(Uri.parse(img));
  return ClipOval(
    child: Image.file(pic, height: 50.0, width: 50.0),
  );
}
