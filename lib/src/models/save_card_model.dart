class SaveCardModel {
  String? brand;
  String? lastFourNumbers;
  String? saveToken;

  SaveCardModel({
    required this.brand,
    required this.lastFourNumbers,
    required this.saveToken,
  });

  SaveCardModel.fromJson(Map<String, dynamic> json)
      : brand = json['brand'],
        lastFourNumbers = json['lastFourNumbers'],
        saveToken = json['saveToken'];

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'lastFourNumbers': lastFourNumbers,
        'saveToken': saveToken,
      };
}