import 'dart:math';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';

class MyGameSubClass extends BaseGame with PanDetector {
  var screenSize = Size(800, 626);

  SpriteAnimationComponent player;
  var playerSize = Vector2(66, 82);
  var playerSpriteSheet;

  var bulletSize = Vector2(24, 24);

  var bulletImage;

  var bullets = [];

  bool isGameStart = false;

  //游戏基本配置
  //碰撞检测范围
  double hitDistance = 20;

  //更改画布背景色
  @override
  Color backgroundColor() => Color(0xffc3c8c9);

  //引擎准备完成
  @override
  Future<void> onLoad() async {
    print(screenSize);
    //加载飞机的序列帧图片
    playerSpriteSheet = SpriteSheet(
      image: await images.load('player.png'),
      srcSize: playerSize,
    );

    player = SpriteAnimationComponent(
      size: playerSize,
      animation: playerSpriteSheet.createAnimation(row: 0, stepTime: .1, to: 2),
    );

    //将飞机添加到场景中
    add(player);
    //读取子弹素材
    bulletImage = await images.load('bullet.png');

    //游戏初始化
    gameReset();

    gameStart();
  }

  //游戏数据复原函数
  void gameReset() {
    player.x = (screenSize.width - playerSize.x) / 2;
    player.y = (screenSize.height - playerSize.y) / 2;

    bullets.removeWhere((element) => true);
    bullets = [];

    gameTime = 0;
  }

  Timer timer;
  int gameTime = 0;
  void gameStart() {
    isGameStart = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      gameTime += 1;
      addGroupBullet();
    });

    addGroupBullet();
  }

  void gameOver() {
    isGameStart = false;

    if(timer!=null)timer.cancel();

    player.animation = playerSpriteSheet.createAnimation(
        row: 0, stepTime: .1, loop: false, from: 2, to: 6);

    print("game over");
  }

  //添加一个子弹
  void addBullet() {
    final bullet = SpriteComponent.fromImage(bulletImage, size: bulletSize);

    double bulletX;
    double bulletY;

    if (Random().nextBool()) {
      bulletX = Random().nextDouble() * (screenSize.width + bulletSize.x) -
          bulletSize.x;
      bulletY = Random().nextBool() ? -bulletSize.y : screenSize.height;
    } else {
      bulletX = Random().nextBool() ? -bulletSize.x : screenSize.width;
      bulletY = Random().nextDouble() * (screenSize.height + bulletSize.y) -
          bulletSize.y;
    }

    bullet.x = bulletX;
    bullet.y = bulletY;

    add(bullet);

    bullets.add({
      "component": bullet,
      "speed": (1+gameTime/10) + Random().nextDouble()*3,
      "angle": atan2(((bulletY + bulletSize.y/2) - (player.y + playerSize.y / 2)),
          ((bulletX + bulletSize.x) - (player.x + playerSize.x / 2)))
    });
  }

  //添加一组子弹
  void addGroupBullet() {
    int groupCount = 10+Random().nextInt(gameTime+1);
    for (int i = 0; i < groupCount; i++) {
      addBullet();
    }
  }

  //游戏主循环
  @override
  void update(double dt) {
    super.update(dt);

    if (!isGameStart) return;

    for (int i = bullets.length - 1; i >= 0; i--) {
      var bulletItem = bullets[i];

      SpriteComponent bullet = bulletItem["component"] as SpriteComponent;

      double angle = bulletItem["angle"];
      double speed = bulletItem["speed"];

      bullet.x -= cos(angle) * speed;
      bullet.y -= sin(angle) * speed;

      if (isHitPlayer(bullet.x, bullet.y)) {
        gameOver();
      }

      if (isNotInScreen(bullet.x, bullet.y)) {
        print("bullet removed");
        remove(bullet);
        bullets.removeAt(i);
        continue;
      }
    }
  }

  //子弹离开屏幕判断
  bool isNotInScreen(double x, double y) {
    if (x + bulletSize.x/2 < 0 || x > screenSize.width || y + bulletSize.y/2 < 0 || y > screenSize.height)
      return true;
    return false;
  }

  //飞机和子弹碰撞判断
  bool isHitPlayer(double x, double y) {
    double _x = (x + bulletSize.x / 2 - (player.x + playerSize.x / 2)).abs();
    double _y = (y + bulletSize.y / 2 - (player.y + playerSize.y / 2)).abs();

    double distance = sqrt(_x * _x + _y * _y);

    if (distance <= hitDistance) return true;
    return false;
  }

  //拖动移动飞机
  @override
  void onPanUpdate(DragUpdateDetails details) {
    super.onPanUpdate(details);

    if (!isGameStart) return;

    player.x = details.globalPosition.dx - playerSize.x / 2;
    player.y = details.globalPosition.dy - playerSize.y / 2;
  }
}

main() {
  runApp(GameWidget(
    game: MyGameSubClass(),
  ));
}
