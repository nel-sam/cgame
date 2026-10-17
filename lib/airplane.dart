import 'dart:math';

import 'package:dragonpuppyfun/cgame.dart';
import 'package:dragonpuppyfun/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Airplane extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<CGame> {
  final double height;
  final double width;
  bool isCrashing = false;
  bool isMovingRight = true;

  Airplane({required this.height, required this.width});

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) / 2;

        final collisionNormal = absoluteCenter - mid;
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
      game.images.fromCache('plane.png'),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.1,
        textureSize: Vector2(405, 400),
      ),
    );

    size = Vector2(this.width, this.height);
    position = Vector2(game.canvasSize.x / 2 - 100, 10);

    //add(RectangleHitbox(collisionType: CollisionType.active));
    add(
      RectangleHitbox(
        size: Vector2(width * 0.3, height * 0.3),
        position: Vector2(width * 0.05, height * 0.05),
      ),
    );
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
      int movementAmount = 1 + (game.score / 2).floor();
      int defaultPlaneSpeed = max(1, (game.canvasSize.y * 0.008).floor());
      bool planeIsOnScreenY = this.y < game.canvasSize.y;
      bool planeIsOnScreenX =
          this.x < game.canvasSize.x - this.width && this.x > 0;
      int planeSpeed = defaultPlaneSpeed + (game.score / 2).floor();

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
        this.x = game.getRandomX();
      }
    }

    super.update(dt);
  }
}
