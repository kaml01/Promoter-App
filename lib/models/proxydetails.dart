class proxydetails{

  String proxy;

  proxydetails({required this .proxy});

  factory proxydetails.fromJson(Map<String, dynamic> json) {
    return proxydetails(
        proxy: json['proxy']
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['proxy'] = proxy;
    return map;
  }

}