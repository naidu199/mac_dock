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
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Dock<IconData>(
          items: const [
            Icons.person,
            Icons.message,
            Icons.call,
            Icons.camera,
            Icons.photo,
          ],
          builder: (icon, scale) {
            return AnimatedScale(
              duration: const Duration(milliseconds: 100),
              scale: scale,
              child: Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      Colors.primaries[icon.hashCode % Colors.primaries.length],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              ),
            );
          },
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
  });

  final List<T> items;
  final Widget Function(T, double) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();
  T? draggedItem;
  double? mouseX;
  double? dragX;
  static const double maxScale = 1.5;
  static const double influenceRange = 150;
  static const double itemWidth = 64.0; // Width of each item including margin

  // Store item positions
  final Map<int, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _items.length; i++) {
      _keys[i] = GlobalKey();
    }
  }

  double _getScale(double itemX) {
    if (mouseX == null || draggedItem != null) return 1.0;

    final distance = (mouseX! - itemX).abs();
    if (distance > influenceRange) return 1.0;

    final scale =
        1.0 + (maxScale - 1.0) * math.pow(1 - distance / influenceRange, 2);
    return scale;
  }

  double _getOffset(int index) {
    if (draggedItem == null || dragX == null) return 0;

    final draggedIndex = _items.indexOf(draggedItem!);
    if (draggedIndex == -1) return 0;

    // Get the current item's position
    final key = _keys[index];
    if (key?.currentContext == null) return 0;

    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return 0;

    final itemPosition = box.localToGlobal(Offset.zero).dx;

    // Calculate the position where the dragged item would be inserted
    final dragPosition = dragX!;
    final insertionIndex =
        (dragPosition / itemWidth).round().clamp(0, _items.length - 1);

    // Determine if this item needs to move
    if (insertionIndex > draggedIndex) {
      if (index <= insertionIndex && index > draggedIndex) {
        return -itemWidth;
      }
    } else if (insertionIndex < draggedIndex) {
      if (index >= insertionIndex && index < draggedIndex) {
        return itemWidth;
      }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return LayoutBuilder(
                    key: _keys[index],
                    builder: (context, constraints) {
                      final box = context.findRenderObject() as RenderBox?;
                      final itemX = box?.localToGlobal(Offset.zero).dx ?? 0;
                      final scale = _getScale(itemX + constraints.maxWidth / 2);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.identity()
                          ..translate(_getOffset(index)),
                        child: Draggable<T>(
                          data: item,
                          feedback: widget.builder(item, maxScale),
                          childWhenDragging: Opacity(
                            opacity: 0.2,
                            child: widget.builder(item, 1.0),
                          ),
                          onDragStarted: () {
                            setState(() {
                              draggedItem = item;
                              mouseX = null;
                            });
                          },
                          onDragEnd: (_) {
                            setState(() {
                              draggedItem = null;
                              dragX = null;
                            });
                          },
                          onDragUpdate: (details) {
                            setState(() {
                              dragX = details.globalPosition.dx;
                            });
                          },
                          child: DragTarget<T>(
                            onWillAcceptWithDetails: (data) => true,
                            onAcceptWithDetails: (details) {
                              final data = details.data;
                              setState(() {
                                final oldIndex = _items.indexOf(data);
                                final newIndex = _items.indexOf(item);
                                _items.removeAt(oldIndex);
                                _items.insert(newIndex, data);
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              return widget.builder(item, scale);
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
    );
  }
}
