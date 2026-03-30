import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../customer/services/api_service.dart';
import '../../theme/app_theme.dart';
import 'worker_notifications_screen.dart';
import 'bank_transfers_screen.dart';
import 'pending_deductions_screen.dart';

class WorkerMoneyScreen extends StatefulWidget {
  const WorkerMoneyScreen({super.key, this.onNavigateToTab});

  final ValueChanged<int>? onNavigateToTab;

  @override
  State<WorkerMoneyScreen> createState() => _WorkerMoneyScreenState();
}

class _WorkerMoneyScreenState extends State<WorkerMoneyScreen> {
  int _selectedMonthIndex = 0;
  bool _isLoadingEarnings = true;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _monthsData = <Map<String, dynamic>>[];
  double _upcomingTransfer = 0;
  double _pendingDeductions = 0;
  List<Map<String, dynamic>> _deductionsBreakdown = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadEarningsSummary();
  }

  Future<void> _loadEarningsSummary() async {
    setState(() {
      _isLoadingEarnings = true;
    });

    try {
      await _apiService.initialize();
      final result = await _apiService.getWorkerEarningsSummary(months: 6);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final rawMonths = data['months'] as List<dynamic>? ?? <dynamic>[];
        List<Map<String, dynamic>> parsedMonths = rawMonths
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => {
                'label': item['label']?.toString() ?? '',
                'earnings': ((item['earnings'] ?? 0) as num).toDouble(),
              },
            )
            .toList();

        double upcomingTransfer = ((data['upcoming_transfer'] ?? 0) as num)
            .toDouble();
        final hasAnyTransfer =
            parsedMonths.any((m) => ((m['earnings'] ?? 0) as num) > 0) ||
            upcomingTransfer > 0;

        // Keep Money tab consistent with Account > Bank Transfers when summary is all zero.
        if (!hasAnyTransfer) {
          final pastResult = await _apiService.getWorkerPastServices(
            limit: 200,
          );
          if (pastResult['success'] == true) {
            final pastData = pastResult['data'] as Map<String, dynamic>;
            final services =
                (pastData['services'] as List<dynamic>? ?? <dynamic>[])
                    .whereType<Map<String, dynamic>>()
                    .toList();

            final monthMap = <String, double>{};
            for (final service in services) {
              final rawTime = service['scheduled_time']?.toString() ?? '';
              DateTime? dt;
              try {
                dt = DateTime.parse(rawTime);
              } catch (_) {
                dt = null;
              }
              if (dt == null) continue;

              final label = _monthLabel(dt.month);
              final amount = ((service['worker_amount'] ?? 0) as num)
                  .toDouble();
              monthMap[label] = (monthMap[label] ?? 0) + amount;
            }

            if (monthMap.isNotEmpty) {
              parsedMonths = monthMap.entries
                  .map((e) => {'label': e.key, 'earnings': e.value})
                  .toList();
              final currentLabel = _monthLabel(DateTime.now().month);
              upcomingTransfer = monthMap[currentLabel] ?? 0;
            }
          }
        }

        setState(() {
          _monthsData = parsedMonths;
          _selectedMonthIndex = _monthsData.isNotEmpty
              ? _monthsData.length - 1
              : 0;
          _upcomingTransfer = upcomingTransfer;
          _pendingDeductions = ((data['pending_deductions'] ?? 0) as num)
              .toDouble();
          _deductionsBreakdown =
              (data['deductions_breakdown'] as List<dynamic>? ?? <dynamic>[])
                  .whereType<Map<String, dynamic>>()
                  .toList();
        });
      }
    } catch (_) {
      // Keep fallback empty state if API is unavailable.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEarnings = false;
        });
      }
    }
  }

  // Calculate chart data (normalized to 100px max height)
  List<double> get _chartData {
    if (_monthsData.isEmpty) return <double>[];
    final maxEarning = _monthsData
        .map((item) => (item['earnings'] as double))
        .reduce((a, b) => a > b ? a : b);
    final divisor = maxEarning <= 0 ? 1.0 : maxEarning;
    return _monthsData
        .map((item) => ((item['earnings'] as double) / divisor) * 80)
        .toList();
  }

  // Get current month's earnings
  double get _currentEarnings {
    if (_monthsData.isEmpty || _selectedMonthIndex >= _monthsData.length) {
      return 0;
    }
    return (_monthsData[_selectedMonthIndex]['earnings'] as double);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<WorkerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.getTextColor(context);
    final textSecondary = AppTheme.getTextColor(context, secondary: true);
    final cardBg = AppTheme.getSurfaceColor(context);
    final cardBorder = AppTheme.getDividerColor(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.credit_card,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WorkerNotificationsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Money Title - BOLD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Money',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Earned this month card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF0D47A1),
                              AppTheme.workerPrimaryDark,
                            ]
                          : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.workerPrimaryColor.withOpacity(
                          isDark ? 0.25 : 0.15,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${_currentEarnings.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Earned this month',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              size: 28,
                              color: AppTheme.workerPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Bar chart
                      SizedBox(
                        height: 100,
                        child: _isLoadingEarnings
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(_monthsData.length, (
                                  index,
                                ) {
                                  final isSelected =
                                      index == _selectedMonthIndex;
                                  final height = _chartData[index];
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: 36,
                                        height: height,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isSelected
                                                ? [
                                                    AppTheme.workerPrimaryDark,
                                                    AppTheme.workerPrimaryColor,
                                                  ]
                                                : [
                                                    AppTheme.workerPrimaryLight,
                                                    const Color(0xFF90CAF9),
                                                  ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppTheme
                                                        .workerPrimaryColor
                                                        .withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  );
                                }),
                              ),
                      ),

                      const SizedBox(height: 16),

                      // Month selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_monthsData.length, (index) {
                          final isSelected = index == _selectedMonthIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMonthIndex = index;
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  _monthsData[index]['label'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? (isDark
                                              ? Colors.white
                                              : Colors.black87)
                                        : (isDark
                                              ? Colors.white70
                                              : Colors.black45),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? 24 : 6,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.workerPrimaryDark
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bank transfers section - BOLD HEADING
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bank transfers',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BankTransfersScreen(
                              upcomingTransferAmount: _upcomingTransfer,
                              monthlyTransfers: _monthsData,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.workerPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Upcoming transfer card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BankTransfersScreen(
                          upcomingTransferAmount: _upcomingTransfer,
                          monthlyTransfers: _monthsData,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: Color(0xFF1976D2),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UPCOMING TRANSFER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${_upcomingTransfer.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Current cycle',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pending deductions card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PendingDeductionsScreen(
                          totalPending: _pendingDeductions,
                          deductions: _deductionsBreakdown,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.orange,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PENDING DEDUCTIONS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${_pendingDeductions.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _monthLabel(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[(month - 1).clamp(0, 11)];
  }
}
