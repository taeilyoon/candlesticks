


na(num? n){
  return n == null ? 0: n;
}


extension numListExt on List<num>{
  num exponentialMovingAverage(int len, {int index = 0}) {
    var alpha = 2 / (len + 1);
    var ema = this[len];
    for (var i = len; i >= index; i--) {
      ema = alpha * this[i] + (1 - alpha) * ema;
    }
    return ema;
  }
  ema(int len, {int index = 0}) {
    var alpha = 2 / (len +1);;
    // if(index == len)
    //   return 0;

    return this[index] * alpha + ema(len, index : index+1) * (1 - alpha);
  }

}


class Math {
  static double Max(double a, double b) {
    return a > b ? a : b;
  }

  static double Abs(double a) {
    return a > 0 ? a : -a;
  }
}


extension intExt on int {
  int get sigma => (2 * this + 1 / 2).floor();
}

extension ListNumExt<T extends num> on List<T> {
  T max() {
    if (length == 0) {
      return 0.0 as T;
    }
    return reduce((curr, next) => curr > next ? curr : next);
  }

  T min() {
    if (length == 0) {
      return 0.0 as T;
    }
    return reduce((curr, next) => curr < next ? curr : next);
  }

  // T ema() {
  //   return this.first;
  // }

  T sma() {
    return reduce((value, element) {
      return value + element as T;
    });
  }
}

extension ListExt<T> on List<T> {
  void addNotNull(T? value) {
    if (value == null) return;
    add(value);
  }

  T? get firstOrNull {
    if (length == 0)
      return null;
    else
      return first;
  }

  T? firstWhereOrNull(
      bool test(T element),
      ) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  T? getOrNull(int i) {
    if (length < i) {
      return null;
    } else {
      return this[i];
    }
  }
}

extension DateTimeExt on DateTime {
  isAfterOrSame() {}
}

num nz(num? number) {
  if (number?.isNaN != false) {
    return 0;
  }
  return number!;
}

var p = [706000.0
,697000.0
,718000.0
,726000.0
,729000.0
,718000.0
,727000.0
,725000.0
,720000.0
,701000.0
,680000.0
,694000.0
,701000.0
,700000.0
,722000.0
,718000.0
,759000.0
,747000.0
,725000.0
,738000.0
,730000.0
,740000.0
,733000.0
,739000.0
,725000.0
,760000.0
,737000.0
,727000.0
,727000.0
,677000.0
,655000.0
,650000.0
,627000.0
,589000.0
,606000.0
,605000.0
,605000.0
,603000.0
,596000.0
,610000.0
,600000.0
,591000.0
,585000.0
,569000.0
,556000.0
,546000.0
,566000.0
,564000.0
,587000.0
,597000.0
,610000.0
,629000.0
,619000.0
,634000.0
,608000.0
,602000.0
,615000.0
,614000.0
,602000.0
,571000.0
,554000.0
,560000.0
,566000.0
,576000.0
,575000.0
,598000.0
,578000.0
,576000.0
,586000.0
,587000.0
,591000.0
,587000.0
,600000.0
,618000.0
,624000.0
,629000.0
,632000.0
,623000.0
,619000.0
,612000.0
,615000.0
,597000.0
,598000.0
,589000.0
,586000.0
,572000.0
,583000.0
,569000.0
,578000.0
,556000.0
,563000.0
,558000.0
,568000.0
,567000.0
,559000.0
,545000.0
,546000.0
,548000.0
,541000.0
,528000.0];

void main(){
  print("dsadsa");
  var s = p.exponentialMovingAverage(3, index: 0);
  // 715200
  // 717550
  print(s);
}