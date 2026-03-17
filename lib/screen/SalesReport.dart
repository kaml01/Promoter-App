import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promoterapp/config/Common.dart';
import 'package:promoterapp/models/Shops.dart';
import 'package:promoterapp/models/saalesreport.dart';
import 'package:promoterapp/screen/HomeScreen.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:promoterapp/util/ApiHelper.dart';
import 'package:promoterapp/util/Shared_pref.dart';
import 'package:promoterapp/util/functionhelper.dart';

class SalesReport extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return SalesReportState();
  }

}

class SalesReportState extends State<SalesReport> {

  bool _isLoading = false;
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

    print("retailerId ${SharedPrefClass.getInt(SHOP_ID)}");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Sales Reports",
              style: TextStyle(
                  color: Color(0xFF063A06), fontWeight: FontWeight.w400)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Color(0xFF063A06)),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            child: Icon(Icons.arrow_back, color: Color(0xFF063A06)),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: const Color(0xFFE8E4E4),
                child: Column(
                  children: [

                    SizedBox(
                      child: Row(
                        children: [

                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () async {
                                var date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100));
                                if (date != null) {
                                  setState(() {
                                    from =
                                        DateFormat('yyyy/MM/dd').format(date);
                                  });

                                  if (to != "") {
                                    getproreports(from, to);
                                  }
                                }
                              },
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  color: Colors.green,
                                  height: 40,
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/Images/Calender.png',
                                          width: 20,
                                          height: 20,
                                          alignment: Alignment.center,
                                        ),
                                        from == ""
                                            ? Text(
                                                "FROM",
                                                style: TextStyle(
                                                    color: Colors.white),
                                                textAlign: TextAlign.center,
                                              )
                                            : Text(
                                                "$from",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                                onTap: () async {
                                  var date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2100));
                                  if (date != null) {
                                    setState(() {
                                      to =
                                          DateFormat('yyyy/MM/dd').format(date);
                                    });

                                    if (from != "") {
                                      getproreports(from, to);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Please select from date",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                  }
                                },
                                child: Container(
                                    margin: EdgeInsets.all(10),
                                    color: Colors.green,
                                    height: 40,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              'assets/Images/Calender.png',
                                              width: 20,
                                              height: 20),
                                          to == ""
                                              ? Text(
                                                  "TO",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              : Text(
                                                  "$to",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                        ],
                                      ),
                                    ))),
                          )

                        ],
                      ),
                    ),

                    FutureBuilder<List<saalesreport>>(
                        future: report,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Expanded(
                                child: ListView.builder(
                                    physics: const ScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data?.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.all(2),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                snapshot.data![index].shopName
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(2),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                snapshot
                                                    .data![index].productName
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color(0xFF817373)),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(2),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${snapshot.data![index].pieces.toString()} pieces",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color(0xFF817373)),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(2),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                snapshot.data![index].timestamp
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color(0xFF817373)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                }
                              )
                            );
                          }
                          return Container();
                        })

                  ],
                ),
              ),
      ),
      onWillPop: () async  {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        return new Future(() => true);
      },
    );
  }

  void getproreports(String from, String to) {
    report = getreports('getPromoterTodaySale2', from, to);
  }

}
