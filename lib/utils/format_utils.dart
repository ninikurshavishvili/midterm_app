String formatPrice(double price) {
  if (price >= 1000) {
    final formatted = price.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '\$$formatted';
  } else if (price >= 1) {
    return '\$${price.toStringAsFixed(2)}';
  } else {
    return '\$${price.toStringAsFixed(4)}';
  }
}

String formatLargeNumber(double value) {
  if (value >= 1e12) {
    return '\$${(value / 1e12).toStringAsFixed(2)}T';
  } else if (value >= 1e9) {
    return '\$${(value / 1e9).toStringAsFixed(2)}B';
  } else if (value >= 1e6) {
    return '\$${(value / 1e6).toStringAsFixed(2)}M';
  }
  return '\$${value.toStringAsFixed(2)}';
}
