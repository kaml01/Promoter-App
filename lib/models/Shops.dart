class Shops {
  int? retailerID;
  String? retailerName;
  String? address;
  String? state;
  String? zone;
  String? area;
  String? subArea;
  String? contactPerson;
  String? contactNo;
  String? mobileNo;
  int? pincode;
  String? threeMonthAvg;
  String? sixMonthAvg;
  String? group;
  String? currentMonthSale;
  String? lastVisitStatus;
  String? lastVisitSale;
  int? lastMonthSale;
  int? lastMonthSaleBoxes;
  String? beatName;
  int? beatId;
  String? covered;
  int? target;
  String? offset;
  String? lastVisitDate;
  String? latitude;
  String? longitude;
  int? bestSale;
  String? gSTNum;
  String? type;
  int? vTarget;
  int? vDone;
  String? email;
  String? dob;

  Shops(
      {this.retailerID,
        this.retailerName,
        this.address,
        this.state,
        this.zone,
        this.area,
        this.subArea,
        this.contactPerson,
        this.contactNo,
        this.mobileNo,
        this.pincode,
        this.threeMonthAvg,
        this.sixMonthAvg,
        this.group,
        this.currentMonthSale,
        this.lastVisitStatus,
        this.lastVisitSale,
        this.lastMonthSale,
        this.lastMonthSaleBoxes,
        this.beatName,
        this.beatId,
        this.covered,
        this.target,
        this.offset,
        this.lastVisitDate,
        this.latitude,
        this.longitude,
        this.bestSale,
        this.gSTNum,
        this.type,
        this.vTarget,
        this.vDone,
        this.email,
        this.dob});


  factory Shops.fromJson(Map<String, dynamic> json) {
    return Shops(
        retailerID : json['retailerID'],
        retailerName : json['retailerName'],
        address : json['address'],
        state : json['state'],
        zone : json['zone'],
        area : json['area'],
        subArea : json['subArea'],
        contactPerson : json['contactPerson'],
        contactNo : json['contactNo'],
        mobileNo : json['mobileNo'],
        pincode : json['pincode'],
        threeMonthAvg : json['threeMonthAvg'],
        sixMonthAvg : json['sixMonthAvg'],
    group : json['group'],
    currentMonthSale : json['currentMonthSale'],
    lastVisitStatus : json['lastVisitStatus'],
    lastVisitSale : json['lastVisitSale'],
    lastMonthSale : json['lastMonthSale'],
    lastMonthSaleBoxes : json['lastMonthSaleBoxes'],
    beatName : json['beatName'],
    beatId : json['beatId'],
    covered : json['covered'],
    target : json['target'],
    offset : json['offset'],
    lastVisitDate : json['lastVisitDate'],
    latitude : json['latitude'],
    longitude : json['longitude'],
    bestSale : json['bestSale'],
    gSTNum : json['GSTNum'],
    type : json['type'],
    vTarget : json['vTarget'],
    vDone : json['vDone'],
    email : json['email'],
    dob : json['dob']);
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['retailerID'] = this.retailerID;
    data['retailerName'] = this.retailerName;
    data['address'] = this.address;
    data['state'] = this.state;
    data['zone'] = this.zone;
    data['area'] = this.area;
    data['subArea'] = this.subArea;
    data['contactPerson'] = this.contactPerson;
    data['contactNo'] = this.contactNo;
    data['mobileNo'] = this.mobileNo;
    data['pincode'] = this.pincode;
    data['threeMonthAvg'] = this.threeMonthAvg;
    data['sixMonthAvg'] = this.sixMonthAvg;
    data['group'] = this.group;
    data['currentMonthSale'] = this.currentMonthSale;
    data['lastVisitStatus'] = this.lastVisitStatus;
    data['lastVisitSale'] = this.lastVisitSale;
    data['lastMonthSale'] = this.lastMonthSale;
    data['lastMonthSaleBoxes'] = this.lastMonthSaleBoxes;
    data['beatName'] = this.beatName;
    data['beatId'] = this.beatId;
    data['covered'] = this.covered;
    data['target'] = this.target;
    data['offset'] = this.offset;
    data['lastVisitDate'] = this.lastVisitDate;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['bestSale'] = this.bestSale;
    data['GSTNum'] = this.gSTNum;
    data['type'] = this.type;
    data['vTarget'] = this.vTarget;
    data['vDone'] = this.vDone;
    data['email'] = this.email;
    data['dob'] = this.dob;
    return data;
  }
}