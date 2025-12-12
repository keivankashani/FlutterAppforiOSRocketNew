import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum DateRangeType { today, week, month, quarter, year, custom }

class DateRangeSelectorWidget extends StatefulWidget {
  final DateRangeType selectedRange;
  final ValueChanged<DateRangeType>? onRangeChanged;
  final VoidCallback? onFilterTap;

  const DateRangeSelectorWidget({
    super.key,
    this.selectedRange = DateRangeType.month,
    this.onRangeChanged,
    this.onFilterTap,
  });

  @override
  State<DateRangeSelectorWidget> createState() =>
      _DateRangeSelectorWidgetState();
}

class _DateRangeSelectorWidgetState extends State<DateRangeSelectorWidget> {
  late DateRangeType _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.selectedRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, colorScheme),
          SizedBox(height: 2.h),
          _buildRangeSelector(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                _getDateRangeText(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
        if (widget.onFilterTap != null)
          IconButton(
            onPressed: widget.onFilterTap,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: colorScheme.primary,
              size: 24,
            ),
            tooltip: 'Filter Data',
          ),
      ],
    );
  }

  Widget _buildRangeSelector(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DateRangeType.values.map((range) {
          final isSelected = range == _selectedRange;
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: _buildRangeChip(context, colorScheme, range, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRangeChip(BuildContext context, ColorScheme colorScheme,
      DateRangeType range, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRange = range;
        });
        widget.onRangeChanged?.call(range);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          _getRangeLabel(range),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }

  String _getRangeLabel(DateRangeType range) {
    switch (range) {
      case DateRangeType.today:
        return 'Today';
      case DateRangeType.week:
        return 'Week';
      case DateRangeType.month:
        return 'Month';
      case DateRangeType.quarter:
        return 'Quarter';
      case DateRangeType.year:
        return 'Year';
      case DateRangeType.custom:
        return 'Custom';
    }
  }

  String _getDateRangeText() {
    final now = DateTime.now();

    switch (_selectedRange) {
      case DateRangeType.today:
        return '${now.month}/${now.day}/${now.year}';
      case DateRangeType.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${startOfWeek.month}/${startOfWeek.day} - ${endOfWeek.month}/${endOfWeek.day}';
      case DateRangeType.month:
        final monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        return '${monthNames[now.month - 1]} ${now.year}';
      case DateRangeType.quarter:
        final quarter = ((now.month - 1) ~/ 3) + 1;
        return 'Q$quarter ${now.year}';
      case DateRangeType.year:
        return '${now.year}';
      case DateRangeType.custom:
        return 'Custom Range';
    }
  }
}
