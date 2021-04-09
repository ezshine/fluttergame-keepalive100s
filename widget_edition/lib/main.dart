import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:widget_edition/widgets/AnimatedSpriteImage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int gameStatus = 0;

  double playerLeft = 0;
  double playerTop = 0;
  double playerWidth = 66;
  double playerHeight= 82;
  int playerSpriteStartIndex = 0;
  int playerSpriteEndIndex = 1;
  int playerSprtePlayTimes = 0;

  double hitDistance = 20;
  Size screenSize = window.physicalSize/window.devicePixelRatio;
  Size bulletSize = Size(20,20);

  List bulletsData = [];

  int gameTime = 0;

  late Timer updateTimer;
  late Image bulletImage;

  @override
  void initState() {

    bulletImage = Image.asset("assets/images/bullet.png",width: bulletSize.width,height: bulletSize.height);

    super.initState();
  }

  addBullet(){
    double bulletX;
    double bulletY;

    if (Random().nextBool()) {
      bulletX = Random().nextDouble() * (screenSize.width + bulletSize.width) -
          bulletSize.width;
      bulletY = Random().nextBool() ? -bulletSize.height : screenSize.height;
    } else {
      bulletX = Random().nextBool() ? -bulletSize.width : screenSize.width;
      bulletY = Random().nextDouble() * (screenSize.height + bulletSize.height) -
          bulletSize.height;
    }

    bulletsData.add({
      "x":bulletX,
      "y":bulletY,
      "speed": (1+gameTime/10) + Random().nextDouble()*3,
      "angle": atan2(((bulletY + bulletSize.height/2) - (playerTop + playerHeight / 2)),
          ((bulletX + bulletSize.width) - (playerLeft + playerWidth / 2)))
    });
  }

  addGroupBullets(){
    int groupCount = 10+Random().nextInt(gameTime+1);
    for (int i = 0; i < groupCount; i++) {
      addBullet();
    }
  }

  getBullets(){
    List<Positioned> bullets = [];

    for(int i = 0;i<bulletsData.length;i++){
      var bulletItem = bulletsData[i];
      // print(bulletItem);
      var bulletWidget = Positioned(
        left: bulletItem["x"],
        top: bulletItem["y"],
        child: bulletImage
      );

      bullets.add(bulletWidget);
    }

    return bullets;
  }

  //子弹离开屏幕判断
  bool isNotInScreen(double x, double y) {
    if (x < -bulletSize.width || x > screenSize.width || y < -bulletSize.height || y > screenSize.height)
      return true;
    return false;
  }

  //飞机和子弹碰撞判断
  bool isHitPlayer(double x, double y) {
    double _x = (x + bulletSize.width / 2 - (playerLeft + playerWidth / 2)).abs();
    double _y = (y + bulletSize.height / 2 - (playerTop + playerHeight / 2)).abs();

    double distance = sqrt(_x * _x + _y * _y);

    if (distance <= hitDistance) return true;
    return false;
  }

  sceneTitle() {

    return Center(
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 100),
              child: Image.asset("assets/images/title.png", width: 300)),
          Padding(
              padding: EdgeInsets.only(top: 100),
              child: SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () {
                        gameStart();
                      },
                      child: Text("游戏开始"))))
        ],
      ),
    );
  }

  sceneGameStart() {

    return GestureDetector(
      
        onPanUpdate: (DragUpdateDetails details) {
          if(gameStatus==1){
            setState(() {
              playerLeft += details.delta.dx;
              playerTop += details.delta.dy;
            });
          }
        },
        child: Stack(
          children: [
            Positioned(
              left: playerLeft,
              top: playerTop,
              child: AnimatedSpriteImage(
                duration: Duration(milliseconds: 200),
                image: Image.asset("assets/images/player.png"),
                spriteSize: Size(66, 82),
                startIndex: playerSpriteStartIndex,
                endIndex: playerSpriteEndIndex,
                playTimes: playerSprtePlayTimes,
              ),
            ),
            Stack(
              children: getBullets(),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.topCenter,
                child: Text("$gameTime秒",style: TextStyle(fontSize: 48),),
              )
            ),
            sceneGameOver()
          ],
        ));
  }

  sceneGameOver() {
    if(gameStatus!=2)return Container();
    return Center(
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 200),
              child: Image.asset("assets/images/gameover.png", width: 300)),
          Padding(
              padding: EdgeInsets.only(top: 100),child:Align(
            child: Text("恭喜获得$gameTime秒真男人称号",style: TextStyle(fontSize: 30,color: Colors.blue),),
          )),
          Padding(
              padding: EdgeInsets.only(top: 100),
              child: SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () {
                        gameStart();
                      },
                      child: Text("淦，再来一次"))))
        ],
      ),
    );
  }

  getSceneByStatus() {
    if (gameStatus == 0) {
      return sceneTitle();
    } else if (gameStatus >= 1) {
      return sceneGameStart();
    }
  }

  gameOver(){
    if(updateTimer.isActive)updateTimer.cancel();

    setState(() {
      playerSpriteStartIndex = 2;
      playerSpriteEndIndex = 4;
      playerSprtePlayTimes = 1;
      gameStatus=2;
    });
  }

  gameStart(){

    updateTimer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      
      if(timer.tick%50==0){
        //seconds
        gameTime+=1;
        addGroupBullets();
      }

      for (int i = bulletsData.length - 1; i >= 0; i--) {
      var bulletItem = bulletsData[i];

      double angle = bulletItem["angle"];
      double speed = bulletItem["speed"];

      bulletItem["x"] -= cos(angle) * speed;
      bulletItem["y"] -= sin(angle) * speed;

      if (isHitPlayer(bulletItem["x"], bulletItem["y"])) {
        print("gameOver");
        gameOver();
      }

      if (isNotInScreen(bulletItem["x"], bulletItem["y"])) {
        print("bullet removed");
        bulletsData.removeAt(i);
        continue;
      }
    }

      setState(() {
        
      });
    });
    

    setState(() {
      playerSpriteStartIndex = 0;
      playerSpriteEndIndex = 1;
      playerSprtePlayTimes = 0;

      bulletsData= [];
      gameStatus = 1;
      gameTime = 0;

      playerLeft = screenSize.width/2-66/2;
      playerTop = screenSize.height/2-82/2;
    });

    addGroupBullets();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTextStyle(style: TextStyle(color: Colors.blue), child: Container(child:getSceneByStatus(),color: Colors.grey[300],));
  }
}
