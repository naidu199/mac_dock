import 'package:flutter/material.dart';
import 'dart:ui';

/// The entry point of the Flutter application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application [MyApp] material app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

/// [HomePage] Home page of the application.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // A Mac-style dock with interactive icons.
            MacDock<IconData>(
              items: const [
                Icons.person,
                Icons.message,
                Icons.call,
                Icons.camera,
                Icons.photo,
              ],
              builder: (item, scale) {
                return Container(
                  width: scale * 42,
                  height: scale * 41,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors
                        .primaries[item.hashCode % Colors.primaries.length],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      item,
                      color: Colors.white,
                      size: 24 * scale * 0.8,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}

/// A Mac-style dock widget that displays a list of items with hover and dragging effects.
///
/// The [MacDock] widget allows users to interact with items in a dock-like interface.
/// Items can be hovered over to scale up and dragged to reorder their positions with animations.
///
/// Example:
/// ```dart
/// MacDock<IconData>(
///   items: const [Icons.person, Icons.message, Icons.call],
///   builder: (item, scale) {
///     return Icon(item, size: 24 * scale);
///   },
/// );
/// ```
class MacDock<T extends Object> extends StatefulWidget {
  /// Creates a [MacDock] widget.
  ///
  /// - [items]: The list of items to display in the dock.
  /// - [builder]: A function that builds the widget for each item.
  const MacDock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// The list of items to display in the dock.
  final List<T> items;

  /// A function that builds the widget for each item.
  ///
  /// - [item]: The current item to build.
  /// - [scale]: The scale factor to apply to the item based on hover and dragging state.
  final Widget Function(T item, double scale) builder;

  @override
  State<MacDock<T>> createState() => MacDockState<T>();
}

/// The state class for [MacDock].
class MacDockState<T extends Object> extends State<MacDock<T>> {
  late final List<T> items = widget.items.toList();
  int? _hoveredIndex;
  int? _draggedIndex;

  /// Calculates the size and position of an item based on its distance from the hovered item.
  ///
  /// - [index]: The index of the current item.
  /// - [initVal]: The initial value (used when the item is not hovered).
  /// - [maxVal]: The maximum value (used when the item is hovered).
  /// - [nonHoverMaxVal]: The value for items near the hovered item.
  double calculatedItemValue({
    required int index,
    required double initVal,
    required double maxVal,
    required double nonHoverMaxVal,
  }) {
    if (_hoveredIndex == null) {
      return initVal;
    }

    final distance = (_hoveredIndex! - index).abs();
    final itemsAffected = items.length;

    if (distance == 0) {
      return maxVal;
    } else if (distance == 1) {
      return lerpDouble(initVal, maxVal, 0.75)!;
    } else if (distance == 2) {
      return lerpDouble(initVal, maxVal, 0.5)!;
    } else if (distance < 3 && distance <= itemsAffected) {
      return lerpDouble(initVal, nonHoverMaxVal, .25)!;
    } else {
      return initVal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((val) {
          final index = val.key;
          final item = val.value;

          final calculatedSize = calculatedItemValue(
            index: index,
            initVal: 52,
            maxVal: 80,
            nonHoverMaxVal: 52,
          );

          return DragTarget<T>(
            onAcceptWithDetails: (droppedItem) {
              setState(() {
                final draggedIndex = items.indexOf(droppedItem.data);
                if (draggedIndex != -1) {
                  items.removeAt(draggedIndex);
                  items.insert(index, droppedItem.data);
                }
                _draggedIndex = null;
              });
            },
            onWillAcceptWithDetails: (droppedItem) {
              setState(() {
                _hoveredIndex = index;
                _draggedIndex = items.indexOf(droppedItem.data);
              });
              return true;
            },
            onLeave: (_) {
              setState(() {
                _hoveredIndex = null;
                _draggedIndex = null;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<T>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: 1.2,
                    child: widget.builder(item, 1.2),
                  ),
                ),
                childWhenDragging: const PlaceholderWidget(),
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _hoveredIndex = index;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredIndex = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..translate(
                        0.0,
                        calculatedItemValue(
                          index: index,
                          initVal: 0,
                          maxVal: -10,
                          nonHoverMaxVal: -4,
                        ),
                        0.0,
                      ),
                    margin: EdgeInsets.only(
                      left: _draggedIndex != null
                          ? _hoveredIndex == index
                              ? 64
                              : 0
                          : 0,
                      right: _draggedIndex != null
                          ? _hoveredIndex == index && index == items.length - 1
                              ? 30
                              : 0
                          : 0,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: BoxConstraints(
                      minWidth: 52,
                      maxWidth: calculatedSize,
                      maxHeight: calculatedSize,
                    ),
                    child: widget.builder(item, 1.2),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

/// A placeholder widget used to animate its size when dragged to create a smooth animation effect.
class PlaceholderWidget extends StatefulWidget {
  const PlaceholderWidget({super.key});

  @override
  State<PlaceholderWidget> createState() => _PlaceholderWidgetState();
}

class _PlaceholderWidgetState extends State<PlaceholderWidget> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 48, end: 0),
      builder: (BuildContext context, double value, Widget? child) {
        return SizedBox(
          width: value,
          height: value,
        );
      },
    );
  }
}
