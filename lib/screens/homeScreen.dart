import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:deepmusicfinder/deepmusicfinder.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mobil_proje/constants.dart';
import 'package:mobil_proje/data/getAllPlaylist.dart';
import 'package:mobil_proje/data/getPlaylist.dart';
import 'package:mobil_proje/widgets/img.dart';
import 'package:mobil_proje/widgets/head.dart';
import 'package:mobil_proje/widgets/space.dart';
import 'package:mobil_proje/widgets/time.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<Map<dynamic, dynamic>> songsList = [];
  List<Map<dynamic, dynamic>> tempsongsList = [];
  List<Map<dynamic, dynamic>> choosensongsList = [];
  List<Map<dynamic, dynamic>> playlistsongsList = [];
  Deepmusicfinder musicfinder;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isplaying = false;
  bool weedit = false;
  bool ispause = false;
  Duration current = Duration();
  Duration complete = Duration();
  TabController controller;
  bool createplaylist = false;
  playlist Playlistfile = playlist();
  allplaylist Allplaylist = allplaylist();
  List<String> PlaylistString = List();
  String whichplaylist = "AllSongs";
  String playingplaylist = "AllSongs";
  bool textfield = false;
  bool didweedit = false;
  TextEditingController txtcontroller = TextEditingController();
  bool isplayingnextsong = false;

  void getPermission() async {
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((checkPermissionStatus) async {
      if (checkPermissionStatus == PermissionStatus.granted) {
        try {
          dynamic result = await musicfinder.fetchSong;
          if (result["error"] == true) {
            print(result["errorMsg"]);
            return;
          }
          setState(() {
            songsList = List.from(result["songs"]);
            playlistsongsList.addAll(songsList);
          });
        } catch (e) {
          print(e);
        }
      } else {
        PermissionHandler().requestPermissions([PermissionGroup.storage]).then(
            (reqPermissions) async {
          if (reqPermissions[PermissionGroup.storage] ==
              PermissionStatus.granted) {
            try {
              dynamic result = await musicfinder.fetchSong;
              if (result["error"] == true) {
                print(result["errorMsg"]);
                return;
              }
              setState(() {
                songsList = List.from(result["songs"]);
                playlistsongsList.addAll(songsList);
              });
            } on PlatformException {
              print("Error");
            }
          }
        });
      }
    });
  }

  void getPermissionagain() async {
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((checkPermissionStatus) async {
      if (checkPermissionStatus == PermissionStatus.granted) {
        try {
          dynamic result = await musicfinder.fetchSong;
          if (result["error"] == true) {
            print(result["errorMsg"]);
            return;
          }
          setState(() {
            tempsongsList = [];
            tempsongsList = List.from(result["songs"]);
          });
        } catch (e) {
          print(e);
        }
      } else {
        PermissionHandler().requestPermissions([PermissionGroup.storage]).then(
            (reqPermissions) async {
          if (reqPermissions[PermissionGroup.storage] ==
              PermissionStatus.granted) {
            try {
              dynamic result = await musicfinder.fetchSong;
              if (result["error"] == true) {
                print(result["errorMsg"]);
                return;
              }
              setState(() {
                tempsongsList = [];
                tempsongsList = List.from(result["songs"]);
              });
            } on PlatformException {
              print("Error");
            }
          }
        });
      }
    });
  }

  loadplaylist() async {
    PlaylistString = [];
    await Allplaylist.readfile().then((value) => PlaylistString = value);
    bool isthere = false;
    for (String i in PlaylistString) {
      if (i == "AllSongs") {
        isthere = true;
      }
    }
    if (!isthere) {
      PlaylistString.add("AllSongs");
      await Allplaylist.writefile(PlaylistString);
      PlaylistString = [];
      await Allplaylist.readfile().then((value) => PlaylistString = value);
    }
    print(PlaylistString.length);
    setState(() {});
  }

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
    musicfinder = new Deepmusicfinder();
    this.getPermission();
    this.getPermissionagain();
    audioPlayer.durationHandler = (d) => setState(() {
          complete = d;
        });
    audioPlayer.positionHandler = (p) => setState(() {
          current = p;
        });

    loadplaylist();
  }

  play(int index) async {
    try {
      isplaying
          ? await audioPlayer.play(playlistsongsList[index]['path'],
              isLocal: true, stayAwake: true)
          : await audioPlayer.stop();
    } catch (err) {
      print(err);
    }
  }

  Widget songBuilder(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width - 90,
      margin: EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        title: Row(
          children: [
            Flexible(
              flex: 40,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      playlistsongsList[index]["Title"],
                      style: TextStyle(
                        color: (playingindex == index) ? blueC : whiteC,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: img(playlistsongsList[index]["Image"], index, false),
        onTap: () {
          setState(() {
            ispause = false;
            if (playingindex == index) {
              playingindex = -1;
              isplaying = false;
              audioPlayer.stop();
            } else {
              isplaying = true;
              this.play(index);
              playingindex = index;
            }
          });
        },
      ),
      decoration: (playingindex == index) ? white : blue,
    );
  }

  getchoosenplaylistsongs() async {
    choosensongsList = [];
    await Playlistfile.readfile(whichplaylist)
        .then((value) => choosensongsList.addAll(value));
  }

  Widget playlistbuilder(BuildContext context, int index) {
    return Container(
      color: accentC,
      width: MediaQuery.of(context).size.width - 90,
      margin: EdgeInsets.only(top: 2.0),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (PlaylistString[index] != "AllSongs")
                ? GestureDetector(
                    child: Container(
                      padding: EdgeInsets.only(right: 25.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onTap: () async {
                      await Playlistfile.deleteFile(PlaylistString[index]);
                      PlaylistString.remove(PlaylistString[index]);
                      await Allplaylist.writefile(PlaylistString);
                      PlaylistString = [];
                      await Allplaylist.readfile()
                          .then((value) => PlaylistString.addAll(value));
                      setState(() {});
                    },
                  )
                : Container(),
            RaisedButton(
              color: Colors.white.withOpacity(0),
              onPressed: () async {
                if (PlaylistString[index] == "AllSongs") {
                  playingindex = -1;
                  isplaying = false;
                  audioPlayer.stop();
                  playingplaylist = "AllSongs";
                  playlistsongsList = [];
                  playlistsongsList.addAll(songsList);
                } else {
                  whichplaylist = PlaylistString[index];
                  await getchoosenplaylistsongs();
                  createplaylist = !createplaylist;
                }
                setState(() {
                  weedit = false;
                });
              },
              child: Text(
                PlaylistString[index],
                style: TextStyle(fontSize: 30.0, color: Colors.white),
              ),
            ),
            (playingplaylist == PlaylistString[index])
                ? Container(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Icon(
                      Icons.forward,
                      color: Colors.white,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget songBuildertwo(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width - 90,
      margin: EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        title: Row(
          children: [
            Flexible(
              flex: 9,
              fit: FlexFit.tight,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      tempsongsList[index]["Title"],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: blue,
                    child: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 35.0,
                        ),
                        onPressed: () {
                          setState(() {
                            tempsongsList.removeAt(index);
                          });
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
        leading: img(tempsongsList[index]["Image"], index, false),
      ),
      decoration: blue,
    );
  }

  Widget songBuilderthree(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width - 90,
      margin: EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        title: Row(
          children: [
            Flexible(
              flex: 9,
              fit: FlexFit.tight,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      choosensongsList[index]["Title"],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: img(choosensongsList[index]["Image"], index, false),
      ),
      decoration: blue,
    );
  }

  Widget slider() {
    if (isplayingnextsong) {
      setState(() {
        Duration dur = complete - complete;
        audioPlayer.seek(dur);
      });
    }
    return Slider(
      activeColor: accentC,
      inactiveColor: Colors.white,
      value: current.inSeconds.toDouble(),
      min: 0.0,
      max: complete.inSeconds.toDouble(),
      onChanged: (double value) {
        if (value >= complete.inSeconds.toDouble()) {
          value = complete.inSeconds.toDouble() - 1;
        }
        setState(() {
          value = value;
          audioPlayer.seek(Duration(seconds: value.toInt()));
        });
      },
    );
  }

  forward() {
    ispause = false;
    playingindex += 1;
    if (playingindex > playlistsongsList.length - 1) {
      playingindex = 0;
    }
    setState(() {
      audioPlayer.play(playlistsongsList[playingindex]["path"],
          isLocal: true, stayAwake: true);
    });
  }

  back() {
    ispause = false;
    playingindex -= 1;
    if (playingindex < 0) {
      playingindex = playlistsongsList.length - 1;
    }
    setState(() {
      audioPlayer.play(playlistsongsList[playingindex]["path"],
          isLocal: true, stayAwake: true);
    });
  }

  gettab() {
    return Flexible(
        flex: 25,
        fit: FlexFit.tight,
        child: Container(
          width: MediaQuery.of(context).size.width - 20,
          decoration: blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              img(playlistsongsList[playingindex]["Image"], playingindex, true),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 120,
                    child: Text(
                      playlistsongsList[playingindex]["Title"],
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 40.0),
                    width: MediaQuery.of(context).size.width - 120,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            back();
                          },
                          child: Icon(
                            Icons.fast_rewind,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (ispause) {
                              audioPlayer.resume();
                            }
                            if (!ispause) {
                              audioPlayer.pause();
                            }
                            setState(() {
                              ispause = !ispause;
                            });
                          },
                          child: Icon(
                            (ispause) ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            forward();
                          },
                          child: Icon(
                            Icons.fast_forward,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        Time(current),
                        style: textStyle700,
                      ),
                      slider(),
                      Text(
                        Time(complete),
                        style: textStyle300,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget Songs() {
    return Container(
      decoration: blue,
      child: Column(
        children: [
          Head(context),
          Space(),
          Flexible(
            flex: 80,
            fit: FlexFit.tight,
            child: Container(
              width: MediaQuery.of(context).size.width - 20,
              padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
              child: ListView.builder(
                itemBuilder: songBuilder,
                itemCount: (playingplaylist == "AllSongs")
                    ? songsList.length
                    : choosensongsList.length,
              ),
              decoration: blue,
            ),
          ),
          Space(),
          isplaying ? gettab() : Container(),
        ],
      ),
    );
  }

  Widget Playlist() {
    return Container(
      color: blueC,
      child: Column(
        children: [
          Head(context),
          Space(),
          Flexible(
            flex: 20,
            fit: FlexFit.tight,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: (!createplaylist)
                  ? Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5.0),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 20,
                            padding: EdgeInsets.only(top: 25.0, bottom: 2.0),
                            child: ListView.builder(
                                itemCount: PlaylistString.length,
                                itemBuilder: playlistbuilder),
                            decoration: blue,
                          ),
                        ),
                        (!createplaylist)
                            ? (!textfield) //true
                                ? Center(
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: Colors.white,
                                          size: 50.0,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            textfield = !textfield;
                                          });
                                        }),
                                  )
                                : Container(
                                    child: Column(
                                      children: [
                                        TextField(
                                          maxLength: 15,
                                          decoration: InputDecoration(
                                            hintText:
                                                "        Liste adını giriniz",
                                            hintStyle: TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                          controller: txtcontroller,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              child: Icon(
                                                Icons.done,
                                                color: blueC,
                                                size: 30.0,
                                              ),
                                              onTap: () async {
                                                if (txtcontroller.text != "") {
                                                  PlaylistString.add(
                                                      txtcontroller.text);
                                                  await Allplaylist.writefile(
                                                      PlaylistString);
                                                  PlaylistString = [];
                                                  await Allplaylist.readfile()
                                                      .then((value) =>
                                                          PlaylistString =
                                                              value);
                                                }
                                                setState(() {
                                                  textfield = !textfield;
                                                });
                                              },
                                            ),
                                            SizedBox(
                                              width: 40.0,
                                            ),
                                            GestureDetector(
                                              child: Icon(
                                                Icons.cancel,
                                                color: blueC,
                                                size: 30.0,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  textfield = !textfield;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    decoration: white,
                                  )
                            : Container(),
                        // Padding(padding: EdgeInsets.only(bottom: 5.0)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              decoration: blue,
                              child: GestureDetector(
                                child: Text(
                                  whichplaylist,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 40.0),
                                ),
                                onTap: () {
                                  setState(() {});
                                },
                              ),
                            ),
                            Container(
                              decoration: blue,
                              child: GestureDetector(
                                child: Icon(
                                  Icons.save,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                                onTap: () async {
                                  if (didweedit) {
                                    choosensongsList = [];
                                    choosensongsList.addAll(tempsongsList);
                                    await Playlistfile.writefile(
                                        choosensongsList, whichplaylist);
                                  }
                                  choosensongsList = [];
                                  await Playlistfile.readfile(whichplaylist)
                                      .then((value) =>
                                          choosensongsList.addAll(value));
                                  setState(() {
                                    playlistsongsList = [];
                                    playlistsongsList.addAll(choosensongsList);
                                    createplaylist = !createplaylist;
                                  });
                                },
                              ),
                            ),
                            Container(
                              decoration: blue,
                              child: GestureDetector(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                                onTap: () async {
                                  if (didweedit) {
                                    choosensongsList = [];
                                    choosensongsList.addAll(tempsongsList);
                                    await Playlistfile.writefile(
                                        choosensongsList, whichplaylist);
                                  }
                                  choosensongsList = [];
                                  await Playlistfile.readfile(whichplaylist)
                                      .then((value) =>
                                          choosensongsList.addAll(value));
                                  setState(() {
                                    playingindex = -1;
                                    isplaying = false;
                                    audioPlayer.stop();
                                    playingplaylist = whichplaylist;
                                    createplaylist = !createplaylist;
                                    playlistsongsList = [];
                                    playlistsongsList.addAll(choosensongsList);
                                  });
                                },
                              ),
                            ),
                            Container(
                              decoration: blue,
                              child: GestureDetector(
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                                onTap: () async {
                                  if (!weedit) {
                                    getPermissionagain();
                                    choosensongsList = [];
                                    await Playlistfile.writefile(
                                        choosensongsList, whichplaylist);
                                  } else {
                                    choosensongsList = [];
                                    choosensongsList.addAll(tempsongsList);
                                    await Playlistfile.writefile(
                                        choosensongsList, whichplaylist);
                                    choosensongsList = [];
                                    await Playlistfile.readfile(whichplaylist)
                                        .then((value) =>
                                            choosensongsList.addAll(value));
                                  }
                                  setState(() {
                                    didweedit = true;
                                    weedit = !weedit;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              decoration: blue,
            ),
          ),
          Space(),
          (createplaylist)
              ? ((weedit)
                  ? Flexible(
                      flex: 80,
                      fit: FlexFit.tight,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                        child: ListView.builder(
                          itemBuilder: songBuildertwo,
                          itemCount: tempsongsList.length,
                        ),
                        decoration: blue,
                      ),
                    )
                  : Flexible(
                      flex: 80,
                      fit: FlexFit.tight,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                        child: ListView.builder(
                          itemBuilder: songBuilderthree,
                          itemCount: choosensongsList.length,
                        ),
                        decoration: blue,
                      ),
                    ))
              : Container(),
          (createplaylist) ? Space() : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            body: TabBarView(
              children: <Widget>[Songs(), Playlist()],
              controller: controller,
            ),
            bottomNavigationBar: Material(
              color: accentC,
              child: TabBar(
                tabs: <Tab>[
                  Tab(
                    child: Container(
                      child: Column(
                        children: [
                          Icon(Icons.queue_music),
                          Text("Şarkılar"),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      child: Column(
                        children: [
                          Icon(Icons.featured_play_list),
                          Text("Oynatma Listeleri"),
                        ],
                      ),
                    ),
                  ),
                ],
                controller: controller,
                indicatorColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
