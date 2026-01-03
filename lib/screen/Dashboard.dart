import 'package:shared_preferences/shared_preferences.dart';
// import 'package:device_information/device_information.dart';
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
import 'package:promoterapp/config/Color.dart';
import 'package:promoterapp/models/Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../util/functionhelper.dart';
import '../models/monthlyItem.dart';
import 'dart:convert';
import 'dart:math';

class Dashboard extends StatefulWidget{

  final Color dark = Colors.cyan;
  final Color normal =  Colors.blue;
  final Color light =  Colors.white;

  @override
  State<StatefulWidget> createState() {
    return Dashboardstate();
  }

}

class Dashboardstate extends State<Dashboard>{

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

  static const names = [
    'Canola','Olive'
  ];

  String? cdate,targettype;
  int canola_achie=0,olive_achie=0,mustard_achie=0,pomace_achie=0,
      canola_target=0,olive_target=0,wheatgrass_target=0,wheatgrass_achie=0;

  List<ChartData> chartdata=[];

  final List category=[
    'Canola','Olive','Wheatgrass'
  ];

  static final random = Random();

  static int generateRndInt({
    final int min = 0,
    final int max = 1,
  }) => min + random.nextInt(max - min + 1);

  static int get rndInt
  {
    const value = 250;
    return value == 2 ? 0 : value;
  }

  static double getMeasure(final int value) => value.toDouble();

  TextEditingController dateController = TextEditingController();
  final DatabaseHelper dbManager = DatabaseHelper();
  int version=0;
  String device="";
  String name="";
  List<Item> itemdata = [];
  bool _isLoading = false;
  Future<List<ChartData>>? userdetails;
  String personName="";
  int target = 0,userid=0,total_target=0;
  final gradientList = <List<Color>>[
    [
      Color.fromRGBO(91, 253, 199, 1),
      Color.fromRGBO(91, 253, 199, 1),
    ],
    [
      Color.fromRGBO(129, 182, 205, 1),
      Color.fromRGBO(91, 253, 199, 1),
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
  int difference =0 ;
  List<Color> colorList = [
    const Color(0xff3EE094),
    const Color(0xffD95AF3),
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
      difference = date.difference(d1).inDays+2;
    });

    Future.delayed(const Duration(milliseconds: 600), () {

      setState(() {
        _isLoading = false;
      });

    });

    getSKU('GetShopsItemData').then((value) => {

      savelocaldb(value)

    });

  }

