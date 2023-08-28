import 'package:dragonpuppyfun/cgame.dart';
import 'package:dragonpuppyfun/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Airplane extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<CGame> {
  final double height;
  final double width;

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

  void onLoad() {
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
}
