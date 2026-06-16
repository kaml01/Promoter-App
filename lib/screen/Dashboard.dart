import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:promoterapp/models/Logindetails.dart';
import 'package:promoterapp/util/DatabaseHelper.dart';
import 'package:promoterapp/screen/SalesEntry.dart';
import 'package:promoterapp/util/Shared_pref.dart';
import 'package:promoterapp/util/ApiHelper.dart';
import 'package:pie_chart/pie_chart.dart' as Pie;
import 'package:promoterapp/config/Common.dart';
import 'package:promoterapp/models/Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../util/functionhelper.dart';
import '../models/monthlyItem.dart';
import 'dart:convert';
import 'dart:math';

class Dashboard extends StatefulWidget {

  final Color dark = Colors.cyan;
  final Color normal = Colors.blue;
  final Color light = Colors.white;

  @override
  State<StatefulWidget> createState() {
    return Dashboardstate();
  }
  
}

class Dashboardstate extends State<Dashboard> {

  static const Color _pageBackground = Color(0xFFFFFBF7);
  static const Color _pageBackgroundSoft = Color(0xFFF6F1E8);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceMuted = Color(0xFFF8F4ED);
  static const Color _surfaceTint = Color(0xFFF0F6EE);
  static const Color _primaryText = Color(0xFF203127);
  static const Color _secondaryText = Color(0xFF6E766F);
  static const Color _border = Color(0xFFEAE3D8);
  static const Color _primaryGreen = Color(0xFF2F7A4B);
  static const Color _accentGold = Color(0xFFC49557);
  static const Color _chartAchieved = Color(0xFF5AB7D6);
  static const Color _chartPending = Color(0xFF84AEE8);
  static const Color _softShadow = Color(0x142C302A);

  getOption() {
    var option = '''{
    legend: {
      data: // Use your data here
    },
    grid: {left: '3%', right: '4%', bottom: '3%', containLabel: true},
    xAxis: [
      {
        type: 'category',
        data: // Use your data here,
      }
    ],
    yAxis: [
      {type: 'value'}
    ],
    series: [
      {
        name: // Use your data here,
        type: 'bar',
        stack: 'test',
        emphasis: {focus: 'series'},
        data: // Use your data here
      },
      {
        name: // Use your data here,
        type: 'bar',
        stack: 'test',
        emphasis: {focus: 'series'},
        data: // Use your data here
      },
      {
        name: // Use your data here,
        type: 'bar',
        stack: 'test',
        emphasis: {focus: 'series'},
        data: // Use your data here
      },
      {
        name: // Use your data here,
        type: 'bar',
        stack: 'test',
        emphasis: {focus: 'series'},
        data: // Use your data here
      },
      {
        name: // Use your data here,
        type: 'bar',
        stack: 'test',
        emphasis: {focus: 'series'},
        data: // Use your data here
      },
    ]
    }''';
  }

  static const names = ['Canola', 'Olive'];

  String? cdate, targettype;
  int canola_achie = 0,
      olive_achie = 0,
      mustard_achie = 0,
      pomace_achie = 0,
      canola_target = 0,
      olive_target = 0,
      wheatgrass_target = 0,
      wheatgrass_achie = 0;

  List<ChartData> chartdata = [];

  final List category = ['Canola', 'Olive', 'Wheatgrass'];

  static final random = Random();

  static int generateRndInt({
    final int min = 0,
    final int max = 1,
  }) =>
      min + random.nextInt(max - min + 1);

  static int get rndInt {
    const value = 250;
    return value == 2 ? 0 : value;
  }

  static double getMeasure(final int value) => value.toDouble();

