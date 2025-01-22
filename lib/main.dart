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
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: DockContainer(),
            ),
          ],
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
  static const double maxScale = 1.3;
  static const double influenceRange = 150;
  static const double baseItemSize = 48.0;
  static const double baseItemSpacing = 20.0;
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
        duration: const Duration(milliseconds: 200),
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
          curve: Curves.easeOutCubic,
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

    return 1.0 + (maxScale - 1.0) * math.pow(1 - distance / influenceRange, 2);
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
    double totalWidth = 0;
    for (int i = 0; i < _items.length; i++) {
      totalWidth += baseItemSize * scales[i];
      if (i < _items.length - 1) {
        totalWidth += baseItemSpacing;
      }
    }
    return totalWidth + 32;
  }

  void _updateDragPosition(double x) {
    setState(() {
      dragX = x;
      if (draggedItem != null && dragIndex != null) {
        final itemCenter = x + baseItemSize / 2;
        final newIndex =
            (itemCenter / itemWidth).round().clamp(0, _items.length - 1);

        if (newIndex != dragIndex) {
          final oldIndex = dragIndex!;
          final direction = newIndex > oldIndex ? 1 : -1;

          for (var i = 0; i < _items.length; i++) {
            if (i == oldIndex) continue;

            final shouldMove = direction > 0
                ? i > oldIndex && i <= newIndex
                : i < oldIndex && i >= newIndex;

            if (shouldMove) {
              final newPosition = _calculateBasePosition(i - direction);
              _positions[i] = Tween<double>(
                begin: _positions[i].value,
                end: newPosition,
              ).animate(_positionControllers[i]);
              _positionControllers[i].forward(from: 0);
            } else if (!shouldMove && i != oldIndex) {
              // Reset position for items that don't need to move
              final newPosition = _calculateBasePosition(i);
              if (_positions[i].value != newPosition) {
                _positions[i] = Tween<double>(
                  begin: _positions[i].value,
                  end: newPosition,
                ).animate(_positionControllers[i]);
                _positionControllers[i].forward(from: 0);
              }
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
        final containerWidth = _calculateContainerWidth(scales);
        const containerHeight = baseItemSize * maxScale + 12;

        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: containerWidth,
            height: containerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: MouseRegion(
                      onHover: (event) {
                        setState(() {
                          mouseX = event.localPosition.dx;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          mouseX = null;
                        });
                      },
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
                                top:
                                    (containerHeight - (baseItemSize * scale)) /
                                        2,
                                child: Draggable<T>(
                                  data: item,
                                  feedback: Transform.scale(
                                    scale: maxScale,
                                    child: _buildIcon(item, 1.0),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.2,
                                    child: _buildIcon(item, 1.0),
                                  ),
                                  onDragStarted: () {
                                    setState(() {
                                      draggedItem = item;
                                      dragIndex = index;
                                      mouseX = null;
                                    });
                                  },
                                  onDragUpdate: (details) {
                                    _updateDragPosition(
                                        details.localPosition.dx);
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
                                      final oldIndex =
                                          _items.indexOf(data.data);
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
                                            const Duration(milliseconds: 100),
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
