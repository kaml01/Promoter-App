class monthlyitem {

  String? itemName;
  int? itemType;
  int? pieces;
  int? quantity;
  num? boxes;
  Null uOM;
  Null schemeApprovedById;
  Null schemeApprovedByName;
  Null isScheme;

  monthlyitem(
      {this.itemName,
        this.itemType,
        this.pieces,
        this.quantity,
        this.boxes,
        this.uOM,
        this.schemeApprovedById,
        this.schemeApprovedByName,
        this.isScheme});

  monthlyitem.fromJson(Map<String, dynamic> json) {
    itemName = json['itemName'];
    itemType = json['itemType'];
    pieces = json['pieces'];
    quantity = json['quantity'];
    boxes = json['boxes'];
    uOM = json['UOM'];
    schemeApprovedById = json['schemeApprovedById'];
    schemeApprovedByName = json['schemeApprovedByName'];
    isScheme = json['isScheme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemName'] = this.itemName;
    data['itemType'] = this.itemType;
    data['pieces'] = this.pieces;
    data['quantity'] = this.quantity;
    data['boxes'] = this.boxes;
    data['UOM'] = this.uOM;
    data['schemeApprovedById'] = this.schemeApprovedById;
    data['schemeApprovedByName'] = this.schemeApprovedByName;
    data['isScheme'] = this.isScheme;
    return data;
  }
}