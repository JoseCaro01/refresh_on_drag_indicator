import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A customizable refresh indicator that triggers a callback when a drag
/// gesture is detected from the bottom edge of the scrollable content.
///
/// This widget wraps the child widget and listens for drag gestures. When the
/// drag exceeds a defined threshold, it triggers the `onTopRequestedLoad` or `onBottomRequestedLoad` callback
/// and displays a loader animation.
///
/// [RefreshOnDragIndicator] supports both iOS and Android platforms, handling
/// overscroll notifications appropriately for each.
///
/// The widget's behavior, animations, and appearance can be customized
/// through various parameters.
class RefreshOnDragIndicator extends StatefulWidget {
  /// Creates a [RefreshOnDragIndicator].
  ///
  /// [child] is the scrollable content wrapped by this widget.
  /// [onTopRequestedLoad] is the callback triggered when the drag exceeds the threshold.
  /// [returnDuration] defines the duration of the animation when the loader returns to its starting position.
  /// [topLoaderWidget] and [bottomLoaderWidget] is an optional widget displayed during the loading animation.
  /// [topStartPosition] and [topEndPosition] define the starting and ending positions
  /// [bottomStartPosition] and [bottomEndPosition] define the starting and ending positions
  /// of the loader widget during the drag animation.
  const RefreshOnDragIndicator({
    super.key,
    required this.child,
    required this.refreshDragType,
    this.onTopRequestedLoad,
    this.onBottomRequestedLoad,
    this.returnDuration = const Duration(milliseconds: 500),
    this.topLoaderWidget = const RefreshLoader(),
    this.bottomLoaderWidget = const RefreshLoader(),
    this.topStartPosition = -60,
    this.topEndPosition,
    this.bottomStartPosition = -60,
    this.bottomEndPosition,
  });

  /// The child widget wrapped by the refresh indicator.
  final Widget child;

  /// The drag type used for define what kind of drag can use.
  final RefreshDragEnum refreshDragType;

  /// Callback triggered when the drag exceeds the threshold and loading is initiated.
  final Future<void> Function()? onTopRequestedLoad;

  /// Callback triggered when the drag exceeds the threshold and loading is initiated.
  final Future<void> Function()? onBottomRequestedLoad;

  /// Optional widget displayed during the loading animation at top.
  ///
  /// Defaults to a simple [RefreshLoader] widget if not provided.
  final Widget topLoaderWidget;

  /// Optional widget displayed during the loading animation at bottom.
  ///
  /// Defaults to a simple [RefreshLoader] widget if not provided.
  final Widget bottomLoaderWidget;

  /// The starting position of the loader widget during the drag animation.
  ///
  /// Defaults to `-60` if not specified.
  final double topStartPosition;

  /// The ending position of the loader widget during the drag animation.
  ///
  /// Defaults to 1/8 of the screen height if not specified.
  final double? topEndPosition;

  /// The starting position of the loader widget during the drag animation.
  ///
  /// Defaults to `-60` if not specified.
  final double bottomStartPosition;

  /// The ending position of the loader widget during the drag animation.
  ///
  /// Defaults to 1/8 of the screen height if not specified.
  final double? bottomEndPosition;

  /// The duration of the animation when the loader returns to its starting position.
  ///
  /// Defaults to 500 milliseconds.
  final Duration returnDuration;

  @override
  State<RefreshOnDragIndicator> createState() => _RefreshOnDragIndicatorState();
}

