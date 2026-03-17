class StockItem {

  int itemid=0,pieces=0;
  num quantity=0.0;

  StockItem(this.itemid, this.pieces, this.quantity);

  Map toJson() => {
    'itemId': itemid,
    'itemPieces': pieces,
    'itemQuantity': quantity,
  };

}