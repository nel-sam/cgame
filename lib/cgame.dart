import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class CGame extends FlameGame with TapDetector {
  late Size screenSize = Size(0, 0);
  late ParallaxComponent backgrounds;
  late SpriteAnimationComponent player;
  late SpriteAnimationComponent plane;
  late bool isCrashing = false;
  late int crashFrameCount = 100;
  late SpriteComponent food;
  late SpriteComponent number1;
  late SpriteComponent number2;
  late double newX = 0;
  late int score = 0;
  late double defaultBgBaseSpeed = -200;
  late double numberWH = 50;
  late bool moveRight;
  late int loopsDone = 0;
  late int maxLoops = 25;
  late int playerSpeed = 0;
  //Bgm audio = Bgm();
  late SpriteComponent gameOver;

  CGame() {}

  double getRandomX() {
    try {
      Random rnd;
      int min = 40;
      int max = screenSize.width.toInt() - 60;
      rnd = new Random();
      int numba = (min + rnd.nextInt(max - min));

      if (numba == null) {
        numba = 0;
      }

      return numba.toDouble();
    } catch (ex) {
      return 100;
    }
  }

  void handleFoodCollision() {
    score++;
    setPointsDisplay();
    food.y = -100;
    food.x = getRandomX();
  }

  void handlePlaneCollision() {
    score--;
    setPointsDisplay();
    isCrashing = true;
  }

  bool isFoodCollision() {
    double playerCenterX = player.x + (player.width / 2);
    double playerMinY = player.y;
    double playerMaxY = player.y + player.height;

    double foodCenterX = food.x + (food.width / 2);
    double foodMinY = food.y;
    double foodMaxY = food.y + food.height;

    bool inXRange =
        (playerCenterX - foodCenterX).abs().toInt() < food.width / 2;
    bool inYRange = foodMinY >= playerMinY && foodMaxY <= playerMaxY;
    return inXRange && inYRange;
  }

  bool isGameOver() {
    return loopsDone >= maxLoops;
  }

  bool isPlaneCollision() {
    int xDist = (player.x - plane.x).abs().toInt();
    bool inYRange = (plane.y + plane.height) >= player.y &&
        (plane.y + plane.height) <= (player.y + player.height);
    return xDist < (plane.width / 2) && inYRange;
  }

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();

    // audio.initialize();
    // if (audio.isPlaying) audio.audioPlayer.stop();
    // audio.play('music.mp3');

    // backgrounds = ParallaxComponent(
    //   [
    //     ParallaxImageData(
    //       'water.png',
    //       repeat: ImageRepeat.repeat,
    //       fill: LayerFill.width,
    //     ),
    //     ParallaxImage('cloud.png', repeat: ImageRepeat.repeat),
    //   ],
    //   baseSpeed: Offset(0, defaultBgBaseSpeed),
    //   layerDelta: Offset(200, -400),
    // );

    //add(backgrounds);

    // final dragonSheet = SpriteSheet(
    //     image: 'dragon_sprite.png',
    //     textureWidth: 405,
    //     textureHeight: 400,
    //     columns: 7,
    //     rows: 1);

    player = SpriteAnimationComponent();
    player.animation = SpriteAnimation.fromFrameData(
        images.fromCache('dragon_sprite.png'),
        SpriteAnimationData.sequenced(
            amount: 1, stepTime: 1, textureSize: Vector2(405, 400)));
    add(player);

    // final planeSheet = SpriteSheet(
    //     imageName: 'plane.png',
    //     textureWidth: 400,
    //     textureHeight: 400,
    //     columns: 2,
    //     rows: 1);

    // plane = AnimationComponent.empty();
    // plane.animation = planeSheet.createAnimation(
    //     from: 0, to: 2, stepTime: 0.1, loop: true, row: 0);
    // add(plane);

    plane = SpriteAnimationComponent();
    player.animation = SpriteAnimation.fromFrameData(
        images.fromCache('plane.png'),
        SpriteAnimationData.sequenced(
            amount: 1, stepTime: 1, textureSize: Vector2(400, 400)));
    add(plane);

    food = SpriteComponent();
    food.sprite =
        Sprite(images.fromCache('food.png'), srcSize: Vector2(45, 53));
    add(food);

    number1 = SpriteComponent();
    number1.sprite =
        Sprite(images.fromCache('numbers/0.png'), srcSize: Vector2(50, 50));
    add(number1);

    number2 = SpriteComponent();
    number2.sprite =
        Sprite(images.fromCache('numbers/0.png'), srcSize: Vector2(50, 50));
    add(number2);

    gameOver = SpriteComponent();
    gameOver.sprite =
        Sprite(images.fromCache('gameover.png'), srcSize: Vector2(200, 200));
    add(gameOver);
    setPointsDisplay();

    backgrounds = await loadParallaxComponent([
      ParallaxImageData('water.png'),
      ParallaxImageData('cloud.png'),
    ]);
    add(backgrounds);
  }

  @override
  void onTapDown(TapDownInfo d) {
    double min = -20;
    double max = screenSize.width - 40;
    moveRight = (player.x - d.eventPosition.widget.x).floor() < 0;
    newX = moveRight ? max : min;
  }

  @override
  void onTapUp(TapUpInfo event) {
    // Do something in response to a tap event
  }

  void resize(Size size) {
    screenSize = size;
    double screenCenterX = screenSize.width / 2;
    playerSpeed = (screenSize.width / 200).ceil();
    backgrounds.width = size.width;
    backgrounds.height = size.height;

    food.x = getRandomX();
    food.y = -100;
    food.width = 45;
    food.height = 53;

    plane.x = getRandomX();
    plane.y = -30;
    plane.width = 120;
    plane.height = 120;

    player.width = 200;
    player.height = 200;
    player.y = size.height - player.height - 100;
    player.x = getRandomX();
    newX = player.x;

    number1.width = numberWH;
    number1.height = numberWH;
    number1.x = screenCenterX - number1.width / 2;
    number1.y = 100;
    add(number1);

    number2.width = numberWH;
    number2.height = numberWH;
    number2.x = (screenCenterX - (number1.width / 2)) - 40;
    number2.y = -400;
    add(number2);

    gameOver.width = 0;
    gameOver.height = 0;
    gameOver.x = screenCenterX - 100;
    gameOver.y = (screenSize.height / 2) - 100;
    add(gameOver);

    //super. size = size; TODO: resize
  }

  setPointsDisplay() {
    score = score < 0 ? 0 : score;
    final scoreAsStr = score.toString();

    if (score < 10) {
      number2.y = -400;
      number1.sprite = Sprite(images.fromCache('numbers/$score.png'),
          srcSize: Vector2(numberWH, numberWH));
    } else {
      number2.y = 100;
      number1.sprite = Sprite(images.fromCache('numbers/${scoreAsStr[1]}.png'),
          srcSize: Vector2(numberWH, numberWH));
      number2.sprite = Sprite(images.fromCache('numbers/${scoreAsStr[0]}.png'),
          srcSize: Vector2(numberWH, numberWH));
    }
  }

  void update(double t) {
    if (isGameOver()) {
      plane.width = plane.height = 0;
      food.width = food.height = 0;
      player.width = player.height = 0;
      gameOver.width = 200;
      gameOver.height = 200;
    }

    if (isFoodCollision()) {
      handleFoodCollision();
    } else if (isCrashing) {
      if (crashFrameCount-- <= 0) {
        isCrashing = false;
        crashFrameCount = 100;
        plane.width = 120;
        plane.height = 120;
        plane.y = -200;
        plane.angle = 0;

        player.width = 200;
        player.height = 200;
      } else {
        crashFrameCount--;
        plane.width -= 3;
        plane.height -= 3;
        plane.x -= 3;
        plane.y--;
        plane.angle--;

        player.width += getRandomX() % 2 == 0 ? -10 : 10;
        player.height += getRandomX() % 2 == 0 ? -10 : 10;
      }
    } else if (isPlaneCollision()) {
      handlePlaneCollision();
    }

    int defaultFoodSpeed = 6;
    int defaultPlaneSpeed = 8;

    //backgrounds.baseSpeed = Offset(0, defaultBgBaseSpeed + (score * 10)); TODO:
    if (player.x.floor() != newX.floor()) {
      if (moveRight) {
        if (player.x < screenSize.width) player.x += playerSpeed;
      } else {
        if (player.x > -20) player.x -= playerSpeed;
      }
    }

    if (food.y < screenSize.height) {
      food.y += score <= 0
          ? defaultFoodSpeed
          : defaultPlaneSpeed + (score / 2).floor();
    } else {
      food.y = 0;
      food.x = getRandomX();
      loopsDone++;
    }

    if (plane.y < screenSize.height) {
      plane.y += score <= 0
          ? defaultPlaneSpeed
          : defaultFoodSpeed + (score / 3).floor();
      plane.x += getRandomX() % 3 == 0 ? -1 : 1;
    } else {
      plane.y = 0;
      plane.x = getRandomX();
    }

    super.update(t);
  }
}
