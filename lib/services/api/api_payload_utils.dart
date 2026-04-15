import 'dart:convert';

Map<String, dynamic>? asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      return asMap(decoded);
    } catch (_) {
      return null;
    }
  }
  return null;
}

List<Map<String, dynamic>> asMapList(dynamic value) {
  if (value is List) {
    return value.map(asMap).whereType<Map<String, dynamic>>().toList(growable: false);
  }
  return const [];
}

Map<String, dynamic>? firstNestedMap(dynamic source, List<String> keys) {
  for (final key in keys) {
    final found = deepFind(source, key);
    final map = asMap(found);
    if (map != null) return map;
  }
  return null;
}

List<Map<String, dynamic>> firstNestedList(dynamic source, List<String> keys) {
  for (final key in keys) {
    final found = deepFind(source, key);
    final list = asMapList(found);
    if (list.isNotEmpty) return list;
  }
  return const [];
}

dynamic deepFind(dynamic source, String key) {
  if (source is Map) {
    for (final entry in source.entries) {
      if (entry.key.toString() == key) {
        return entry.value;
      }
      final nested = deepFind(entry.value, key);
      if (nested != null) return nested;
    }
  } else if (source is List) {
    for (final item in source) {
      final nested = deepFind(item, key);
      if (nested != null) return nested;
    }
  }
  return null;
}

String? firstString(dynamic source, List<String> keys) {
  for (final key in keys) {
    final found = deepFind(source, key);
    if (found == null) continue;
    if (found is String && found.trim().isNotEmpty) return found.trim();
    if (found is num || found is bool) return found.toString();
  }
  return null;
}

int? firstInt(dynamic source, List<String> keys) {
  for (final key in keys) {
    final found = deepFind(source, key);
    if (found is int) return found;
    if (found is num) return found.toInt();
    if (found is String) {
      final parsed = int.tryParse(found.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

bool? firstBool(dynamic source, List<String> keys) {
  for (final key in keys) {
    final found = deepFind(source, key);
    if (found is bool) return found;
    if (found is num) return found != 0;
    if (found is String) {
      final normalized = found.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') return true;
      if (normalized == 'false' || normalized == '0' || normalized == 'no') return false;
    }
  }
  return null;
}

DateTime? firstDateTime(dynamic source, List<String> keys) {
  for (final key in keys) {
    final found = deepFind(source, key);
    if (found is DateTime) return found;
    if (found is String && found.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(found.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

String? extractToken(Map<String, dynamic> payload) {
  return firstString(payload, const [
    'token',
    'access_token',
    'jwt',
    'auth_token',
    'session_token',
    'bearer_token',
  ]);
}

int? extractPointsBalance(Map<String, dynamic> payload) {
  return firstInt(payload, const [
    'available_points',
    'points_balance',
    'balance',
    'current_points',
    'points',
    'total_points',
  ]);
}
