import '../services/api/api_payload_utils.dart';

enum AppConnectionStatus { connected, disconnected, pending }

class AppConnection {
  const AppConnection({
    required this.provider,
    required this.status,
    this.externalUserId,
    this.connectedAt,
    this.lastSyncedAt,
  });

  final String provider;
  final AppConnectionStatus status;
  final String? externalUserId;
  final DateTime? connectedAt;
  final DateTime? lastSyncedAt;

  bool get isConnected => status == AppConnectionStatus.connected;
  bool get isPending => status == AppConnectionStatus.pending;

  factory AppConnection.fromApi(Map<String, dynamic> map) {
    return AppConnection(
      provider:
          (firstString(map, const ['provider']) ?? '').trim().toLowerCase(),
      status: _parseStatus(
        firstString(map, const ['connection_status', 'status']) ??
            'disconnected',
      ),
      externalUserId: firstString(map, const [
        'external_user_id',
        'externalUserId',
      ]),
      connectedAt: firstDateTime(map, const ['connected_at', 'connectedAt']),
      lastSyncedAt: firstDateTime(map, const [
        'last_synced_at',
        'lastSyncedAt',
      ]),
    );
  }

  static AppConnectionStatus _parseStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'connected':
        return AppConnectionStatus.connected;
      case 'pending':
        return AppConnectionStatus.pending;
      default:
        return AppConnectionStatus.disconnected;
    }
  }
}
