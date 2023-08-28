import 'package:dragonpuppyfun/airplane.dart';
import 'package:dragonpuppyfun/cgame.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<CGame> {
  final double height;
  final double width;
  int crashFrameCount = 100;
  bool isCrashing = false;

  Player({required this.height, required this.width});

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Airplane) {
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
    } else if (other is Airplane) {
      this.isCrashing = true;
    }

    super.onCollisionEnd(other);
  }

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache('dragon_sprite.png'),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: 0.1,
        textureSize: Vector2(405, 400),
      ),
    );

    size = Vector2(this.width, this.height);
    position =
        Vector2(gameRef.canvasSize.x / 2 - 100, gameRef.canvasSize.y - 230);

    add(RectangleHitbox(collisionType: CollisionType.active));
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
    }

    super.update(dt);
  }
}
