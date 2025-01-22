import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: DockContainer(),
            ),
          ),
        ),
      ),
    );
  }
}

class DockContainer extends StatefulWidget {
  const DockContainer({super.key});

  @override
  State<DockContainer> createState() => _DockContainerState();
}

class _DockContainerState extends State<DockContainer> {
  double _containerWidth = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _containerWidth > 0 ? _containerWidth + 32 : null,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.3),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Dock<IconData>(
              items: const [
                Icons.person,
                Icons.message,
                Icons.call,
                Icons.camera,
                Icons.photo,
              ],
              onWidthChanged: (width) {
                setState(() {
                  _containerWidth = width;
                });
              },
              builder: (icon, scale) {
                return AnimatedScale(
                  duration: const Duration(milliseconds: 100),
                  scale: scale,
                  child: Container(
                    margin: EdgeInsets.all(4 * scale),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors
                          .primaries[icon.hashCode % Colors.primaries.length],
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
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
    required this.onWidthChanged,
  });

  final List<T> items;
  final Widget Function(T, double) builder;
  final Function(double) onWidthChanged;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>>
    with TickerProviderStateMixin {
  late final List<T> _items = widget.items.toList();
  T? draggedItem;
  double? mouseX;
  double? dragX;
  int? dragIndex;
  static const double maxScale = 1.4;
  static const double influenceRange = 150;
  static const double baseItemWidth = 64.0;
  static const double baseItemSize = 48.0;
  static const double baseItemSpacing = 20.0;
//   static const double itemWidth = baseItemSize + baseItemSpacing;
  late List<AnimationController> _positionControllers;
  late List<Animation<double>> _positions;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _positionControllers = List.generate(
      _items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _positions = List.generate(
      _items.length,
      (index) => Tween<double>(
        begin: index * baseItemWidth,
        end: index * baseItemWidth,
      ).animate(
        CurvedAnimation(
          parent: _positionControllers[index],
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  double _calculateContainerWidth() {
    double totalWidth = 0;
    for (int i = 0; i < _items.length; i++) {
      totalWidth += baseItemSize;
      if (i < _items.length - 1) {
        totalWidth += baseItemSpacing;
      }
    }
    return totalWidth + 32 + baseItemSize;
  }

  double _getScale(double itemX) {
    if (mouseX == null || draggedItem != null) return 1.0;

    final distance = (mouseX! - itemX).abs();
    if (distance > influenceRange) return 1.0;

    return 1.0 + (maxScale - 1.0) * math.pow(1 - distance / influenceRange, 2);
  }

  void _updateDragPosition(double x) {
    setState(() {
      dragX = x;
      if (draggedItem != null && dragIndex != null) {
        final newIndex =
            (x / baseItemWidth).round().clamp(0, _items.length - 1);

        if (newIndex != dragIndex) {
          final oldIndex = dragIndex!;
          final direction = newIndex > oldIndex ? 1 : -1;

          for (var i = 0; i < _items.length; i++) {
            if (i == oldIndex) continue;

            final shouldMove = direction > 0
                ? i > oldIndex && i <= newIndex
                : i < oldIndex && i >= newIndex;

            if (shouldMove) {
              _positions[i] = Tween<double>(
                begin: _positions[i].value,
                end: (i - direction) * baseItemWidth,
              ).animate(_positionControllers[i]);
              _positionControllers[i].forward(from: 0);
            }
          }

          dragIndex = newIndex;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          mouseX = event.localPosition.dx;
//           print("hello");
          widget.onWidthChanged(_calculateContainerWidth());
        });
      },
      onExit: (event) {
        setState(() {
          mouseX = null;
        });
      },
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: _items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return AnimatedBuilder(
                    animation: _positionControllers[index],
                    builder: (context, child) {
                      return Positioned(
                        left: _positions[index].value,
                        top: 0,
                        bottom: 0,
                        child: Draggable<T>(
                          data: item,
                          feedback: Transform.scale(
                            scale: 1.1,
                            child: widget.builder(item, maxScale),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.2,
                            child: widget.builder(item, 1.0),
                          ),
                          onDragStarted: () {
                            setState(() {
                              draggedItem = item;
                              dragIndex = index;
                              mouseX = null;
                            });
                          },
                          onDragUpdate: (details) {
                            _updateDragPosition(details.localPosition.dx);
                          },
                          onDragEnd: (_) {
                            setState(() {
                              if (dragIndex != null && dragIndex != index) {
                                final item = _items.removeAt(index);
                                _items.insert(dragIndex!, item);
                                _initializeAnimations();
                              }
                              draggedItem = null;
                              dragIndex = null;
                              dragX = null;
                            });
                          },
                          child: DragTarget<T>(
                            onWillAcceptWithDetails: (data) => true,
                            onAcceptWithDetails: (data) {
                              final oldIndex = _items.indexOf(data.data);
                              final newIndex = _items.indexOf(item);
                              setState(() {
                                _items.removeAt(oldIndex);
                                _items.insert(newIndex, data.data);
                                _initializeAnimations();
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              final box =
                                  context.findRenderObject() as RenderBox?;
                              final itemX =
                                  box?.localToGlobal(Offset.zero).dx ?? 0;
                              final scale =
                                  _getScale(itemX + baseItemWidth / 2);
                              return widget.builder(item, scale);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _positionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
