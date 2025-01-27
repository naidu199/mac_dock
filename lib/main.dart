import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

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
                      size: 32 * scale,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 32,
            )
          ],
        ),
      ),
    );
  }
}

class MacDock<T extends Object> extends StatefulWidget {
  const MacDock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T item, double scale) builder;

  @override
  State<MacDock<T>> createState() => MacDockState<T>();
}

class MacDockState<T extends Object> extends State<MacDock<T>> {
  late final List<T> items = widget.items.toList();
  int? _hoveredIndex;
  int? _draggedIndex;

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
      return lerpDouble(initVal, maxVal, 0.5)!;
    } else if (distance == 2) {
      return lerpDouble(initVal, maxVal, 0.25)!;
    } else if (distance < 3 && distance <= itemsAffected) {
      return lerpDouble(initVal, nonHoverMaxVal, .15)!;
    } else {
      return initVal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black26,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((val) {
          final index = val.key;
          final item = val.value;

          final calculatedSize = calculatedItemValue(
            index: index,
            initVal: 48,
            maxVal: 72,
            nonHoverMaxVal: 48,
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
              final draggedIndex = items.indexOf(droppedItem.data);
              setState(() {
                _hoveredIndex = index;
                _draggedIndex = draggedIndex;
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
                    scale: 1.3,
                    child: widget.builder(item, calculatedSize / 68),
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
                    duration: const Duration(milliseconds: 150),
                    transform: Matrix4.identity()
                      ..translate(
                        0.0,
                        calculatedItemValue(
                          index: index,
                          initVal: 0,
                          maxVal: -15,
                          nonHoverMaxVal: -4,
                        ),
                        0.0,
                      ),
                    margin: EdgeInsets.only(
                      left: _draggedIndex != null
                          ? _hoveredIndex == index
                              ? 68
                              : 0
                          : 0,
                      right: _draggedIndex != null
                          ? _hoveredIndex == index && index == items.length - 1
                              ? 30
                              : 0
                          : 0,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    constraints: BoxConstraints(
                      minWidth: 48,
                      maxWidth: calculatedSize,
                      maxHeight: calculatedSize,
                    ),
                    child: widget.builder(item, calculatedSize / 68),
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
