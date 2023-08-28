import 'dart:math';

import 'package:dragonpuppyfun/cgame.dart';
import 'package:dragonpuppyfun/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Airplane extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<CGame> {
  final double height;
  final double width;
  int crashFrameCount = 100;
  bool isCrashing = false;
  bool isMovingRight = true;

  Airplane({required this.height, required this.width});

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is ScreenHitbox) {
    } else if (other is Player) {
      isCrashing = true;
    }

    super.onCollisionEnd(other);
  }

  void onLoad() {
    isMovingRight = Random().nextBool();

    animation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache('plane.png'),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.1,
        textureSize: Vector2(405, 400),
      ),
    );

    size = Vector2(this.width, this.height);
    position = Vector2(gameRef.canvasSize.x / 2 - 100, 10);

    add(RectangleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    if (isCrashing) {
      if (size.x <= 0) {
        isCrashing = false;
        size.x = width;
        size.y = height;
        angle = 0;
      } else {
        size.x -= 3;
        size.y -= 3;
        angle += 1;
      }
    } else {
      int movementAmount = 1 + (gameRef.score / 2).floor();
      int defaultPlaneSpeed = max(1, (gameRef.canvasSize.y * 0.008).floor());
      bool planeIsOnScreenY = this.y < gameRef.canvasSize.y;
      bool planeIsOnScreenX =
          this.x < gameRef.canvasSize.x - this.width && this.x > 0;
      int planeSpeed = defaultPlaneSpeed + (gameRef.score / 2).floor();

      planeSpeed = planeSpeed <= 0 ? defaultPlaneSpeed : planeSpeed;

      if (planeIsOnScreenY) {
        this.y += planeSpeed;

        if (planeIsOnScreenX) {
          this.x += isMovingRight ? movementAmount : -movementAmount;
        } else if (!planeIsOnScreenX && this.x < this.width) {
          isMovingRight = true;
          this.x += movementAmount;
        } else {
          isMovingRight = false;
          this.x -= movementAmount;
        }
      } else {
        this.y = 0 - this.height;
        this.x = gameRef.getRandomX();
      }
    }

    super.update(dt);
  }
}
