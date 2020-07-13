class Result {
  final String classification;

  Result({this.classification});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      classification: json['result'],
    );
  }
}