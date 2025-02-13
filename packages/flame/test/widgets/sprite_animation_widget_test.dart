import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'loading_widget.dart';

Future<void> main() async {
  final image = await generateImage();

  group('SpriteAnimationWidget', () {
    testWidgets('has no FutureBuilder when passed an animation',
        (tester) async {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image);
      final spriteAnimation = SpriteAnimation.spriteList(
        [sprite1, sprite2],
        stepTime: 0.1,
      );

      await tester
          .pumpWidget(SpriteAnimationWidget(animation: spriteAnimation));

      final futureBuilderFinder = find.byType(FutureBuilder);
      final spriteAnimationWidgetFinder = find.byType(SpriteAnimationWidget);

      expect(futureBuilderFinder, findsNothing);
      expect(spriteAnimationWidgetFinder, findsOneWidget);
    });

    testWidgets(
      'has FutureBuilder and LoadingWidget when passed an asset path',
      (tester) async {
        const imagePath = 'test_path';
        Flame.images.add(imagePath, image);
        final spriteAnimationData = SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 1,
          textureSize: Vector2(10, 10),
        );

        await tester.pumpWidget(
          SpriteAnimationWidget.asset(
            path: imagePath,
            data: spriteAnimationData,
            loadingBuilder: (_) => const LoadingWidget(),
          ),
        );

        final futureBuilderFinder = find.byType(FutureBuilder<SpriteAnimation>);
        final spriteAnimationWidgetFinder =
            find.byType(InternalSpriteAnimationWidget);
        final loadingWidgetFinder = find.byType(LoadingWidget);

        expect(futureBuilderFinder, findsOneWidget);
        expect(loadingWidgetFinder, findsOneWidget);
        expect(spriteAnimationWidgetFinder, findsNothing);

        /// loading to be removed
        await tester.pump();

        expect(futureBuilderFinder, findsOneWidget);
        expect(loadingWidgetFinder, findsNothing);
        expect(spriteAnimationWidgetFinder, findsOneWidget);
      },
    );
  });
}
