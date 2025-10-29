import 'package:flutter/material.dart';

class DraggableFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Offset initialOffset;
  final Size screenSize;

  const DraggableFAB({
    super.key,
    required this.onPressed,
    required this.child,
    required this.initialOffset,
    required this.screenSize,
  });

  @override
  State<DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<DraggableFAB> {
  late Offset _position;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialOffset;
  }

  void _updatePosition(Offset newPosition) {
    final screenWidth = widget.screenSize.width;
    final screenHeight = widget.screenSize.height;
    final fabSize = 56.0; // Tamaño estándar del FAB

    // Limitar la posición dentro de los límites de la pantalla
    // No permitir que baje más allá de donde está inicialmente (evitar que se oculte bajo la navegación)
    final clampedX = newPosition.dx.clamp(0.0, screenWidth - fabSize);
    final clampedY = newPosition.dy.clamp(0.0, widget.initialOffset.dy); // Solo permitir mover hacia arriba

    setState(() {
      _position = Offset(clampedX, clampedY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: Material(
          color: Colors.transparent,
          elevation: 8,
          child: Transform.scale(
            scale: 1.1,
            child: widget.child,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: widget.child,
        ),
        onDragEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          _updatePosition(details.offset);
        },
        onDragStarted: () {
          setState(() {
            _isDragging = true;
          });
        },
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            _isDragging = false;
          });
          _updatePosition(offset);
        },
        child: GestureDetector(
          onTap: _isDragging ? null : widget.onPressed,
          child: AnimatedScale(
            scale: _isDragging ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _isDragging ? 0.7 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}