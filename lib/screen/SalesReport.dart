import 'package:flutter/material.dart';
import 'package:promoterapp/models/Shops.dart';
import 'package:promoterapp/models/saalesreport.dart';
import 'package:intl/intl.dart';
import 'package:promoterapp/util/ApiHelper.dart';
import 'package:promoterapp/util/functionhelper.dart';

class SalesReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SalesReportState();
  }
}

class SalesReportState extends State<SalesReport> {
  static const Color _pageBackground = Color(0xFFFFFBF7);
  static const Color _pageBackgroundSoft = Color(0xFFF4EFE6);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceSoft = Color(0xFFF8F4ED);
  static const Color _surfaceTint = Color(0xFFEAF6EC);
  static const Color _primaryGreen = Color(0xFF3F7F4B);
  static const Color _primaryText = Color(0xFF203127);
  static const Color _secondaryText = Color(0xFF6B766E);
  static const Color _border = Color(0xFFE6E0D7);
  final bool _isLoading = false;
  String from = "", to = "", salesid = "";
  Future<List<saalesreport>>? report;
  String? cdate;
  List<Shops> shopdata = [];

  @override
  void initState() {
    super.initState();

    cdate = getcurrentdate();

    from = cdate ?? "";
    to = cdate ?? "";
    getproreports(from, to);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _pageBackground,
            _pageBackgroundSoft,
          ],
        ),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<saalesreport>>(
              future: report,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                          child: _buildHeroCard(),
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(
                          icon: Icons.error_outline_rounded,
                          title: "Unable to load reports",
                          subtitle:
                              "Please try again after checking your connection.",
                        ),
                      ),
                    ],
                  );
                }

                final reports = snapshot.data ?? [];

                if (reports.isEmpty) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                          child: _buildHeroCard(),
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: "No sales found",
                          subtitle:
                              "Try changing the date range to see more entries.",
                        ),
                      ),
                    ],
                  );
                }

                final totalPieces = reports.fold<int>(
                  0,
                  (sum, item) => sum + _toInt(item.pieces),
                );

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: Column(
                          children: [
                            _buildHeroCard(),
                            const SizedBox(height: 12),
                            _buildSummaryOverview(
                              entries: reports.length.toString(),
                              pieces: totalPieces.toString(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: EdgeInsets.only(
                              bottom: index == reports.length - 1 ? 0 : 12,
                            ),
                            child: _buildReportCard(reports[index], index),
                          ),
                          childCount: reports.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAF7EC),
            Color(0xFFF8F3E8),
            Color(0xFFE3F0E2),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102C302A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sales Activity",
            style: TextStyle(
              color: _primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          // const Text(
          //   "My Sales Report",
          //   style: TextStyle(
          //     color: _primaryText,
          //     fontSize: 28,
          //     height: 1.15,
          //     fontWeight: FontWeight.w700,
          //   ),
          // ),
          // const SizedBox(height: 10),
          // Text(
          //   "Review your sales entries across the selected date range.",
          //   style: TextStyle(
          //     color: _secondaryText,
          //     fontSize: 14,
          //     height: 1.4,
          //   ),
          // ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded,
                      color: _primaryGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                    "${_formatDisplayDate(from)}  -  ${_formatDisplayDate(to)}",
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: _primaryGreen,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // const Text(
          //   "Choose a start and end date to review sales entries.",
          //   style: TextStyle(
          //     color: _secondaryText,
          //     fontSize: 13,
          //   ),
          // ),
          // const SizedBox(height: 14),
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildDateCard(
          //         label: "From",
          //         value: from.isEmpty ? "Select date" : _formatDisplayDate(from),
          //         accentColor: const Color(0xFF0C5B35),
          //         onTap: _pickFromDate,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildDateCard(
          //         label: "To",
          //         value: to.isEmpty ? "Select date" : _formatDisplayDate(to),
          //         accentColor: const Color(0xFF8A6C45),
          //         onTap: _pickToDate,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildDateCard({
    required String label,
    required String value,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surfaceSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.calendar_month_rounded,
                  color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryOverview({
    required String entries,
    required String pieces,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFFF9F1),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102C302A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryMetric(
              title: "Entries",
              value: entries,
              accentColor: const Color(0xFF0C5B35),
              icon: Icons.receipt_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: _border,
          ),
          Expanded(
            child: _buildSummaryMetric(
              title: "Pieces",
              value: pieces,
              accentColor: const Color(0xFF8A6C45),
              icon: Icons.inventory_2_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String title,
    required String value,
    required Color accentColor,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(saalesreport item, int index) {
    final accentColor =
        index.isEven ? const Color(0xFF0C5B35) : const Color(0xFF8A6C45);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFFF9F1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102C302A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.store_rounded, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.shopName?.toString() ?? "Unknown shop",
                      style: const TextStyle(
                        color: _primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.productName?.toString() ?? "Unknown product",
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip(
                Icons.inventory_2_outlined,
                "${item.pieces?.toString() ?? "0"} pieces",
              ),
              _buildInfoChip(
                Icons.stacked_bar_chart_rounded,
                "Qty ${item.totalQuantity?.toString() ?? "0"}",
              ),
              _buildInfoChip(
                Icons.schedule_rounded,
                item.timestamp?.toString() ?? "--",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _primaryGreen),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: _primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFFFF9F1),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x102C302A),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _surfaceTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 30, color: _primaryGreen),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        from = DateFormat('yyyy/MM/dd').format(date);
      });

      if (to.isNotEmpty) {
        getproreports(from, to);
      }
    }
  }

  Future<void> _pickToDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        to = DateFormat('yyyy/MM/dd').format(date);
      });

      if (from.isNotEmpty) {
        getproreports(from, to);
      } else {}
    }
  }

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    DateTime initialStart = now;
    DateTime initialEnd = now;

    try {
      if (from.isNotEmpty) {
        initialStart = DateFormat('yyyy/MM/dd').parse(from);
      }
      if (to.isNotEmpty) {
        initialEnd = DateFormat('yyyy/MM/dd').parse(to);
      }
    } catch (_) {
      initialStart = now;
      initialEnd = now;
    }

    if (initialEnd.isBefore(initialStart)) {
      initialEnd = initialStart;
    }

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );

    if (pickedRange != null) {
      setState(() {
        from = DateFormat('yyyy/MM/dd').format(pickedRange.start);
        to = DateFormat('yyyy/MM/dd').format(pickedRange.end);
      });
      getproreports(from, to);
    }
  }

  String _formatDisplayDate(String value) {
    if (value.isEmpty) {
      return "--";
    }

    try {
      final parsedDate = DateFormat('yyyy/MM/dd').parse(value);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (_) {
      return value;
    }
  }

  int _toInt(String? value) {
    return int.tryParse(value ?? "") ?? 0;
  }

  void getproreports(String from, String to) {
    report = getreports('getPromoterTodaySale2', from, to);
  }
}
