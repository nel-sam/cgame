import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/material.dart';

class CGame extends BaseGame with TapDetector, HasWidgetsOverlay {
  Size screenSize;
  ParallaxComponent _parallaxComponent;
  AnimationComponent player;
  int newX;

  CGame() {
    _parallaxComponent = ParallaxComponent(
      [
        ParallaxImage(
          'water.png',
          repeat: ImageRepeat.repeat,
          fill: LayerFill.width,
        ),
        ParallaxImage('cloud.png', repeat: ImageRepeat.repeat),
      ],
      baseSpeed: Offset(0, -200),
      layerDelta: Offset(200, -400),
    );

    add(_parallaxComponent);

    final spriteSheet = SpriteSheet(
        imageName: 'dragon_sprite.png',
        textureWidth: (405),
        textureHeight: 400,
        columns: 7,
        rows: 1);

    player = AnimationComponent.empty();
    player.animation =
        spriteSheet.createAnimation(0, from: 0, to: 6, stepTime: 0.1);

    add(player);
  }

  void resize(Size size) {
    screenSize = size;
    double screenCenterX = screenSize.width / 2;

    _parallaxComponent.width = size.width;
    _parallaxComponent.height = size.height;
    player.width = 200;
    player.height = 200;
    player.y = size.height - player.height - 100;
    player.x = (screenCenterX - (player.width / 2)).floorToDouble();
    newX = player.x.floor();

    super.resize(size);
  }

  @override
  void onTapDown(TapDownDetails d) {
    newX = (d.localPosition.dx - (player.width / 2)).floor();
  }

  void update(double t) {
    if (player.x.floor() != newX) {
      final isRightMovement = player.x - newX < 0;
      if (isRightMovement) {
        player.x += 2;
      } else {
        player.x -= 2;
      }
    }

    super.update(t);
  }
}
