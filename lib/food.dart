import 'dart:math';

import 'package:dragonpuppyfun/cgame.dart';
import 'package:dragonpuppyfun/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Food extends SpriteComponent with CollisionCallbacks, HasGameRef<CGame> {
  final double height;
  final double width;
  bool isCrashing = false;

  Food({required this.height, required this.width});

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // if (other is Player) {
    //   if (intersectionPoints.length == 2) {
    //     // Calculate the collision normal and separation distance.
    //     final mid = (intersectionPoints.elementAt(0) +
    //             intersectionPoints.elementAt(1)) /
    //         2;

    //     final collisionNormal = absoluteCenter - mid;
    //     final separationDistance = (size.x / 2) - collisionNormal.length;
    //     collisionNormal.normalize();
    //   }
    // }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is ScreenHitbox) {
    } else if (other is Player) {
      gameRef.score++;
      gameRef.setPointsDisplay();
      this.y = -100;
      this.x = gameRef.getRandomX();
    }

    super.onCollisionEnd(other);
  }

  @override
  void onLoad() {
    position = Vector2(gameRef.getRandomX(), -50);
    sprite =
        Sprite(gameRef.images.fromCache('food.png'), srcSize: Vector2(45, 53));
    add(RectangleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    int defaultFoodSpeed = max(1, (gameRef.canvasSize.y * 0.01).floor());

    if (this.y < gameRef.canvasSize.y) {
      this.y += gameRef.score <= 0
          ? defaultFoodSpeed
          : defaultFoodSpeed + (gameRef.score / 2).floor();
    } else {
      this.y = 0;
      this.x = gameRef.getRandomX();
      gameRef.loopsDone++;
    }
  }
}
