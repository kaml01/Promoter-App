class saalesreport {
  String? timestamp;
  String? shopName;
  String? productName;
  String? pieces;
  String? totalQuantity;

  saalesreport(
      {this.timestamp,
        this.shopName,
        this.productName,
        this.pieces,
        this.totalQuantity});

  saalesreport.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    shopName = json['shopName'];
    productName = json['productName'];
    pieces = json['pieces'];
    totalQuantity = json['totalQuantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['shopName'] = this.shopName;
    data['productName'] = this.productName;
    data['pieces'] = this.pieces;
    data['totalQuantity'] = this.totalQuantity;
    return data;
  }

}