  TextEditingController dateController = TextEditingController();
  final DatabaseHelper dbManager = DatabaseHelper();
  int version = 0;
  String device = "";
  String name = "";
  List<Item> itemdata = [];
  bool _isLoading = false;
  Future<List<ChartData>>? userdetails;
  String personName = "";
  int target = 0, userid = 0, total_target = 0;
  final gradientList = <List<Color>>[
    [
      _chartPending,
      _chartPending,
    ],
    [
      _chartAchieved,
      _chartPending,
    ],
  ];
  // String imei="",modelno="",devicename="";
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );
  int difference = 0;
  List<Color> colorList = [
    _chartAchieved,
    _chartPending,
  ];
  var locations = [
    {
      'country': 'Japan',
      'city': 'Tokyo',
      'Latitude': 35.6762,
      'Longitude': 139.6503,
      'utcOffset': 9,
    }
  ];

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    getuserdetails('Userdetails');
    cdate = getcurrentdate();

    askpermission();
    getdetails();
    name = SharedPrefClass.getString(PERSON_NAME);
    DateTime now = DateTime.now();
    final d1 = DateTime.now();
    final date = DateTime(now.year, now.month + 1, 0);

    setState(() {
      difference = date.difference(d1).inDays + 2;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _isLoading = false;
      });
    });

    getSKU('GetShopsItemData').then((value) => {savelocaldb(value)});
  }

  void getdetails() async {
    try {
      // imei = await DeviceInformation.deviceIMEINumber;
      // modelno = await DeviceInformation.deviceModel;
      // devicename = await DeviceInformation.deviceName;
    } catch (e) {
      print("exception $e");
    }
  }

  Future<void> saveversion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    var response = await http.post(Uri.parse(
        '${SharedPrefClass.getString(IP_URL)}checkLatestAppVersion?id=$userid&device=${androidInfo.model}&appversion=$_packageInfo'));
    final list = jsonDecode(response.body);
  }

  Future<void> savelocaldb(value) async {
    itemdata = value
        .map<Item>((m) => Item.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    await DatabaseHelper.deleteall();
    int? id = await dbManager.insertdata(itemdata);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      _buildHeroHeader(),
                      const SizedBox(height: 18),
                      // _buildShopSummarySection(),
                      // const SizedBox(height: 18),
                      _buildTargetOverviewSection(),
                      const SizedBox(height: 18),
                      _buildPerformanceSection(),

                    ],
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SalesEntry()));
        },
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Sale",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    final groupName = SharedPrefClass.getString(GROUP).isEmpty
        ? "Sales Dashboard"
        : SharedPrefClass.getString(GROUP);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F5E7),
            Color(0xFFF8F3E8),
            Color(0xFFE3F0E2),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: _softShadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Performance",
                      style: TextStyle(
                        color: _accentGold,
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Welcome back,\n$name",
                      style: const TextStyle(
                        color: _primaryText,
                        fontSize: 24,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: _accentGold, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      groupName,
                      style: const TextStyle(
                        color: _primaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Text(
          //   "Track targets, progress, and monthly sales movement in one place.",
          //   style: TextStyle(
          //     color: _secondaryText,
          //     fontSize: 13,
          //     height: 1.4,
          //   ),
          // ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHeroMiniStat(
                  "Days Left",
                  difference.toString(),
                  Icons.calendar_month_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeroMiniStat(
                  "Unit",
                  targettype ?? "--",
                  Icons.bar_chart_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _surfaceTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryGreen, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
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
    );
  }

  Widget _buildShopSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Shop Summary",
          style: TextStyle(
            color: _primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _buildStatCard(
        //         "Assigned",
        //         SharedPrefClass.getString(ASSIGNED).isEmpty
        //             ? "0"
        //             : SharedPrefClass.getString(ASSIGNED),
        //         "Total shops mapped",
        //         const Color(0xFF0C5B35),
        //         Icons.storefront_rounded,
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     Expanded(
        //       child: _buildStatCard(
        //         "Covered",
        //         SharedPrefClass.getString(COVERED).isEmpty
        //             ? "0"
        //             : SharedPrefClass.getString(COVERED),
        //         "Visited this cycle",
        //         const Color(0xFF8A6C45),
        //         Icons.location_on_rounded,
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 12),
        // _buildStatCard(
        //   "Productive Shops",
        //   SharedPrefClass.getString(PRODUCTIVE).isEmpty
        //       ? "0"
        //       : SharedPrefClass.getString(PRODUCTIVE),
        //   "Shops that converted into sales",
        //   const Color(0xFF2F6EAA),
        //   Icons.trending_up_rounded,
        //   fullWidth: true,
        // ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color accent,
    IconData icon, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: _softShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _primaryText,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetOverviewSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: _softShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Target Overview",
            style: TextStyle(
              color: _primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total_target == 0
                ? "Monthly target and daily pace"
                : "Product-wise target split",
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          if (SharedPrefClass.getString(GROUP) == "Wheatgrass")
            Row(
              children: [
                Expanded(
                  child: _buildTargetTile(
                    "Wheatgrass",
                    wheatgrass_target.toString(),
                    targettype ?? "Boxes",
                    _primaryGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTargetTile(
                    "Achieved",
                    wheatgrass_achie.toString(),
                    "This month",
                    _accentGold,
                  ),
                ),
              ],
            )
          else if (total_target == 0)
            Row(
              children: [
                Expanded(
                  child: _buildTargetTile(
                    "Target",
                    target.toString(),
                    targettype ?? "Ltrs",
                    _primaryGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTargetTile(
                    "Per Day",
                    difference == 0
                        ? "0"
                        : (target / difference).round().toString(),
                    "Recommended pace",
                    _accentGold,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildTargetTile(
                    "Canola",
                    canola_target.toString(),
                    targettype ?? "Ltrs",
                    _primaryGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTargetTile(
                    "Olive",
                    olive_target.toString(),
                    targettype ?? "Ltrs",
                    _accentGold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTargetTile(
      String label, String value, String helper, Color accentColor) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _surfaceMuted,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accentColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              helper,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 10,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return FutureBuilder(
        future: userdetails,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _border),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _border),
              boxShadow: const [
                BoxShadow(
                  color: _softShadow,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Performance Insights",
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total_target == 0
                      ? "See how much of the monthly target has been closed."
                      : "Compare achieved volume against remaining target.",
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                total_target == 0
                    ? _buildPiePerformanceCard()
                    : _buildBarPerformanceCard(),
              ],
            ),
          );
        });
  }

  Widget _buildPiePerformanceCard() {
    final int pending = max(target - canola_achie, 0);
    final double completion = target == 0 ? 0 : canola_achie / target;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceMuted,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTargetTile(
                  "Achieved",
                  canola_achie.toString(),
                  "Closed so far",
                  _chartAchieved,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildTargetTile(
                  "Pending",
                  pending.toString(),
                  "${(completion * 100).clamp(0, 100).toStringAsFixed(0)}% complete",
                  _chartPending,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Pie.PieChart(
          dataMap: {
            "Pending": pending.toDouble(),
            "Achieved": canola_achie.toDouble(),
          },
          colorList: colorList,
          chartRadius: MediaQuery.of(context).size.width / 3.1,
          centerText: "Target",
          ringStrokeWidth: 20,
          animationDuration: const Duration(seconds: 3),
          chartValuesOptions: const Pie.ChartValuesOptions(
            showChartValues: true,
            showChartValuesOutside: true,
            showChartValuesInPercentage: false,
            showChartValueBackground: false,
          ),
          legendOptions: const Pie.LegendOptions(
            showLegends: true,
            legendShape: BoxShape.rectangle,
            legendTextStyle: TextStyle(fontSize: 14),
            legendPosition: Pie.LegendPosition.bottom,
            showLegendsInRow: true,
          ),
          gradientList: gradientList,
        ),
      ],
    );
  }

  Widget _buildBarPerformanceCard() {
    final double axisMax = max(
      max(canola_target, olive_target).toDouble(),
      chartdata.fold<double>(
          0, (prev, item) => max(prev, (item.y1 + item.y2).toDouble())),
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _buildLegendChip("Achieved", _chartAchieved),
              _buildLegendChip("Pending", _chartPending),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: SfCartesianChart(
            margin: const EdgeInsets.fromLTRB(6, 10, 10, 10),
            plotAreaBorderWidth: 0,
            primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              axisLine: AxisLine(width: 0),
            ),
            primaryYAxis: NumericAxis(
              interval: axisMax <= 100 ? 20 : 100,
              maximum: axisMax <= 0 ? 100 : axisMax,
              majorGridLines: const MajorGridLines(
                width: 1,
                color: _border,
              ),
              axisLine: const AxisLine(width: 0),
            ),
            palette: const <Color>[
              _chartAchieved,
              _chartPending,
            ],
            series: [
              if (canola_target != 0)
                StackedColumnSeries<ChartData, String>(
                  borderRadius: BorderRadius.circular(8),
                  dataLabelSettings: const DataLabelSettings(
                    labelAlignment: ChartDataLabelAlignment.bottom,
                    isVisible: true,
                  ),
                  dataSource: chartdata,
                  xValueMapper: (ChartData ch, _) => ch.x,
                  yValueMapper: (ChartData ch, _) => ch.y1,
                  dataLabelMapper: (ChartData ch, _) =>
                      ch.y1 <= 0 ? '' : ch.y1.toString(),
                  width: 0.42,
                  spacing: 0.25,
                ),
              StackedColumnSeries<ChartData, String>(
                borderRadius: BorderRadius.circular(8),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
                dataSource: chartdata,
                xValueMapper: (ChartData ch, _) => ch.x,
                yValueMapper: (ChartData ch, _) => ch.y2,
                dataLabelMapper: (ChartData ch, _) =>
                    ch.y2 <= 0 ? '' : ch.y2.toString(),
                width: 0.42,
                spacing: 0.25,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendChip(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: _secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<Logindetails> getuserdetails(String endpoint) async {
    int userid = 0;

    Logindetails details;
    userid = SharedPrefClass.getInt(USER_ID);
    print("SharedPref ${SharedPrefClass.getString(IP_URL)}");
    var response = await http.post(Uri.parse(
        '${SharedPrefClass.getString(IP_URL)}$endpoint?userId=$userid'));
    final list = jsonDecode(response.body);

    if (response.statusCode == 200) {
      details = Logindetails.fromJson(json.decode(response.body));

      SharedPrefClass.setString(ATT_STATUS, details.attStatus.toString());
      SharedPrefClass.setInt(
          DISTANCE_ALLOWED, details.distanceAllowed!.toInt());
      SharedPrefClass.setInt(USER_ID, details.personId);
      SharedPrefClass.setString(PERSON_TYPE, details.personType.toString());
      SharedPrefClass.setString(PERSON_NAME, details.personName.toString());
      SharedPrefClass.setString(GROUP, details.group.toString());
      SharedPrefClass.setInt(TARGET, details.target!.toInt());
      SharedPrefClass.setString(ASSIGNED, details.assignedshops.toString());
      SharedPrefClass.setString(COVERED, details.coveredshops.toString());
      SharedPrefClass.setString(PRODUCTIVE, details.productiveshops.toString());

      if (details.personId != 0) {
        if (details.group == "GT" || details.group == "MT") {
          if (details.totaltarget == 0) {
            setState(() {
              total_target = 0;
              target = details.target!.toInt();
              targettype = "Ltrs";
            });
          } else {
            setState(() {
              total_target = 1;
              canola_target = details.canola!.toInt();
              olive_target = details.olive!.toInt();
              targettype = "Ltrs";
            });
          }
        } else {
          if (details.target != 0) {
            setState(() {
              total_target = 1;
              wheatgrass_target = details.target!.toInt();
              targettype = "Boxes";
            });
          } else {
            setState(() {
              total_target = 1;
              wheatgrass_target = details.wheatgrass!.toInt();
              targettype = "Boxes";
            });
          }
        }
      }
    } else {
      throw Exception('Failed to load data');
    }
    userdetails = gettargetdata();
    return details;
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Canola';
        break;
      case 1:
        text = 'Mustard';
        break;
      case 2:
        text = 'Olive';
        break;
      case 3:
        text = 'Pomace';
        break;
      case 4:
        text = 'Ex Virgin';
        break;
      case 5:
        text = 'Ghee';
        break;
      case 6:
        text = 'GOLD';
        break;
      case 7:
        text = 'SOYA';
        break;
      case 8:
        text = 'SUN';
        break;
      default:
        text = '';
        break;
    }

    return SideTitleWidget(
      child: Text(text, style: style),
      space: 6,
      meta: meta,
    );
  }

  List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
    return [
      BarChartGroupData(
        x: 0,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 250,
            rodStackItems: [
              BarChartRodStackItem(0, 200, widget.dark),
              BarChartRodStackItem(200, 250, widget.normal),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 300,
            rodStackItems: [
              BarChartRodStackItem(0, 200, widget.dark),
              BarChartRodStackItem(200, 300, widget.normal),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 400,
            rodStackItems: [
              BarChartRodStackItem(0, 200, widget.dark),
              BarChartRodStackItem(200, 400, widget.normal),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
    ];
  }

  Future<List<ChartData>> gettargetdata() async {
    chartdata.clear();
    canola_achie = 0;
    olive_achie = 0;
    wheatgrass_achie = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getInt(USER_ID)!;
    List<monthlyitem> detailslist = [];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(
        Uri.parse(
            '${SharedPrefClass.getString(IP_URL)}GetPersonMonthlyItemReport?id=$userid&date=$cdate'),
        headers: headers);

    if (response.body.isNotEmpty) {
      try {
        num val = 0;
        final list = jsonDecode(response.body);

        detailslist = list
            .map<monthlyitem>(
                (m) => monthlyitem.fromJson(Map<String, dynamic>.from(m)))
            .toList();

        if (targettype == "Ltrs") {
          if (total_target == 0) {
            for (int i = 0; i < detailslist.length; i++) {
              setState(() {
                canola_achie += detailslist[i].quantity!.toInt();
              });
            }
          } else {
            for (int i = 0; i < detailslist.length; i++) {
              if (detailslist[i].itemType == 2 ||
                  detailslist[i].itemType == 5 ||
                  detailslist[i].itemType == 8) {
                setState(() {
                  olive_achie += detailslist[i].quantity!.toInt();
                });
                print("else if ${olive_achie}");
              } else if (detailslist[i].itemType == 1) {
                setState(() {
                  canola_achie += detailslist[i].quantity!.toInt();
                });

                print("canola ${canola_achie}");
              }
            }

            // setState(() {
            //   chartdata = [
            //     ChartData(category[0], 10,200),
            //     ChartData(category[1], 29,2)
            //   ];
            // });
            //   print("canola$canola_target $canola_achie");
            //   print("olive $olive_target $olive_achie");
            print(
                "canola ${category[1]} $olive_achie ${olive_target - olive_achie}");

            // chartdata = [
            //  ChartData(category[0],canola_achie,canola_target-canola_achie),
            //  ChartData(category[1],olive_achie,olive_target-olive_achie),
            // ];

            chartdata = [
              ChartData(
                category[0],
                canola_achie,
                max(canola_target - canola_achie, 0),
              ),
              ChartData(
                category[1],
                olive_achie,
                max(olive_target - olive_achie, 0),
              ),
            ];
          }
        } else {
          print("else if ");
          for (int i = 0; i < detailslist.length; i++) {
            setState(() {
              wheatgrass_achie += detailslist[i].quantity!.toInt();
            });
          }

          setState(() {
            chartdata.add(ChartData(
              category[2],
              wheatgrass_achie,
              max(wheatgrass_target - wheatgrass_achie, 0),
            ));
          });
        }
      } catch (e) {
        print("exception$e");
      }
    }

    return chartdata;
  }
  
}

class ChartData {
  final String x;
  final int y1;
  final int y2;
  ChartData(this.x, this.y1, this.y2);
}
