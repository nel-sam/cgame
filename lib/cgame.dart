import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class CGame extends BaseGame with TapDetector, HasWidgetsOverlay {
  Size screenSize;
  ParallaxComponent _parallaxComponent;
  SpriteComponent player;

  CGame() {
    _parallaxComponent = ParallaxComponent(
      [
        ParallaxImage(
          'water.png',
          repeat: ImageRepeat.repeat,
          alignment: Alignment.topCenter,
        ),
        ParallaxImage('cloud.png', repeat: ImageRepeat.repeat),
      ],
      baseSpeed: Offset(0, -200),
      layerDelta: Offset(20, -400),
    );

    add(_parallaxComponent);

    player = SpriteComponent.fromSprite(0, 0, Sprite('body.png'));
    add(player);
  }

  void resize(Size size) {
    screenSize = size;
    double screenCenterX = screenSize.width / 2;

    _parallaxComponent.width = size.width;
    _parallaxComponent.height = size.height;
    player.width = size.width / 4;
    player.height = size.height / 4;
    player.y = size.height - player.height - 100;
    player.x = screenCenterX - (player.width / 2);

    super.resize(size);
  }

  void update(double t) {
    super.update(t);
  }
}
