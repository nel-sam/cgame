import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class CGame extends Game {
  Size screenSize;
  SpriteComponent bgSprite;
  SpriteComponent player;

  CGame() {
    bgSprite = SpriteComponent.fromSprite(0, 0, Sprite('water.jpeg'));
    player = SpriteComponent.fromSprite(0, 0, Sprite('body.png'));
  }

  void resize(Size size) {
    screenSize = size;
    double screenCenterX = screenSize.width / 2;

    bgSprite.width = size.width;
    bgSprite.height = size.height;
    player.width = size.width / 4;
    player.height = size.height / 4;
    player.y = size.height - player.height - 100;
    player.x = screenCenterX - (player.width / 2);

    super.resize(size);
  }

  void render(Canvas canvas) {
    bgSprite.render(canvas);
    player.render(canvas);
  }

  void update(double t) {
    // TODO: implement update
  }
}
