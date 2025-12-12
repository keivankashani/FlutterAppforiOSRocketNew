import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/chart_carousel_widget.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/metrics_summary_widget.dart';

class AnalyticsDataScreen extends StatefulWidget {
  const AnalyticsDataScreen({super.key});

  @override
  State<AnalyticsDataScreen> createState() => _AnalyticsDataScreenState();
}

class _AnalyticsDataScreenState extends State<AnalyticsDataScreen>
    with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  DateRangeType _selectedDateRange = DateRangeType.month;
  Map<String, dynamic> _currentFilters = {
    'department': 'All Departments',
    'metrics': <String>[],
    'startDate': '',
    'endDate': '',
  };

  bool _isLoading = false;
  bool _isOfflineMode = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock data for analytics
  final List<Map<String, dynamic>> _metricsData = [
    {
      'value': '\$2.4M',
      'label': 'Total Revenue',
      'change': '+12.5%',
      'isPositive': true,
      'icon': 'attach_money',
    },
    {
      'value': '45.2K',
      'label': 'Active Users',
      'change': '+8.3%',
      'isPositive': true,
      'icon': 'people',
    },
    {
      'value': '68.7%',
      'label': 'Conversion Rate',
      'change': '-2.1%',
      'isPositive': false,
      'icon': 'trending_up',
    },
    {
      'value': '4.2',
      'label': 'Avg Session',
      'change': '+15.7%',
      'isPositive': true,
      'icon': 'schedule',
    },
  ];

  final List<Map<String, dynamic>> _chartsData = [
    {
      'title': 'Revenue Trends',
      'subtitle': 'Monthly revenue performance',
      'type': 'line',
      'showLegend': false,
      'data': [
        {'label': 'Jan', 'value': 2100},
        {'label': 'Feb', 'value': 2300},
        {'label': 'Mar', 'value': 2800},
        {'label': 'Apr', 'value': 2600},
        {'label': 'May', 'value': 3200},
        {'label': 'Jun', 'value': 3800},
      ],
    },
    {
      'title': 'User Engagement',
      'subtitle': 'Daily active users',
      'type': 'bar',
      'showLegend': false,
      'data': [
        {'label': 'Mon', 'value': 1200},
        {'label': 'Tue', 'value': 1800},
        {'label': 'Wed', 'value': 2200},
        {'label': 'Thu', 'value': 1900},
        {'label': 'Fri', 'value': 2400},
        {'label': 'Sat', 'value': 1600},
        {'label': 'Sun', 'value': 1400},
      ],
    },
    {
      'title': 'Market Share',
      'subtitle': 'Distribution by segment',
      'type': 'pie',
      'showLegend': true,
      'data': [
        {'label': 'Enterprise', 'value': 45},
        {'label': 'SMB', 'value': 30},
        {'label': 'Startup', 'value': 15},
        {'label': 'Other', 'value': 10},
      ],
    },
    {
      'title': 'Growth Rate',
      'subtitle': 'Quarterly growth trends',
      'type': 'area',
      'showLegend': false,
      'data': [
        {'label': 'Q1', 'value': 15},
        {'label': 'Q2', 'value': 22},
        {'label': 'Q3', 'value': 28},
        {'label': 'Q4', 'value': 35},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call to Azure services
      await Future.delayed(const Duration(seconds: 2));

      // Update last updated timestamp
      setState(() {
        _lastUpdated = DateTime.now();
        _isOfflineMode = false;
      });
    } catch (e) {
      // Handle API failure - show cached data
      setState(() {
        _isOfflineMode = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadAnalyticsData();
  }

  void _onDateRangeChanged(DateRangeType range) {
    setState(() {
      _selectedDateRange = range;
    });
    _loadAnalyticsData();
  }

  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => FilterBottomSheetWidget(
          currentFilters: _currentFilters,
          onFiltersChanged: (filters) {
            setState(() {
              _currentFilters = filters;
            });
            _loadAnalyticsData();
          },
        ),
      ),
    );
  }

  void _onChartDetailsTap() {
    showDialog(
      context: context,
      builder: (context) => _buildChartDetailsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Analytics',
        variant: CustomAppBarVariant.standard,
        showBackButton: false,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        color: colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            // Sticky header with date range selector
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                child: DateRangeSelectorWidget(
                  selectedRange: _selectedDateRange,
                  onRangeChanged: _onDateRangeChanged,
                  onFilterTap: _onFilterTap,
                ),
              ),
            ),

            // Offline indicator
            if (_isOfflineMode)
              SliverToBoxAdapter(
                child: _buildOfflineIndicator(colorScheme),
              ),

            // Loading indicator
            if (_isLoading)
              SliverToBoxAdapter(
                child: _buildLoadingIndicator(colorScheme),
              ),

            // Metrics summary
            SliverToBoxAdapter(
              child: MetricsSummaryWidget(
                metrics: _metricsData,
                onRefresh: _onRefresh,
              ),
            ),

            // Chart carousel
            SliverToBoxAdapter(
              child: ChartCarouselWidget(
                charts: _chartsData,
                onChartTap: _onChartDetailsTap,
              ),
            ),

            // Last updated info
            SliverToBoxAdapter(
              child: _buildLastUpdatedInfo(colorScheme),
            ),

            // Bottom padding for navigation bar
            SliverToBoxAdapter(
              child: SizedBox(height: 12.h),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(
        variant: CustomBottomBarVariant.standard,
        currentIndex: 0,
      ),
    );
  }

  Widget _buildOfflineIndicator(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'wifi_off',
            color: Colors.orange,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Mode',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Showing cached data. Pull to refresh when online.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading analytics data...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedInfo(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'sync',
            color: colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Last updated: ${_lastUpdated.toString().substring(0, 16)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const Spacer(),
          if (!_isOfflineMode)
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartDetailsDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chart Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Enhanced chart interactions with pinch-to-zoom, pan gestures, and detailed tooltips are available in the full-screen view.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to full-screen chart view
                    },
                    child: const Text('Full Screen'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 20.h;

  @override
  double get maxExtent => 20.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
