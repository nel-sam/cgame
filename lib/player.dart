import 'dart:math';

import 'package:dragonpuppyfun/airplane.dart';
import 'package:dragonpuppyfun/cgame.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<CGame> {
  final double height;
  final double width;
  bool isCrashing = false;

  Player({required this.height, required this.width});

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Airplane) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid =
            (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;
        final collisionNormal = absoluteCenter - mid;
        collisionNormal.normalize();
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is ScreenHitbox) {
    } else if (other is Airplane) {
      isCrashing = true;
      game.score--;
      game.setPointsDisplay();
    }

    super.onCollisionEnd(other);
  }

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('dragon_sprite.png'),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: 0.1,
        textureSize: Vector2(405, 400),
      ),
    );

    size = Vector2(this.width, this.height);
    position = Vector2(game.canvasSize.x / 2 - 100, game.canvasSize.y - 230);

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
      } else {
        size.x -= 3;
        size.y -= 3;
      }
    } else {
      int defaultPlayerSpeed = max(1, (game.canvasSize.y * 0.006).floor());
      final moveRight = game.moveRight;

      if (moveRight == null) return;

      if (moveRight) {
        if (this.x < game.playerMaxRight) {
          this.x += defaultPlayerSpeed;
        }
      } else {
        if (this.x > game.playerMaxLeft) {
          this.x -= defaultPlayerSpeed;
        }
      }
    }

    super.update(dt);
  }
}
