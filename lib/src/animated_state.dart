import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'animation.dart';
import 'dart_utilities.dart';

typedef TweenVisitor = void Function(Tween<dynamic> tween, dynamic targetValue);
typedef ForEachTween = void Function(TweenVisitor visitor);

mixin AnimatedStateMixin<T extends StatefulWidget> on TickerProviderStateMixin<T> {
  static final completedAnimation = Shared(const CompletedAnimation());
  final List<Shared<Animation<double>>> _animations = [];
  final Map<Tween, Shared<Animation<double>>> _animationMap = {};

  Iterable<AnimationController> get _allControllers sync* {
    for (final animation in _animations)
      yield animation.get() as AnimationController;
    List<AnimationController> mapControllers = [];
    for (final animation in _animationMap.values)
      if (animation.get() is AnimationController) {
        final controller = animation.get() as AnimationController;
        if (!mapControllers.contains(controller)) {
          mapControllers.add(controller);
          yield controller; 
        }
      }
  } 

  Duration? _animationDuration;
  set animationDuration(Duration duration) {
    if (duration == _animationDuration) return;
    _animationDuration = duration;
    for (final controller in _allControllers) {
      if (controller.duration != duration) {
        controller.duration = duration;
        controller.stop();
        controller.forward();
      }
    }
  }
  Duration get animationDuration {
    assert(_animationDuration != null, 'You should set animationDuration before animating.');
    return _animationDuration!;
  }

  bool _shouldUpdateTweens = false;
  static const bool forceAlwaysUpdateTweens = false;

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _shouldUpdateTweens = true;
  }

  /// Call this to update tweens with new target values. This will
  /// trigger an animation. Update [animationDuration] before updating 
  /// tweens.
  ///
  /// This actually updates only after [didUpdateWidget], assuming
  /// that target values can only be changed due to widget updates.
  /// You can override this globally by setting [forceAlwaysUpdateTweens]
  /// to true.
  ///
  /// Note that animating already animated value would extend 
  /// an animation's duration and change its curve.
  void updateTweens(ForEachTween forEachTween) {
    Shared<Animation<double>>? animation;
    if (_animationMap.isEmpty) {
      forEachTween((tween, targetValue) {
        tween.end = tween.begin = targetValue;
        _animationMap[tween] = completedAnimation;
        completedAnimation.useCount++;
      });
    } else {   
      if (forceAlwaysUpdateTweens || _shouldUpdateTweens) {
        forEachTween((tween, targetValue) {
          if (tween.end != targetValue) {
            final _animation = _animationMap[tween]!;
            _animation.useCount--;
            final _animationValue = _animation.get().value;
            if (_animation.useCount == 0 && _animation.get() is AnimationController) {
              if (kDebugMode) {
                int animationsLength = _animations.length;
                (_animation.get() as AnimationController).value = 1.0;
                assert(_animations.length == animationsLength + 1);
              } else {
                (_animation.get() as AnimationController).value = 1.0;
              }
            }
            animation ??= _getAvailableAnimation(animationDuration);
            _animationMap[tween] = animation!;
            animation!.useCount++;
            tween.begin = tween.transform(_animationValue);
            tween.end = targetValue;
          }
        });

        if (animation != null) {
          assert(animation!.get() is AnimationController);
          (animation!.get() as AnimationController).forward(from: 0.0);
        } 

        _shouldUpdateTweens = false;
      }
    }
  }

  Shared<Animation<double>> _getAvailableAnimation(Duration animationDuration) {
    if (_animations.isEmpty) {
      final animation = Shared<Animation<double>>(
        AnimationController(
          duration: animationDuration,
          vsync: this,
        )
        ..addListener(() => setState(() { }))
      );

      animation.get().addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationMap.updateAll((key, value) {
            return value == animation ? completedAnimation : value;
          });
          animation.useCount = 0;
          _animations.add(animation);
        }
      });
      return animation;
    } else {
      return _animations.removeLast();
    }
  }

  U evaluate<U>(Tween<U> tween) {
    final animation = _animationMap[tween];
    assert(animation != null);
    return tween.evaluate(animation!.get());
  }

  @override
  void dispose() {
    for (final controller in _allControllers)
      controller.dispose();
    super.dispose();
  }
}