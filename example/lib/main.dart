import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import './candle_ticker_model.dart';
import './repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

enum DrawingState {
  none,
  lineLow,
  lineHigh,
  lineFree,
  lineFreeInfinite,
  horizonLine,
  circle,
  square,
  squareInfinite,
}

class _MyAppState extends State<MyApp> {
  BinanceRepository repository = BinanceRepository();

  List<Candle> candles = [];
  WebSocketChannel? _channel;
  bool themeIsDark = false;
  String currentInterval = "1h";
  final intervals = [
    '1m',
    '3m',
    '5m',
    '15m',
    '30m',
    '1h',
    '2h',
    '4h',
    '6h',
    '8h',
    '12h',
    '1d',
    '3d',
    '1w',
    '1M',
  ];
  List<String> symbols = [];
  String currentSymbol = "";

  bool isDrawing = false;

  Set<CandlePosition> selectedDrawing = {};
  CandlePosition? nowPosition;

  List<Indicator> indicators = [
    InfurenceIndicator(
      label: "Influence",
      shortPeriod: 9,
      midPeriod: 26,
    ),
  ];
  List<SubIndicator> subIndicators = [
    // VolumeIndicatorIndicator(color: Colors.black),
    ADXIndicator(color: Colors.black),
    OBVIndicator(color: Colors.black),
    MACDIndicator(),
    // CommodityChannㅌelIndexIndicator(color: Colors.white)
  ];