class _RefreshOnDragIndicatorState extends State<RefreshOnDragIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final ValueNotifier<double> _drag;
  late final ValueNotifier<bool?> _isBottomOverscroll;
  late bool _startAnimation;
  late bool _isEdge;
  late bool _isLoading;
  double? _initialDrag;

  double get _defaultEndPosition =>
      (WidgetsBinding
              .instance.platformDispatcher.views.first.display.size.height /
          WidgetsBinding.instance.platformDispatcher.views.first.display
              .devicePixelRatio) /
      8;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    _drag.dispose();
    _isBottomOverscroll.dispose();
    _animationController
      ..removeListener(_onAnimationUpdate)
      ..dispose();
    super.dispose();
  }

  /// Initializes state variables and configures the animation controller.
  void _initData() {
    _drag = ValueNotifier(0.0);
    _isBottomOverscroll = ValueNotifier(null);
    _startAnimation = false;
    _isEdge = false;
    _isLoading = false;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.returnDuration,
    )..addListener(_onAnimationUpdate);
  }

  /// Handles pointer-up events, triggers the loading callback if the drag exceeds
  /// the threshold, and animates the loader back to its starting position.
  Future<void> _handlePointerUp() async {
    _startAnimation = false;
    _isEdge = false;
    _initialDrag = null;
    if (_isBottomOverscroll.value == null) return;

    if (_drag.value >=
        (_isBottomOverscroll.value!
            ? widget.bottomEndPosition ?? _defaultEndPosition
            : widget.topEndPosition ?? _defaultEndPosition)) {
      _isBottomOverscroll.value!
          ? await widget.onBottomRequestedLoad?.call()
          : await widget.onTopRequestedLoad?.call();
    }
    if (_drag.value > 0.0) _animateToZero();
  }

  /// Handles pointer-move events, updating the drag value based on the user's gesture.
  void _handlePointerMove(PointerMoveEvent event) {
    if (_initialDrag == event.position.dy) return;

    if (_isEdge && _startAnimation) {
      _isBottomOverscroll.value ??= _initialDrag! > event.position.dy;

      final endPosition = _isBottomOverscroll.value!
          ? widget.bottomEndPosition ?? _defaultEndPosition
          : widget.topEndPosition ?? _defaultEndPosition;

      // If we're already at the final position, do nothing
      if (_drag.value == endPosition) return;

      // Calculate the movement delta
      final delta = _isBottomOverscroll.value!
          ? _initialDrag! - event.position.dy
          : event.position.dy - (_initialDrag ?? event.position.dy);

      _initialDrag = event.position.dy;
      _drag.value = (_drag.value + delta).clamp(0, endPosition);
    }
  }

  /// Animates the loader back to its starting position using a smooth animation.
  void _animateToZero() {
    if (_animationController.isAnimating) return;

    _animationController.value = _drag.value /
        (_isBottomOverscroll.value!
            ? widget.bottomEndPosition ?? _defaultEndPosition
            : widget.topEndPosition ??
                _defaultEndPosition); // Normalizes the range.

    _animationController.animateTo(
      0.0, // Target position.
      duration: widget.returnDuration, // Animation duration.
      curve: Curves.easeOut, // Smooth easing curve.
    );
  }

  /// Updates the drag value as the animation progresses.
  void _onAnimationUpdate() {
    _drag.value = _animationController.value *
        (_isBottomOverscroll.value!
            ? widget.bottomEndPosition ?? _defaultEndPosition
            : widget.topEndPosition ?? _defaultEndPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (_isLoading ||
            _animationController.isAnimating ||
            widget.refreshDragType == RefreshDragEnum.none) {
          return;
        }
        _initialDrag ??= event.position.dy;
        _isBottomOverscroll.value = null;
        _startAnimation = true;
      },
      onPointerUp: (_) => _handlePointerUp(),
      onPointerMove: _handlePointerMove,
      child: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (_startAnimation) {
                  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
                  final isAndroid =
                      defaultTargetPlatform == TargetPlatform.android;

                  if ((isIOS && notification.metrics.outOfRange) ||
                      (isAndroid && notification is OverscrollNotification)) {
                    final pixels = notification.metrics.pixels;
                    final isNegative = isIOS
                        ? pixels.isNegative
                        : (notification as OverscrollNotification)
                            .overscroll
                            .isNegative;

                    final isTopOverscroll = isNegative &&
                        (widget.refreshDragType == RefreshDragEnum.top ||
                            widget.refreshDragType == RefreshDragEnum.both);

                    final isBottomOverscroll = !isNegative &&
                        (widget.refreshDragType == RefreshDragEnum.bottom ||
                            widget.refreshDragType == RefreshDragEnum.both);

                    _isEdge = isTopOverscroll || isBottomOverscroll;
                  }
                }
                return true;
              },
              child: widget.child,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _isBottomOverscroll,
            builder: (context, isBottom, child) => ValueListenableBuilder(
              valueListenable: _drag,
              builder: (context, value, child) {
                if (isBottom ?? false) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: widget.bottomStartPosition +
                        value.clamp(
                            0, widget.bottomEndPosition ?? _defaultEndPosition),
                    child: Visibility(
                        visible: isBottom ?? false,
                        child: widget.bottomLoaderWidget),
                  );
                }
                return Positioned(
                  left: 0,
                  right: 0,
                  top: widget.topStartPosition +
                      value.clamp(
                          0, widget.topEndPosition ?? _defaultEndPosition),
                  child: Visibility(
                      visible: isBottom != null && !isBottom,
                      child: widget.topLoaderWidget),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RefreshLoader extends StatelessWidget {
  const RefreshLoader({
    this.backgroundColor = Colors.white,
    this.color = Colors.blue,
    this.diameter = 30,
    this.shape = BoxShape.circle,
    this.shadow = const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.24),
        blurRadius: 8,
        spreadRadius: 0,
        offset: Offset(
          0,
          3,
        ),
      )
    ],
    this.strokeWidth = 3.0,
    super.key,
  });
  final Color backgroundColor;
  final Color color;
  final double diameter;
  final BoxShape shape;
  final List<BoxShadow> shadow;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: diameter,
          height: diameter,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: backgroundColor, shape: shape, boxShadow: shadow),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: color,
            ),
          )),
    );
  }
}

enum RefreshDragEnum { top, bottom, both, none }
