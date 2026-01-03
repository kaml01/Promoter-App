import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promoterapp/config/Color.dart';
import 'package:promoterapp/provider/DropdownProvider.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget{

  String skulist="",image="";
  int skuid,idx=0;
  num quantity=0.0;

  MyWidget(this.skulist,this.skuid,this.image,this.idx,this.quantity);

  TextEditingController op_stock = TextEditingController();
  TextEditingController clo_stock = TextEditingController();
  TextEditingController samp_stock = TextEditingController();
  TextEditingController sale = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final dropdownOptionsProvider = Provider.of<DropdownProvider>(context);

    return Container(
        color: light_grey,
        width: double.infinity,
        margin: const EdgeInsets.only(left: 10, right: 10,top: 10),
        child: Column(
            children: [

              Card(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0)),),
                elevation: 10,
                shadowColor: Colors.black,
                child:Column(
                  children: [

                    Container(
                      decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
                      ),
                      padding: EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(skulist,style: TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                    ),

                    Container(
                      color: white,
                      padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                      child:Row(

                          children: [

                            Expanded(
                              flex:1,
                              child: Image.network(image,width: 50,height: 100),
                            ),

                            Expanded(
                                flex: 1,
                                child:Column(
                                  children: [
                                    //
                                    // SizedBox(
                                    //   width: 110,
                                    //   child: TextField(
                                    //     controller: op_stock,
                                    //     onChanged: (value){
                                    //       // if(page==""){
                                    //       dropdownOptionsProvider.addopeningstock(idx, int.parse(value), skuid);
                                    //       // }else{
                                    //       //   dropdownOptionsProvider.additemdropdown(idx, int.parse(value), skuid,quantity);
                                    //       // }
                                    //
                                    //     },
                                    //     keyboardType: TextInputType.number,
                                    //     decoration: InputDecoration(
                                    //         hintText: "Opening Stock"
                                    //     ),
                                    //     style: TextStyle(fontSize: 16.0, height: 2.0, color: Colors.black),
                                    //   ),
                                    // ),
                                    //
                                    // SizedBox(
                                    //   width: 110,
                                    //   child: TextField(
                                    //     controller: clo_stock,
                                    //     onChanged: (value){
                                    //
                                    //       // if(page==""){
                                    //       dropdownOptionsProvider.addclosingstock(idx, int.parse(value), skuid);
                                    //       // }else{
                                    //       //   dropdownOptionsProvider.additemdropdown(idx, int.parse(value), skuid,quantity);
                                    //       // }
                                    //
                                    //     },
                                    //     keyboardType: TextInputType.number,
                                    //     decoration: InputDecoration(
                                    //         hintText: "Closing Stock"
                                    //     ),
                                    //     style: TextStyle(fontSize: 16.0, height: 2.0, color: Colors.black),
                                    //   ),
                                    // ),

                                    SizedBox(
                                      width: 110,
                                      child: TextField(
                                        controller: samp_stock,
                                        onChanged: (value){

                                          dropdownOptionsProvider.addsamplestock(idx, int.parse(value), skuid);

                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText: "Sample Stock"
                                        ),
                                        style: TextStyle(fontSize: 16.0, height: 2.0, color: Colors.black),
                                      ),
                                    ),

                                    SizedBox(
                                      width: 110,
                                      child: TextField(
                                        controller: sale,
                                        onChanged: (value){
                                          // if(page==""){
                                          dropdownOptionsProvider.addsale(idx, int.parse(value), skuid,quantity);
                                          // }else{
                                          //   dropdownOptionsProvider.additemdropdown(idx, int.parse(value), skuid,quantity);
                                          // }

                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText: "Sale"
                                        ),
                                        style: TextStyle(fontSize: 16.0, height: 2.0, color: Colors.black),
                                      ),
                                    )

                                  ],
                                )
                            ),

                            // Expanded(
                            //     flex: 1,
                            //     child:GestureDetector(
                            //       onTap: (){
                            //         // dynamicList.remove(MyWidget("",0,""));
                            //       },
                            //       child: Image.asset('assets/Images/close.png',width: 20,height: 20,),
                            //     )
                            // ),

                          ]

                      ),
                    )

                  ],
                ),
              )

            ]
        )
    );

  }

}