  @override
  void initState() {
    fetchSymbols().then((value) {
      symbols = value;
      if (symbols.isNotEmpty) fetchCandles("BTCUSDT", currentInterval);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_channel != null) _channel!.sink.close();
    super.dispose();
  }

  Future<List<String>> fetchSymbols() async {
    try {
      // load candles info
      final data = await repository.fetchSymbols();
      return data;
    } catch (e) {
      // handle error
      return [];
    }
  }

  Future<void> fetchCandles(String symbol, String interval) async {
    // close current channel if exists
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    // clear last candle list
    setState(() {
      candles = [];
      currentInterval = interval;
    });

    try {
      // load candles info
      final data =
          await repository.fetchCandles(symbol: symbol, interval: interval);
      // connect to binance stream
      _channel =
          repository.establishConnection(symbol.toLowerCase(), currentInterval);
      // update candles
      setState(() {
        candles = data;
        currentInterval = interval;
        currentSymbol = symbol;
      });
    } catch (e) {
      // handle error
      return;
    }
  }

  void updateCandlesFromSnapshot(AsyncSnapshot<Object?> snapshot) {
    if (candles.isEmpty) return;
    if (snapshot.data != null) {
      final map = jsonDecode(snapshot.data as String) as Map<String, dynamic>;
      if (map.containsKey("k") == true) {
        final candleTicker = CandleTickerModel.fromJson(map);

        // cehck if incoming candle is an update on current last candle, or a new one
        if (candles[0].endDate == candleTicker.candle.endDate &&
            candles[0].open == candleTicker.candle.open) {
          // update last candle
          candles[0] = candleTicker.candle;
        }
        // check if incoming new candle is next candle so the difrence
        // between times must be the same as last existing 2 candles
        else if (candleTicker.candle.endDate.difference(candles[0].endDate) ==
            candles[0].endDate.difference(candles[1].endDate)) {
          // add new candle to list
          candles.insert(0, candleTicker.candle);
        }
      }
    }
  }

  Future<void> loadMoreCandles() async {
    try {
      // load candles info
      final data = await repository.fetchCandles(
          symbol: currentSymbol,
          interval: currentInterval,
          endTime: candles.last.endDate.millisecondsSinceEpoch);
      candles.removeLast();
      setState(() {
        candles.addAll(data);
      });
    } catch (e) {
      // handle error
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeIsDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Binance Candles"),
          actions: [
            // IconButton(
            //   onPressed: () {
            //     setState(() {
            //       themeIsDark = !themeIsDark;
            //     });
            //   },
            //   icon: Icon(
            //     themeIsDark
            //         ? Icons.wb_sunny_sharp
            //         : Icons.nightlight_round_outlined,
            //   ),
            // ),
            // IconButton(
            //   onPressed: () {
            //     setState(() {
            //       this.isDrawing = !this.isDrawing;
            //       selectedDrawing.removeWhere((element) => true);
            //     });
            //   },
            //   icon: Icon(Icons.add),
            //   color: this.isDrawing ? Colors.black : Colors.white,
            // ),
            IconButton(
              onPressed: () {
                // setState(() {
                //   this.indicators.add(
                //       MovingAverageIndicator(length: 10, color: Colors.black, name: '10'));
                // });
              },
              icon: Icon(Icons.draw_rounded),
              color: this.isDrawing ? Colors.black : Colors.white,
            )
          ],
        ),
        body: StreamBuilder(
          stream: _channel == null ? null : _channel!.stream,
          builder: (context, snapshot) {
            updateCandlesFromSnapshot(snapshot);
            return Candlesticks(
              candleWidth: 2.0,
              chartAdjust: ChartAdjust.fullRange,
              // isDrawingMode: this.isDrawing,
              // subIndicator: this.subIndicators,
              key: Key(currentSymbol + currentInterval),
              // indicators: indicators,
              candles: candles,
              onLoadMoreCandles: loadMoreCandles,
              onRemoveIndicator: (String indicator) {
                setState(() {
                  indicators = [
                    ...indicators,
                  ];
                  indicators
                      .removeWhere((element) => element.name == indicator);
                });
              },
              drawing: [
                [
                  LineDrawing(
                      startX: candles[50].startDate,
                      endX: candles[0].endDate,
                      startY: candles[50].low,
                      endY: candles[0].low,
                      width: 5,
                      color: Colors.black,
                      style: LineStyle.dotted,
                      range: LineRange.endOpen),
                  LineDrawing(
                      startX: candles[30].startDate,
                      endX: candles[20].endDate,
                      startY: candles[30].low,
                      endY: candles[20].low,
                      width: 3,
                      color: Colors.black,
                      style: LineStyle.dashed,
                      range: LineRange.close),
                  MarkerDrawing(
                      X: candles[32].startDate,
                      Y: candles[30].low,
                      color: Colors.greenAccent,
                      size: 10,
                      name: "name",
                      shape: MarkerType.square),
                  MarkerDrawing(
                      X: candles[50].startDate,
                      Y: candles[30].low,
                      color: Colors.greenAccent,
                      size: 4,
                      name: "name",
                      shape: MarkerType.diamond),
                  MarkerDrawing(
                      X: candles[34].startDate,
                      Y: candles[30].low,
                      color: Colors.greenAccent,
                      size: 10,
                      name: "name",
                      shape: MarkerType.circle),
                  MarkerDrawing(
                      X: candles[70].startDate,
                      Y: candles[30].low - 2000,
                      color: Colors.greenAccent,
                      size: 10,
                      name: "name",
                      shape: MarkerType.circle),
                  TextDrawing(
                      text: "text",
                      X: candles[70].startDate,
                      Y: candles[30].low - 2000,
                      anchor: TextAnchor.bottom),
                  // TextDrawing(
                  //   text: "text",
                  //   X: candles[25].startDate,
                  //   Y: (candles[50].low + candles[0].low) / 2 - 300,
                  //   textType: TextDrawingType.bubble,
                  // ),
                  TextDrawing(
                      text: "text",
                      X: candles[25].startDate,
                      Y: (candles[50].low + candles[0].low) / 2,
                      textType: TextDrawingType.bubbleArrow,
                      anchor: TextAnchor.bottom),
                  // TextDrawing(
                  //     text: "tㅆt",
                  //     X: candles[25].startDate,
                  //     Y: (candles[50].low + candles[0].low) / 2,
                  //     textType: TextDrawingType.normal,
                  //     anchor: TextAnchor.bottom)
                ],
                [],
                []
              ],
              onChartPanStart: (p) {
                print(p);
                setState(() {
                  selectedDrawing.add(p);
                });
              },
              onChartPanUpadte: (p) {
                nowPosition = p;
              },
              actions: [
                ToolBarAction(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Center(
                          child: Container(
                            width: 200,
                            color: Theme.of(context).backgroundColor,
                            child: Wrap(
                              children: intervals
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 50,
                                          height: 30,
                                          child: RawMaterialButton(
                                            elevation: 0,
                                            fillColor: const Color(0xFF494537),
                                            onPressed: () {
                                              fetchCandles(currentSymbol, e);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                color: Color(0xFFF0B90A),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    currentInterval,
                  ),
                ),
                ToolBarAction(
                  width: 100,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SymbolsSearchModal(
                          symbols: symbols,
                          onSelect: (value) {
                            fetchCandles(value, currentInterval);
                          },
                        );
                      },
                    );
                  },
                  child: Text(
                    currentSymbol,
                  ),
                )
              ],
              indicatorUpdated: (i, n) {
                setState(() {
                  this.indicators.removeWhere((element) => true);
                });
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    this.indicators.addAll(n);
                  });
                });
              },
              onSubIndicatorSettingPressed: (int index) {},
            );
          },
        ),
      ),
    );
  }
}

class SymbolsSearchModal extends StatefulWidget {
  const SymbolsSearchModal({
    Key? key,
    required this.onSelect,
    required this.symbols,
  }) : super(key: key);

  final Function(String symbol) onSelect;
  final List<String> symbols;

  @override
  State<SymbolsSearchModal> createState() => _SymbolSearchModalState();
}

class _SymbolSearchModalState extends State<SymbolsSearchModal> {
  String symbolSearch = "";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          height: MediaQuery.of(context).size.height * 0.75,
          color: Theme.of(context).backgroundColor.withOpacity(0.5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                  onChanged: (value) {
                    setState(() {
                      symbolSearch = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  children: widget.symbols
                      .where((element) => element
                          .toLowerCase()
                          .contains(symbolSearch.toLowerCase()))
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 50,
                              height: 30,
                              child: RawMaterialButton(
                                elevation: 0,
                                fillColor: const Color(0xFF494537),
                                onPressed: () {
                                  widget.onSelect(e);
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Color(0xFFF0B90A),
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({Key? key, required this.onChanged}) : super(key: key);
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      cursorColor: const Color(0xFF494537),
      decoration: const InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: Color(0xFF494537),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
        border: OutlineInputBorder(
          borderSide:
              BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
      ),
      onChanged: onChanged,
    );
  }
}
