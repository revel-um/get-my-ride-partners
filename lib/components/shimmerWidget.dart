import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final isLoading;
  final child;
  final duration;
  const ShimmerWidget({
    @required this.isLoading,
    @required this.child, this.duration = const Duration(seconds: 1),
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    return Shimmer.fromColors(
      period: duration,
      direction: ShimmerDirection.ltr,
      highlightColor: Colors.white,
      baseColor: Color(0xFFECECEC),
      child: child,
    );
  }
}
