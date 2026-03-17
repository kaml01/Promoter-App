class Logindetails {

  Logindetails({
    required this.personId,
    required this.personType,
    required this.personName,
    required this.userName,
    required this.group,
    required this.target,
    required this.targetBoxes,
    required this.distanceAllowed,
    required this.attStatus,
    required this.canola,
    required this.olive,
    required this.gold,
    required this.mustard,
    required this.sunflower,
    required this.soyabean,
    required this.cottonseed,
    required this.wheatgrass,
    required this.naturalmineralwater,
    required this.plainsoda,
    required this.flavouredsoda,
  });

  int personId=0;
  String? personType;
  String? personName;
  String? userName;
  String? group;
  int? target;
  int? targetBoxes;
  int? assignedshops;
  int? coveredshops;
  int? productiveshops;
  int? distanceAllowed;
  int? canola;
  int? olive;
  int? gold;
  int? mustard;
  int? sunflower;
  int? soyabean;
  int? cottonseed;
  int? wheatgrass;
  int? naturalmineralwater;
  int? plainsoda;
  int? flavouredsoda;
  String? attStatus;
  int? totaltarget;

  Logindetails.fromJson(Map<String, dynamic> json) {
    personId = json['personID'];
    personType = json['personType'];
    personName = json['personName'];
    userName = json['userName'];
    group = json['group'];
    target = json['target'];
    targetBoxes = json['targetBoxes'];
    assignedshops = json['AssignedShops'];
    coveredshops = json['shopsCovered'];
    productiveshops = json['shopsProductive'];
    distanceAllowed = json['distanceAllowed'];
    attStatus=json['attStatus'];
    canola = json['canola'];
    olive = json['olive'];
    gold = json['gold'];
    sunflower = json['sunflower'];
    soyabean = json['soyabean'];
    cottonseed = json['cottonseed'];
    wheatgrass=json['wheatgrass'];
    naturalmineralwater = json['naturalmineralwater'];
    plainsoda = json['plainsoda'];
    flavouredsoda = json['flavouredsoda'];
    attStatus = json['attStatus'];
    totaltarget = json['totaltarget'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['personID'] = this.personId;
    data['personType'] = this.personType;
    data['personName'] = this.personName;
    data['userName'] = this.userName;
    data['group'] = this.group;
    data['target'] = this.target;
    data['targetBoxes'] = this.targetBoxes;
    data['AssignedShops'] = this.assignedshops;
    data['shopsCovered'] = this.coveredshops;
    data['shopsProductive'] = this.productiveshops;
    data['distanceAllowed'] = this.distanceAllowed;
    data['attStatus']=this.attStatus;
    data['personName'] = this.personName;
    data['canola'] = this.canola;
    data['olive'] = this.olive;
    data['gold'] = this.gold;
    data['sunflower'] = this.sunflower;
    data['soyabean'] = this.soyabean;
    data['cottonseed'] = this.coveredshops;
    data['wheatgrass'] = this.wheatgrass;
    data['naturalmineralwater'] = this.naturalmineralwater;
    data['plainsoda']=this.plainsoda;
    data['flavouredsoda']=this.flavouredsoda;
    data['attStatus']=this.attStatus;
    data['totaltarget']=this.totaltarget;
    return data;
  }

}