  void getdetails() async{

    try {

      // imei = await DeviceInformation.deviceIMEINumber;
      // modelno = await DeviceInformation.deviceModel;
      // devicename = await DeviceInformation.deviceName;

    } catch(e){
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

    var response = await http.post(Uri.parse('${SharedPrefClass.getString(IP_URL)}checkLatestAppVersion?id=$userid&device=${androidInfo.model}&appversion=$_packageInfo'));
    final list = jsonDecode(response.body);

  }

  Future<void> savelocaldb(value) async {

    itemdata = value.map<Item>((m) => Item.fromJson(Map<String, dynamic>.from(m))).toList();
    await DatabaseHelper.deleteall();
    int? id = await dbManager.insertdata(itemdata);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _isLoading?const Center(
          child:CircularProgressIndicator()
      ):Column(
        children: [

          Container(
            margin: const EdgeInsets.all(10),
            child: Text("Welcome $name",
              style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w300),),
          ),

          SharedPrefClass.getString(GROUP)=="Wheatgrass"?
          Container(
              color: light_grey,
              padding:  const EdgeInsets.only(top: 10),
              child: Column(
                children: [

                  Row(
                    children: [

                      Expanded(
                          child:Center(
                            child:  Text("Wheatgrass",
                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                          )
                      ),

                      Expanded(
                          child: Center(
                              child: Text(wheatgrass_target.toString(),
                                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w700),)
                          )
                      ),

                    ],
                  ),

                ],
               )) : Container(
               color: light_grey,
               padding:  const EdgeInsets.only(top: 10),
               child: Column(
                children: [

                  Row(
                    children: [

                      Expanded(
                          child:Center(
                            child:  Text(total_target==0?"Target":"Canola",
                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                          )
                      ),

                      Expanded(
                          child: Center(
                              child: Text(total_target==0?"Per day":"Olive",
                                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w700),)
                          )
                      ),

                    ],
                  ),

                  Row(
                    children: [

                      Expanded(
                        child: Center(
                          child: Text(total_target==0?target.toString():canola_target.toString(),
                            style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                        ),
                      ),

                      Expanded(
                          child: Center(
                            child:  Text(total_target==0?(target/difference).round().toString():olive_target.toString(),
                              style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                          )
                      ),

                    ],
                  )

             ],
          )),

          const SizedBox(height: 30),

          total_target==0?Pie.PieChart(
               dataMap: {
                 "Pending":  (target-canola_achie).toDouble(),
                 "Achieved": canola_achie.toDouble(),
               },
               colorList: colorList,
               chartRadius: MediaQuery
                   .of(context)
                   .size
                   .width / 3,
               centerText: "Target",
               ringStrokeWidth: 24,
               animationDuration: const Duration(seconds: 3),
               chartValuesOptions: const Pie.ChartValuesOptions(
                   showChartValues: true,
                   showChartValuesOutside: true,
                   showChartValuesInPercentage: false,
                   showChartValueBackground: false),
               legendOptions: const Pie.LegendOptions(
                   showLegends: true,
                   legendShape: BoxShape.rectangle,
                   legendTextStyle: TextStyle(fontSize: 15),
                   legendPosition: Pie.LegendPosition.bottom,
                   showLegendsInRow: true),
              gradientList: gradientList):

          FutureBuilder(
              future: userdetails,
              builder: (context,snapshot){
                if(snapshot.hasData){
                  return Container(
                      margin: const EdgeInsets.all(10),
                      color: light_grey,
                      child:Column(
                        // children: [
                        //
                        //   AspectRatio(
                        //     aspectRatio: 1.55,
                        //     child: Padding(
                        //         padding: const EdgeInsets.only(top: 50),
                        //         child: SfCartesianChart(
                        //           primaryXAxis: const CategoryAxis(),
                        //           primaryYAxis: NumericAxis(
                        //             interval: 100,
                        //             maximum: canola_target!=0?canola_target.toDouble():wheatgrass_target.toDouble(),
                        //           ),
                        //           palette: const <Color>[
                        //             Color(0xFF44BFE5),
                        //             Color(0xFF2888E0),
                        //           ],
                        //           series: [
                        //
                        //             StackedColumnSeries<ChartData,String>(
                        //                 dataLabelSettings: const DataLabelSettings(
                        //                     labelAlignment: ChartDataLabelAlignment.bottom,
                        //                     isVisible:true,showCumulativeValues:true),
                        //                 dataSource: chartdata,
                        //                 xValueMapper: (ChartData ch,_)=>ch.x,
                        //                 yValueMapper: (ChartData ch,_)=>ch.y1,
                        //                 width: 0.4,
                        //                 spacing: 0.2),
                        //
                        //             StackedColumnSeries<ChartData,String>(
                        //                 dataLabelSettings: const DataLabelSettings(isVisible:true,showCumulativeValues:true),
                        //                 dataSource: chartdata,
                        //                 xValueMapper: (ChartData ch,_)=>ch.x,
                        //                 yValueMapper: (ChartData ch,_)=>ch.y2,
                        //                 width: 0.4,
                        //                 spacing: 0.2),
                        //
                        //           ],
                        //         )
                        //     ),
                        //   ),
                        //
                        //   Container(
                        //     margin: EdgeInsets.only(top: 10, bottom: 10),
                        //     width: double.infinity,
                        //     child: Center(
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //
                        //           Container(
                        //             decoration: BoxDecoration(
                        //               shape: BoxShape.rectangle,
                        //               color: Color(0xFF44BFE5),
                        //             ),
                        //             width: 20,
                        //             height: 20,
                        //           ),
                        //           SizedBox(width: 10),
                        //           Container(
                        //             child: Text("Achieved"),
                        //           ),
                        //           SizedBox(width: 20),
                        //           Container(
                        //             decoration: BoxDecoration(
                        //               shape: BoxShape.rectangle,
                        //               color: Color(0xFF2888E0),
                        //             ),
                        //             width: 20,
                        //             height: 20,
                        //           ),
                        //           SizedBox(width: 10),
                        //           Container(
                        //             child: Text("Pending"),
                        //           ),
                        //
                        //         ],
                        //       ),
                        //     ),
                        //   )
                        //
                        // ],

                        children: [
                          AspectRatio(
                            aspectRatio: 1.55,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: SfCartesianChart(
                                primaryXAxis: const CategoryAxis(),
                                primaryYAxis: NumericAxis(
                                  interval: 100,
                                  maximum: canola_target != 0 ? canola_target.toDouble() : olive_target.toDouble(),
                                ),
                                palette: const <Color>[
                                  Color(0xFF44BFE5), // Canola Color
                                  Color(0xFF2888E0), // Olive Color
                                ],
                                series: [
                                  // Show canola data only if target is not zero
                                  if (canola_target != 0)
                                    StackedColumnSeries<ChartData, String>(
                                      dataLabelSettings: const DataLabelSettings(
                                        labelAlignment: ChartDataLabelAlignment.bottom,
                                        isVisible: true,
                                        showCumulativeValues: true,
                                      ),
                                      dataSource: chartdata,
                                      xValueMapper: (ChartData ch, _) => ch.x,
                                      yValueMapper: (ChartData ch, _) => ch.y1, // Assuming y1 is for canola
                                      width: 0.4,
                                      spacing: 0.2,
                                    ),

                                  // Always show olive data
                                  StackedColumnSeries<ChartData, String>(
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      showCumulativeValues: true,
                                    ),
                                    dataSource: chartdata,
                                    xValueMapper: (ChartData ch, _) => ch.x,
                                    yValueMapper: (ChartData ch, _) => ch.y2, // Assuming y2 is for olive
                                    width: 0.4,
                                    spacing: 0.2,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            width: double.infinity,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (canola_target != 0) ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Color(0xFF44BFE5),
                                      ),
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Achieved"),
                                    SizedBox(width: 20),
                                  ],
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Color(0xFF2888E0),
                                    ),
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text("Pending"),
                                ],
                              ),
                            ),
                          ),
                        ],

                      )
                  );
                }
                return Container();
            })

        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
           setState(() {

             Navigator.push(
                 context,
                 MaterialPageRoute(
                     builder: (context) =>
                         SalesEntry()));

           });
        },
        child: Icon(Icons.add),
      ),

    );
  }

  Future<Logindetails> getuserdetails(String endpoint) async {

    int userid=0;

    Logindetails details;
    userid = SharedPrefClass.getInt(USER_ID);
    print("SharedPref ${SharedPrefClass.getString(IP_URL)}")  ;
    var response = await http.post(Uri.parse('${SharedPrefClass.getString(IP_URL)}$endpoint?userId=$userid'));
    final list = jsonDecode(response.body);

    if (response.statusCode == 200) {

      details = Logindetails.fromJson(json.decode(response.body));

      SharedPrefClass.setString(ATT_STATUS,details.attStatus.toString());
      SharedPrefClass.setInt(DISTANCE_ALLOWED,details.distanceAllowed!.toInt());
      SharedPrefClass.setInt(USER_ID, details.personId);
      SharedPrefClass.setString(PERSON_TYPE, details.personType.toString());
      SharedPrefClass.setString(PERSON_NAME, details.personName.toString());
      SharedPrefClass.setString(GROUP, details.group.toString());
      SharedPrefClass.setInt(TARGET, details.target!.toInt());
      SharedPrefClass.setString(ASSIGNED, details.assignedshops.toString());
      SharedPrefClass.setString(COVERED, details.coveredshops.toString());
      SharedPrefClass.setString(PRODUCTIVE, details.productiveshops.toString());

      if (details.personId != 0) {

        if (details.group == "GT"||details.group == "MT") {

          if(details.totaltarget == 0){

            setState(() {
              total_target = 0;
              target = details.target!.toInt();
              targettype = "Ltrs";
            });

          }else{

              setState(() {
                total_target = 1;
                canola_target = details.canola!.toInt();
                olive_target = details.olive!.toInt();
                targettype = "Ltrs";
              });

          }

        } else {

          if(details.target!=0){

            setState(() {
              total_target = 1;
              wheatgrass_target = details.target!.toInt();
              targettype = "Boxes";
            });

          }else{

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getInt(USER_ID)!;
    List<monthlyitem> detailslist = [];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(Uri.parse('${SharedPrefClass.getString(IP_URL)}GetPersonMonthlyItemReport?id=$userid&date=$cdate'),
        headers: headers);

    if (response.body.isNotEmpty) {

      try {

        num val=0;
        final list = jsonDecode(response.body);

        detailslist = list.map<monthlyitem>((m) => monthlyitem.fromJson(Map<String, dynamic>.from(m))).toList();

        if(targettype=="Ltrs"){

          if(total_target==0){

            for(int i=0;i<detailslist.length;i++) {

                setState(() {
                  canola_achie += detailslist[i].quantity!.toInt();
                });

            }

          }else{

            for(int i=0;i<detailslist.length;i++) {

               if(detailslist[i].itemType == 2||detailslist[i].itemType == 5||detailslist[i].itemType == 8) {

                setState(() {
                  olive_achie += detailslist[i].quantity!.toInt();
                });
                print("else if ${olive_achie}");

              }else if (detailslist[i].itemType == 1) {

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
            print("canola ${category[1]} $olive_achie ${olive_target-olive_achie}");

              // chartdata = [
              //  ChartData(category[0],canola_achie,canola_target-canola_achie),
              //  ChartData(category[1],olive_achie,olive_target-olive_achie),
              // ];

            chartdata = [
              ChartData(category[0],canola_achie,canola_target-canola_achie),
              ChartData(category[1],olive_achie,olive_target-olive_achie),
            ];

          }

        }else{
          print("else if ");
          for(int i=0;i<detailslist.length;i++){

              setState(() {
               wheatgrass_achie += detailslist[i].quantity!.toInt();
             });

          }

          setState(() {
            chartdata.add(ChartData(category[2], wheatgrass_achie,wheatgrass_target-wheatgrass_achie));
          });

        }

      } catch (e) {
        print("exception$e");
      }

    }
    
    return chartdata;
  }

}

class ChartData{

  final String x;
  final int y1;
  final int y2;
  ChartData(this.x,this.y1,this.y2);

}







