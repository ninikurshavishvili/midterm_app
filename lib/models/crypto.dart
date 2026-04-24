class Crypto {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double changePercent24h;
  final double marketCap;
  final double volume24h;
  final int colorValue;

  const Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.changePercent24h,
    required this.marketCap,
    required this.volume24h,
    required this.colorValue,
  });

  bool get isPositive => changePercent24h >= 0;
}
