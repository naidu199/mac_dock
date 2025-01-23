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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 40,
                  child: DockContainer(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DockContainer extends StatelessWidget {
  const DockContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Dock<IconData>(
        items: [
          Icons.person,
          Icons.message,
          Icons.call,
          Icons.camera,
          Icons.photo,
        ],
      ),
    );
  }
}

class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
  });

  final List<T> items;

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
  static const double influenceRange = 120;
  static const double baseItemSize = 48.0;
  static const double baseItemSpacing = 16.0;
  static const double itemWidth = baseItemSize + baseItemSpacing;

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
        duration: const Duration(milliseconds: 400),
      ),
    );

    _positions = List.generate(
      _items.length,
      (index) => Tween<double>(
        begin: _calculateBasePosition(index),
        end: _calculateBasePosition(index),
      ).animate(
        CurvedAnimation(
          parent: _positionControllers[index],
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  double _calculateBasePosition(int index) {
    return index * itemWidth;
  }

  double _getScale(double itemX) {
    if (mouseX == null || draggedItem != null) return 1.0;

    final distance = (mouseX! - itemX).abs();
    if (distance > influenceRange) return 1.0;

    final scale =
        1.0 + (maxScale - 1.0) * math.pow(1 - distance / influenceRange, 1.5);
    return scale.clamp(1.0, maxScale);
  }

  List<double> _calculateScales(double containerWidth) {
    if (mouseX == null || draggedItem != null) {
      return List.filled(_items.length, 1.0);
    }

    return List.generate(_items.length, (index) {
      final itemX = _positions[index].value + (baseItemSize / 2);
      return _getScale(itemX);
    });
  }

  double _calculateContainerWidth(List<double> scales) {
    if (draggedItem != null) {
      return (_items.length - 1) * itemWidth + baseItemSize + 32;
    }

    double totalWidth = 0;
    for (int i = 0; i < _items.length; i++) {
      totalWidth += baseItemSize * scales[i];
      if (i < _items.length - 1) {
        totalWidth += baseItemSpacing;
      }
    }
    return totalWidth + 28;
  }

  void _updateDragPosition(double x) {
    setState(() {
      dragX = x;
      if (draggedItem != null && dragIndex != null) {
        final newIndex = (x / itemWidth).round().clamp(0, _items.length - 1);

        if (newIndex != dragIndex) {
          final oldIndex = dragIndex!;

          for (var i = 0; i < _items.length; i++) {
            double targetPosition;

            if (newIndex > oldIndex) {
              if (i < oldIndex || i > newIndex) {
                targetPosition = i * itemWidth;
              } else if (i == oldIndex) {
                targetPosition = newIndex * itemWidth;
              } else {
                targetPosition = (i - 1) * itemWidth;
              }
            } else {
              if (i < newIndex || i > oldIndex) {
                targetPosition = i * itemWidth;
              } else if (i == oldIndex) {
                targetPosition = newIndex * itemWidth;
              } else {
                targetPosition = (i + 1) * itemWidth;
              }
            }

            _positions[i] = Tween<double>(
              begin: _positions[i].value,
              end: targetPosition,
            ).animate(
              CurvedAnimation(
                parent: _positionControllers[i],
                curve: Curves.easeOutBack,
              ),
            );

            if (i != oldIndex) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final scales = _calculateScales(constraints.maxWidth);
        final containerWidth = _calculateContainerWidth(scales) + 16;
        const containerHeight = baseItemSize * maxScale + 24;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: containerWidth + 16,
          height: containerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: MouseRegion(
                    onHover: (event) => setState(() {
                      mouseX = event.localPosition.dx;
                    }),
                    onExit: (event) => setState(() => mouseX = null),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: _items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final scale = scales[index];

                        return AnimatedBuilder(
                          animation: _positionControllers[index],
                          builder: (context, child) {
                            return Positioned(
                              left: _positions[index].value,
                              top: 10,
                              child: Draggable<T>(
                                data: item,
                                feedback: Transform.scale(
                                  scale: maxScale,
                                  child: _buildIcon(item, 1.0),
                                ),
                                childWhenDragging: const SizedBox(),
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
                                    if (dragIndex != null &&
                                        dragIndex != index) {
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
                                  builder:
                                      (context, candidateData, rejectedData) {
                                    return AnimatedScale(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      curve: Curves.easeOutQuint,
                                      scale: scale,
                                      child: _buildIcon(item, 1.0),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(T item, double scale) {
    return Container(
      width: baseItemSize,
      height: baseItemSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors
            .primaries[(item as IconData).hashCode % Colors.primaries.length],
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
          item as IconData,
          color: Colors.white,
          size: 24,
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
