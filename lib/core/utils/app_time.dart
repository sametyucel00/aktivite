abstract final class AppClock {
  static DateTime now() => DateTime.now();
}

abstract final class AppIdFactory {
  static String timestampId({required String prefix, DateTime? now}) {
    final value = now ?? AppClock.now();
    return '$prefix-${value.millisecondsSinceEpoch}';
  }

  static String sequenceId({
    required String prefix,
    required int nextNumber,
  }) {
    return '$prefix-$nextNumber';
  }

  static String timestampValue({DateTime? now}) {
    final value = now ?? AppClock.now();
    return value.millisecondsSinceEpoch.toString();
  }
}
