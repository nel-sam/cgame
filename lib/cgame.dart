import 'dart:math';

import 'package:dragonpuppyfun/airplane.dart';
import 'package:dragonpuppyfun/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class CGame extends FlameGame with TapDetector, HasCollisionDetection {
  late ParallaxComponent groundLayer;
  late ParallaxComponent cloudLayer;
  late SpriteAnimationComponent player;
  late SpriteAnimationComponent plane;
  late bool isCrashing = false;
  late int crashFrameCount = 100;
  late SpriteComponent food;
  late SpriteComponent number1;
  late SpriteComponent number2;
  late int score = 0;
  late double defaultBgBaseSpeed = -0.4;
  late double numberWH = 50;
  late bool? moveRight = null;
  late int loopsDone = 0;
  late int maxLoops = 25;
  late SpriteComponent gameOver;
  late double playerHeight = 0;
  late double playerWidth = 0;
  late double planeWidth = 0;
  late double planeHeight = 0;
  late double playerMaxLeft = 0;
  late double playerMaxRight = 0;

  bool get isGameOver => loopsDone >= maxLoops;

  void doCrashAnimations() {
    crashFrameCount--;
    plane.width -= 2;
    plane.height -= 2;
    plane.angle--;

    playerWidth -= 1;
    playerHeight -= 1;
  }

  void doGameOverActions() {
    plane.width = plane.height = 0;
    food.width = food.height = 0;
    playerWidth = playerHeight = 0;
    gameOver.width = 200;
    gameOver.height = 200;
  }

  void doPostCrashActions() {
    isCrashing = false;
    crashFrameCount = 100;
    plane.width = playerWidth;
    plane.height = playerHeight;
    plane.y = -playerHeight + 20;
    plane.width = planeWidth;
    plane.height = planeHeight;
    plane.angle = 0;
  }

  double getRandomX() {
    try {
      Random rnd;
      int min = 40;
      int max = this.canvasSize.x.toInt() - 60;
      rnd = new Random();
      int num = (min + rnd.nextInt(max - min));

      return num.toDouble();
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
    double playerCenterX = player.x + (playerWidth / 2);
    double playerMinY = player.y;
    double playerMaxY = player.y + playerHeight;

    double foodCenterX = food.x + (food.width / 2);
    double foodMinY = food.y;
    double foodMaxY = food.y + food.height;

    bool inXRange =
        (playerCenterX - foodCenterX).abs().toInt() < food.width / 2;
    bool inYRange = foodMinY >= playerMinY && foodMaxY <= playerMaxY;
    return inXRange && inYRange;
  }

  bool isPlaneCollision() {
    int xDist = (player.x - plane.x).abs().toInt();
    bool inYRange = (plane.y + planeHeight) >= player.y &&
        (plane.y + planeHeight) <= (player.y + playerHeight);
    return xDist < (planeWidth / 2) && inYRange;
  }

  moveFood() {
    int defaultFoodSpeed = max(1, (this.canvasSize.y * 0.01).floor());

    if (food.y < this.canvasSize.y) {
      food.y += score <= 0
          ? defaultFoodSpeed
          : defaultFoodSpeed + (score / 2).floor();
    } else {
      food.y = 0;
      food.x = getRandomX();
      loopsDone++;
    }
  }

  movePlane() {
    int defaultPlaneSpeed = max(1, (this.canvasSize.y * 0.008).floor());
    bool planeIsOnScreen = plane.y < this.canvasSize.y;
    int planeSpeed = (score / 3).floor();

    planeSpeed = planeSpeed <= 0 ? defaultPlaneSpeed : planeSpeed;

    if (planeIsOnScreen) {
      plane.y += planeSpeed;
      plane.x += Random().nextInt(3) % 3 == 0 ? -1 : 1;
    } else {
      plane.y = 0 - plane.height;
      plane.x = getRandomX();
    }
  }

  movePlayer() {
    int defaultPlayerSpeed = max(1, (this.canvasSize.y * 0.008).floor());

    if (moveRight == null) return;

    if (moveRight!) {
      if (player.x < playerMaxRight) {
        player.x += defaultPlayerSpeed;
      }
    } else {
      if (player.x > playerMaxLeft) {
        player.x -= defaultPlayerSpeed;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    playerWidth = playerHeight = this.size.x * 0.45;
    planeWidth = planeHeight = this.size.x * 0.3;

    playerMaxLeft = (0 - (playerWidth * 2)).floor().toDouble();
    playerMaxRight = (this.canvasSize.x).floor().toDouble();

    FlameAudio.bgm.initialize();
    await FlameAudio.loop(
        'music.mp3'); // TODO: Audio doesn't stop when exiting to title screen

    await images.loadAllImages();

    groundLayer = await loadParallaxComponent(
      [ParallaxImageData('water.png')],
      baseVelocity: Vector2(0, defaultBgBaseSpeed), // TODO: this is too fast
      repeat: ImageRepeat.repeat,
      fill:
          LayerFill.height, // TODO: The ground layer is not repeating correctly
    );

    add(groundLayer);

    cloudLayer = await loadParallaxComponent(
      [ParallaxImageData('cloud.png')],
      baseVelocity: Vector2(
          0, defaultBgBaseSpeed), // TODO: make parallax effect more intense
      repeat: ImageRepeat.repeat,
      fill: LayerFill.height,
    );

    add(cloudLayer);

    food = SpriteComponent(
        position: Vector2(50, 50),
        sprite: Sprite(images.fromCache('food.png'), srcSize: Vector2(45, 53)));
    add(food);

    number1 = SpriteComponent();
    number1.sprite = Sprite(images.fromCache('numbers/0.png'),
        srcSize: Vector2(50, 50), srcPosition: Vector2(50, 50));
    add(number1);

    number2 = SpriteComponent();
    number2.sprite = Sprite(images.fromCache('numbers/0.png'),
        srcSize: Vector2(50, 50), srcPosition: Vector2(50, 50));
    add(number2);

    plane = Airplane(height: planeHeight, width: planeWidth);
    add(plane);

    gameOver = SpriteComponent();
    gameOver.sprite = Sprite(images.fromCache('gameover.png'),
        srcSize: Vector2(0, 0), srcPosition: Vector2(-999, -999));
    add(gameOver);

    player = Player(height: playerHeight, width: playerWidth);
    add(player);

    setPointsDisplay();
  }

  @override
  void onTapDown(TapDownInfo d) {
    moveRight =
        ((player.x + playerWidth / 2) - d.eventPosition.widget.x).floor() < 0;
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
    if (isGameOver) {
      doGameOverActions();
    } else if (isFoodCollision()) {
      handleFoodCollision();
    }
    // else if (isCrashing) {
    //   var isCrashDone = crashFrameCount-- <= 0;

    //   if (isCrashDone) {
    //     doPostCrashActions();
    //     return;
    //   } else {
    //     doCrashAnimations();
    //   }
    // }
    // else if (isPlaneCollision()) {
    //   handlePlaneCollision();
    // }
    else {
      // groundLayer.parallax?.baseVelocity =
      //     Vector2(0, defaultBgBaseSpeed - (score * 0.1));
      // cloudLayer.parallax?.baseVelocity =
      //     Vector2(0, defaultBgBaseSpeed - (score * 0.1));

      movePlayer();
      moveFood();
      movePlane();
    }

    super.update(t);
  }
}
