import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({
    this.itemCount = 6,
    this.itemHeight = 72,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => _ShimmerBox(height: itemHeight),
    );
  }
}

class SkeletonChart extends StatelessWidget {
  const SkeletonChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShimmerBox(
      height: 220,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double height;
  final EdgeInsets margin;

  const _ShimmerBox({
    required this.height,
    this.margin = const EdgeInsets.all(0),
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: AppTheme.primario.withOpacity(_animation.value),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
