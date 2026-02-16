extension NumberFormatExtensions on num {
  String toFormattedString() {
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}k';
    }
    return toStringAsFixed(0);
  }

  String toCalorieString() => '${toStringAsFixed(0)}kcal';

  double toProgressPercent() => toDouble().clamp(0.0, 1.0);
}
