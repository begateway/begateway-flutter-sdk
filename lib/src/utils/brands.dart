
class CardBrand {
  final String name;
  final RegExp pattern;

  CardBrand(this.name, this.pattern);
}

final List<CardBrand> cardBrands = [
  CardBrand('VISA', RegExp(r'^4')),
  CardBrand('MASTER_CARD', RegExp(r'^(5[1-5]|2[3-6]|22[2-9]|222[1-9]|27[1-2])')),
  CardBrand('AMEX', RegExp(r'^3[47]')),
  CardBrand('DISCOVER', RegExp(r'^(30[0-5]|3095|3[689]|6011[0234789]|65|64[4-9])')),
  CardBrand('JCB', RegExp(r'^(35|1800|2131)')),
  CardBrand('DINERS', RegExp(r'^(30[0-5]|36|38)')),
  CardBrand('MAESTRO', RegExp(r'^(500|50[2-9]|501[0-8]|5[6-9]|60[2-5]|6010|601[2-9]|6060|616788|62709601|6218[368]|6219[89]|622110|6220|627[1-9]|627089|628[0-1]|6294|6301|630490|633857|63609|6361|636392|636708|637043|637102|637118|637187|637529|639|64[0-3]|67[0123457]|676[0-9]|679|6771)')),
  CardBrand('UNION_PAY', RegExp(r'^(620|621[0234567]|621977|62212[6-9]|6221[3-8]|6222[0-9]|622[3-9]|62[3-6]|6270[2467]|628[2-4]|629[1-2]|632062|685800|69075)')),
  CardBrand('DANKORT', RegExp(r'^5019')),
  CardBrand('BEL_CARD', RegExp(r'^9112')),
  CardBrand('MIR', RegExp(r'^220[0-4]')),
  CardBrand('PROSTIR', RegExp(r'^9804')),
  CardBrand('SOLO', RegExp(r'^(6334|6767)')),
  CardBrand('SWITCH', RegExp(r'^(633110|633312|633304|633303|633301|633300)')),
  CardBrand('HIPERCARD', RegExp(r'^(384|606282|637095|637568|637599|637609|637612)')),
  CardBrand('ELO', RegExp(r'^(401178|401179|431274|438935|451416|457393|457631|457632|504175|506699|5067[0-7]|5090[0-8]|636297|636368|650[04579]|651652|6550[0-4])')),
  CardBrand('RU_PAY', RegExp(r'(606[1-9]|607|608|81|82|508)')),
];

bool isValidLuhn(String cardNumber) {
  int sum = 0;
  bool alternate = false;
  
  // Remove spaces from the card number
  cardNumber = cardNumber.replaceAll(' ', '');
  for (int i = cardNumber.length - 1; i >= 0; i--) {
    int n = int.parse(cardNumber[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) {
        n -= 9;
      }
    }
    sum += n;
    alternate = !alternate;
  }
  
  return sum % 10 == 0;
}


CardBrand findCardBrand(String cardNumber) {
  cardNumber = cardNumber.replaceAll(' ', '');
  if (isValidLuhn(cardNumber)) {
  for (var brand in cardBrands) {
    if (brand.pattern.hasMatch(cardNumber)) {
      return brand;
    }
  }}
  return CardBrand('', RegExp(''));
}
