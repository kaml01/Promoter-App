class SalesItem {

  int itemid=0,pieces=0,clo_stock=0,ope_stock=0,sample=0;
  num quantity=0.0;

  // SalesItem(this.itemid,this.ope_stock,this.clo_stock,this.sample,this.pieces,this.quantity);

  SalesItem(this.itemid,this.sample,this.pieces,this.quantity);

  Map toJson() => {
    'itemId': itemid,
    // 'openingStock':ope_stock,
    // 'closingStock':clo_stock,
    'sampleStock': sample,
    'itemPieces': pieces,
    'itemQuantity': quantity,
  };

}