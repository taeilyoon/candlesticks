/// Candle model wich holds a single candle data.
/// It contains five required double variables that hold a single candle data: high, low, open, close and volume.
/// It can be instantiated using its default constructor or fromJson named custructor.
class Candle {
  /// DateTime for the candle
  final DateTime endDate;
  final DateTime startDate;

  /// The highest price during this candle lifetime
  /// It if always more than low, open and close
  final double high;

  /// The lowest price during this candle lifetime
  /// It if always less than high, open and close
  final double low;

  /// Price at the beginning of the period
  final double open;

  /// Price at the end of the period
  final double close;

  /// Volume is the number of shares of a
  /// security traded during a given period of time.
  final double volume;

  bool get isBull => open <= close;

  bool isContain(DateTime time) {
    if (time.isBefore(endDate) && !time.isBefore(startDate)) {
      return true;
    } else {
      return false;
    }
  }

  Candle({
    required this.endDate,
    required this.startDate,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
    required this.volume,
  });

  Candle.fromJson(List<dynamic> json)
      : endDate = DateTime.fromMillisecondsSinceEpoch(json[0]),
        startDate = DateTime.fromMillisecondsSinceEpoch(json[0])
            .subtract(Duration(hours: 1)),
        high = double.parse(json[2]),
        low = double.parse(json[3]),
        open = double.parse(json[1]),
        close = double.parse(json[4]),
        volume = double.parse(json[5]);
}
