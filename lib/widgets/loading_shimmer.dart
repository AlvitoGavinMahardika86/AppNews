import 'package:flutter/material.dart';
import 'package:news_app/utils/app_colors.dart';

class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key});

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double height,
    required double width,
    required double radius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.divider,
                AppColors.divider.withValues(alpha: 0.5),
                AppColors.divider,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_animation.value * 3.14159),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _shimmerBox(
                  height: 200,
                  width: double.infinity,
                  radius: 0,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source skeleton
                    _shimmerBox(height: 12, width: 100, radius: 6),

                    const SizedBox(height: 12),

                    // Title skeleton
                    _shimmerBox(height: 16, width: double.infinity, radius: 8),
                    const SizedBox(height: 8),
                    _shimmerBox(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.7,
                      radius: 8,
                    ),

                    const SizedBox(height: 12),

                    // Description skeleton
                    _shimmerBox(height: 14, width: double.infinity, radius: 7),
                    const SizedBox(height: 6),
                    _shimmerBox(
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.5,
                      radius: 7,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
