class CurrencyFormatter {
  static String format(double amount) {
    String value = amount.round().toString();
    RegExp reg = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }
}
