import 'dart:math';

import 'package:dragonpuppyfun/airplane.dart';
import 'package:dragonpuppyfun/food.dart';
import 'package:dragonpuppyfun/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class CGame extends FlameGame
    with MultiTouchTapDetector, HasCollisionDetection {
  late ParallaxComponent groundLayer;
  late ParallaxComponent cloudLayer;
  late SpriteAnimationComponent player;
  late SpriteAnimationComponent plane;
  late int crashFrameCount = 100;
  late SpriteComponent food;
  late SpriteComponent number1;
  late SpriteComponent number2;
  late int score = 0;
  late double defaultGroundLayerSpeed = -0.3;
  late double defaultCloudLayerSpeed = -2;
  late double numberWH = 50;
  late bool? moveRight = null;
  late int loopsDone = 0;
  late int maxLoops = 20;
  late SpriteComponent gameOver;
  late double playerHeight = 0;
  late double playerWidth = 0;
  late double planeWidth = 0;
  late double planeHeight = 0;
  late double playerMaxLeft = 0;
  late double playerMaxRight = 0;
  final double gameOverHW = 200;

  bool get isGameOver => loopsDone >= maxLoops;

  void doGameOverActions() {
    plane.width = plane.height = 0;
    food.width = food.height = 0;
    player.width = player.height = 0;
    gameOver.width = gameOverHW;
    gameOver.height = gameOverHW;
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

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    playerWidth = playerHeight = this.size.x * 0.45;
    planeWidth = planeHeight = this.size.x * 0.3;
    final foodHW = this.size.x * 0.05;

    playerMaxLeft = (0 - (playerWidth * 2)).floor().toDouble();
    playerMaxRight = (this.canvasSize.x).floor().toDouble();

    FlameAudio.bgm.initialize();
    await FlameAudio.loop(
      'music.mp3',
    ); // TODO: Audio doesn't stop when exiting to title screen

    await images.loadAllImages();

    groundLayer = await loadParallaxComponent(
      [ParallaxImageData('water.png')],
      baseVelocity: Vector2(0, defaultGroundLayerSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.width,
    );

    add(groundLayer);

    cloudLayer = await loadParallaxComponent(
      [ParallaxImageData('cloud.png')],
      baseVelocity: Vector2(0, defaultCloudLayerSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.height,
    );

    add(cloudLayer);

    number1 = SpriteComponent(
      sprite: Sprite(
        images.fromCache('numbers/0.png'),
        srcSize: Vector2(numberWH, numberWH),
      ),
      position: Vector2(20, 75),
    );
    add(number1);

    number2 = SpriteComponent(
      sprite: Sprite(images.fromCache('numbers/0.png'), srcSize: Vector2(0, 0)),
      position: Vector2(60, 75),
    );
    add(number2);

    plane = Airplane(height: planeHeight, width: planeWidth);
    add(plane);

    food = Food(height: foodHW, width: foodHW);
    add(food);

    player = Player(height: playerHeight, width: playerWidth);
    add(player);

    gameOver = SpriteComponent(
      sprite: Sprite(images.fromCache('gameover.png')),
      size: Vector2(0, 0),
      position: Vector2(
        (this.canvasSize.x / 2) - (gameOverHW / 2),
        (this.canvasSize.y / 2) - (gameOverHW / 2),
      ),
    );
    add(gameOver);

    setPointsDisplay();
  }

  @override
  void onTapDown(int _, TapDownInfo d) {
    moveRight =
        ((player.x + playerWidth / 2) - d.eventPosition.widget.x).floor() < 0;
  }

  setPointsDisplay() {
    score = score < 0 ? 0 : score;
    final scoreAsStr = score.toString();

    if (score < 10) {
      number1.sprite = Sprite(
        images.fromCache('numbers/$score.png'),
        srcSize: Vector2(numberWH, numberWH),
      );
      number2.width = 0;
      number2.height = 0;
    } else {
      number1.sprite = Sprite(
        images.fromCache('numbers/${scoreAsStr[1]}.png'),
        srcSize: Vector2(numberWH, numberWH),
      );
      number2.sprite = Sprite(
        images.fromCache('numbers/${scoreAsStr[0]}.png'),
        srcSize: Vector2(numberWH, numberWH),
      );
    }
  }

  void update(double t) {
    if (isGameOver) {
      doGameOverActions();
    } else {
      groundLayer.parallax?.baseVelocity = Vector2(
        0,
        defaultGroundLayerSpeed - (score * 0.02),
      );
      cloudLayer.parallax?.baseVelocity = Vector2(
        0,
        defaultCloudLayerSpeed - (score * 0.01),
      );
    }

    super.update(t);
  }
}
