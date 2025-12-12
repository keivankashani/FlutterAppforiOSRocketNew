import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './chart_card_widget.dart';

class ChartCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>> charts;
  final VoidCallback? onChartTap;

  const ChartCarouselWidget({
    super.key,
    required this.charts,
    this.onChartTap,
  });

  @override
  State<ChartCarouselWidget> createState() => _ChartCarouselWidgetState();
}

class _ChartCarouselWidgetState extends State<ChartCarouselWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, colorScheme),
        SizedBox(height: 2.h),
        _buildCarousel(context, colorScheme),
        SizedBox(height: 2.h),
        _buildIndicators(context, colorScheme),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Performance Charts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
          Text(
            '${_currentIndex + 1} of ${widget.charts.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      height: 40.h,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.charts.length,
        itemBuilder: (context, index) {
          final chart = widget.charts[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            child: ChartCardWidget(
              title: chart['title'] as String? ?? '',
              subtitle: chart['subtitle'] as String? ?? '',
              chartType: _getChartType(chart['type'] as String? ?? 'line'),
              data:
                  (chart['data'] as List?)?.cast<Map<String, dynamic>>() ?? [],
              onViewDetails: widget.onChartTap,
              primaryColor: _getChartColor(index, colorScheme),
              showLegend: chart['showLegend'] as bool? ?? true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicators(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.charts.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: index == _currentIndex ? 6.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  ChartType _getChartType(String type) {
    switch (type.toLowerCase()) {
      case 'bar':
        return ChartType.bar;
      case 'pie':
        return ChartType.pie;
      case 'area':
        return ChartType.area;
      case 'line':
      default:
        return ChartType.line;
    }
  }

  Color _getChartColor(int index, ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
    ];
    return colors[index % colors.length];
  }
}
