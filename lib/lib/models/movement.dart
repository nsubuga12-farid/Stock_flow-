/// One stock change, e.g. "+12 Coca-Cola". Shown in "Recent Activity"
/// on the dashboard and counted in "Today Moves".
class Movement {
  final String productName;
  final int delta; // positive = stock added, negative = stock removed
  final DateTime time;

  const Movement({
    required this.productName,
    required this.delta,
    required this.time,
  });

  /// Text such as "+12 added" or "3 removed".
  String get description => delta > 0 ? '+$delta added' : '${delta.abs()} removed';

  /// Friendly time such as "2 min", "1 hr", "3 d".
  String get ago {
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    if (d.inHours < 24) return '${d.inHours} hr';
    return '${d.inDays} d';
  }

  bool get isToday {
    final n = DateTime.now();
    return time.year == n.year && time.month == n.month && time.day == n.day;
  }

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'delta': delta,
        'time': time.millisecondsSinceEpoch,
      };

  factory Movement.fromJson(Map<String, dynamic> j) => Movement(
        productName: j['productName'] as String,
        delta: j['delta'] as int,
        time: DateTime.fromMillisecondsSinceEpoch(j['time'] as int),
      );
}
