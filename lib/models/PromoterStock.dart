class SalesItem {

  int itemid=0,quantity=0;
  String itemName="";

  SalesItem(this.itemid, this.itemName, this.quantity);

  Map toJson() => {
    'itemId': itemid,
    'itemPieces': itemName,
    'itemQuantity': quantity,
  };

}