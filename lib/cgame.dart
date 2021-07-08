import 'dart:math';
import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

class CGame extends BaseGame with TapDetector, HasWidgetsOverlay {
  Size screenSize;
  ParallaxComponent backgrounds;
  AnimationComponent player;
  AnimationComponent plane;
  bool isCrashing = false;
  int crashFrameCount = 100;
  SpriteComponent food;
  int newX;
  int score = 0;
  TextComponent text;
  double defaultBgBaseSpeed = -200;

  CGame() {
    backgrounds = ParallaxComponent(
      [
        ParallaxImage(
          'water.png',
          repeat: ImageRepeat.repeat,
          fill: LayerFill.width,
        ),
        ParallaxImage('cloud.png', repeat: ImageRepeat.repeat),
      ],
      baseSpeed: Offset(0, defaultBgBaseSpeed),
      layerDelta: Offset(200, -400),
    );

    add(backgrounds);

    final dragonSheet = SpriteSheet(
        imageName: 'dragon_sprite.png',
        textureWidth: 405,
        textureHeight: 400,
        columns: 7,
        rows: 1);

    player = AnimationComponent.empty();
    player.animation =
        dragonSheet.createAnimation(0, from: 0, to: 6, stepTime: 0.1);
    add(player);

    final planeSheet = SpriteSheet(
        imageName: 'plane.png',
        textureWidth: 400,
        textureHeight: 400,
        columns: 2,
        rows: 1);

    plane = AnimationComponent.empty();
    plane.animation = planeSheet.createAnimation(0,
        from: 0, to: 2, stepTime: 0.1, loop: true);
    add(plane);

    food = SpriteComponent();
    food.sprite = Sprite('food.png', height: 53, width: 45);
    add(food);

    text = TextComponent(
      getPointsDisplay(),
      config: TextConfig(fontSize: 50, color: Colors.white),
    );
    add(text);
  }

  getPointsDisplay() {
    if (score == 1) return '1 point';
    if (score <= 0) score = 0;

    return '$score points';
  }

  void resize(Size size) {
    screenSize = size;
    double screenCenterX = screenSize.width / 2;

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
    newX = player.x.floor();

    text.x = screenCenterX - 50;
    text.y = 50;

    super.resize(size);
  }

  @override
  void onTapDown(TapDownDetails d) {
    newX = (d.localPosition.dx - (player.width / 2)).floor();
  }

  void update(double t) {
    if (foodCollision()) {
      handleFoodCollision();
    } else if (isCrashing) {
      if (crashFrameCount-- <= 0) {
        isCrashing = false;
        crashFrameCount = 100;
        plane.width = 120;
        plane.height = 120;
        plane.y = -200;
        plane.angle = 0;
      } else {
        crashFrameCount--;
        plane.width -= 3;
        plane.height -= 3;
        plane.x -= 3;
        plane.angle--;
      }
    } else if (planeCollision()) {
      handlePlaneCollision();
    }

    int defaultPlayerSpeed = 2;
    int defaultFoodSpeed = 6;
    int defaultPlaneSpeed = 8;

    backgrounds.baseSpeed = Offset(0, defaultBgBaseSpeed + (score * 10));
    if (player.x.floor() != newX) {
      final isRightMovement = player.x - newX < 0;
      if (isRightMovement) {
        player.x += defaultPlayerSpeed;
      } else {
        player.x -= defaultPlayerSpeed;
      }
    }

    if (food.y < screenSize.height) {
      food.y += score <= 0
          ? defaultFoodSpeed
          : defaultPlaneSpeed + (score / 2).floor();
    } else {
      food.y = 0;
      food.x = getRandomX();
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

  void handlePlaneCollision() {
    score--;
    text.text = getPointsDisplay();
    isCrashing = true;
  }

  void handleFoodCollision() {
    score++;
    text.text = getPointsDisplay();
    food.y = -100;
    food.x = getRandomX();
  }

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

  bool foodCollision() {
    int xDist = (player.x - food.x).abs().toInt();
    bool inYRange = food.y >= player.y && (food.y + food.height) >= player.y;
    return xDist < (food.width / 2) && inYRange;
  }

  bool planeCollision() {
    int xDist = (player.x - plane.x).abs().toInt();
    bool inYRange = plane.y >= player.y && (plane.y + plane.height) >= player.y;
    return xDist < (plane.width / 2) && inYRange;
  }
}
