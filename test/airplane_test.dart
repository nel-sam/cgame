import 'dart:ui' as ui;

import 'package:dragonpuppyfun/airplane.dart';
import 'package:dragonpuppyfun/cgame.dart';
import 'package:dragonpuppyfun/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnusedContext extends Fake implements BuildContext {}

class _TestGame extends CGame {
  _TestGame() : super(_UnusedContext());

  @override
  double getRandomX() => 120;
}

class _TestAirplane extends Airplane {
  @override
  final CGame game;

  _TestAirplane(this.game) : super(height: 90, width: 90);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestGame game;
  late Airplane plane;
  late Player player;
  late ui.Image image;

  setUp(() async {
    game = _TestGame();
    game.onGameResize(Vector2(400, 800));
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final picture = recorder.endRecording();
    image = await picture.toImage(810, 400);
    picture.dispose();
    game.images.add('plane.png', image);
    plane = _TestAirplane(game);
    plane.onLoad();
    plane.position = Vector2(120, 700);
    player = Player(height: 180, width: 180);
  });

  tearDown(() {
    game.images.clearCache();
  });

  test('airplane cannot collide while its crash animation plays', () {
    plane.onCollisionEnd(player);
    plane.update(1 / 60);

    expect(plane.isCrashing, isTrue);
    expect(plane.angle, greaterThan(0));
    expect(
      plane.children.whereType<RectangleHitbox>().single.collisionType,
      CollisionType.inactive,
    );
  });

  test('crashed airplane respawns above the screen, not on the player', () {
    plane.onCollisionEnd(player);
    for (var frame = 0; frame < 31; frame++) {
      plane.update(1 / 60);
    }

    expect(plane.isCrashing, isFalse);
    expect(plane.size, Vector2(90, 90));
    expect(plane.angle, 0);
    expect(plane.position, Vector2(120, -90));
    expect(
      plane.children.whereType<RectangleHitbox>().single.collisionType,
      CollisionType.active,
    );

    plane.update(1 / 60);
    expect(plane.isCrashing, isFalse);
    expect(plane.y, greaterThan(-90));
    expect(plane.y, lessThan(0));
  });

  test('normal off-screen airplane still respawns above the screen', () {
    plane.y = game.canvasSize.y;
    plane.update(1 / 60);

    expect(plane.position, Vector2(120, -90));
    expect(plane.isCrashing, isFalse);
  });
}
