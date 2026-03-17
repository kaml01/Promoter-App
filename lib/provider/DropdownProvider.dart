import 'package:flutter/cupertino.dart';

class DropdownProvider extends ChangeNotifier{

  List<int> SKUid= [];
  List<int> selectedpieces= [];
  List<num> selectedquantity= [];
  List<num> open_stoc= [];
  List<num> clos_stoc= [];
  List<num> sampl_stoc= [];

  /*add item*/
  void addopeningstock(int index,int os ,int itemid){

    if (open_stoc.asMap().containsKey(index)) {

      open_stoc[index] = os;
      SKUid[index] = itemid;

    } else {

      open_stoc.insert(index, os);
      SKUid[index] = itemid;

    }

    notifyListeners();
  }

  /*add item*/
  void addclosingstock(int index,int os ,int itemid){

    if (clos_stoc.asMap().containsKey(index)) {

      clos_stoc.insert(index, os);
      SKUid[index] = itemid;

    } else {

      clos_stoc.insert(index, os);
      SKUid[index] = itemid;

    }

    notifyListeners();
  }

  /*add item*/
  void addsamplestock(int index,int pcs,int schemeid){

    if (sampl_stoc.asMap().containsKey(index)) {

      sampl_stoc.insert(index, pcs);
      SKUid[index] = schemeid;

    } else {

      sampl_stoc.insert(index, pcs);
      SKUid[index] = schemeid;

    }

    notifyListeners();

  }

  /*add item*/
  void addsale(int index,int pcs,int schemeid,num quanity){

    if (selectedpieces.asMap().containsKey(index)) {

      selectedpieces[index] = pcs;
      SKUid[index] = schemeid;
      selectedquantity[index] = quanity;

    } else {

      selectedpieces.insert(index,pcs);
      SKUid.insert(index,schemeid);
      selectedquantity.insert(index,quanity);

    }

    notifyListeners();
  }

  /*clear all list*/
  void remove(){

    SKUid.clear();
    selectedpieces.clear();
    selectedquantity.clear();
    notifyListeners();

  }

}