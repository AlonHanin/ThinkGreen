import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../models/app_connection.dart';
import '../../providers/activity_provider.dart';
import '../../providers/app_connections_provider.dart';
import '../../utils/app_feedback.dart';

class SyncAppsScreen extends StatelessWidget {
  const SyncAppsScreen({super.key});

  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  Future<void> _connectStrava(BuildContext context) async {
    final connectionsProvider = context.read<AppConnectionsProvider>();
    final error = await connectionsProvider.connectProvider('strava');

    if (!context.mounted) return;

    if (error != null) {
      showAppSnackBar(
        context,
        context.tr(error),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    await context.read<ActivityProvider>().refreshActivities();
    if (!context.mounted) return;

    showAppSnackBar(context, context.tr('Strava connected successfully.'));
  }

  Future<void> _syncStrava(BuildContext context) async {
    final connectionsProvider = context.read<AppConnectionsProvider>();
    final error = await connectionsProvider.syncProvider('strava');

    if (!context.mounted) return;

    if (error != null) {
      showAppSnackBar(
        context,
        context.tr(error),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    await context.read<ActivityProvider>().refreshActivities();
    if (!context.mounted) return;

    showAppSnackBar(context, context.tr('Strava sync completed.'));
  }

  Future<void> _disconnectStrava(BuildContext context) async {
    final connectionsProvider = context.read<AppConnectionsProvider>();
    final error = await connectionsProvider.disconnectProvider('strava');

    if (!context.mounted) return;

    if (error != null) {
      showAppSnackBar(
        context,
        context.tr(error),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    showAppSnackBar(context, context.tr('Strava disconnected.'));
  }

  String _statusLabel(BuildContext context, AppConnection connection) {
    switch (connection.status) {
      case AppConnectionStatus.connected:
        return context.tr('Connected');
      case AppConnectionStatus.pending:
        return context.tr('Pending');
      case AppConnectionStatus.disconnected:
        return context.tr('Not connected');
    }
  }

  String _dateLabel(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final connectionsProvider = context.watch<AppConnectionsProvider>();
    final stravaConnection = connectionsProvider.connectionFor('strava');

    return Scaffold(
      backgroundColor: lightGreenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('Sync Services'),
          style: GoogleFonts.outfit(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: connectionsProvider.refreshConnections,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            Text(
              context.tr('Automate Your\nPoints'),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: darkGreen,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.tr(
                'Connect your favorite apps to track eco-actions automatically.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGreen.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            _buildStravaCard(
              context,
              connection: stravaConnection,
              isBusy: connectionsProvider.isActing,
            ),
            const SizedBox(height: 20),
            _buildComingSoonCard(
              context,
              'MOOVIT',
              context.tr('Track Your Public Transport Trips'),
              Icons.directions_bus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStravaCard(
    BuildContext context, {
    required AppConnection connection,
    required bool isBusy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_run, color: darkGreen, size: 20),
              const SizedBox(width: 10),
              const Text(
                'STRAVA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      connection.isConnected
                          ? Colors.green.shade50
                          : darkGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(context, connection),
                  style: TextStyle(
                    color:
                        connection.isConnected
                            ? Colors.green.shade800
                            : darkGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('Track Runs, Walks And Bike Rides'),
            style: TextStyle(
              fontSize: 12,
              color: darkGreen.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            context,
            context.tr('Connected at'),
            _dateLabel(connection.connectedAt),
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            context,
            context.tr('Last synced'),
            _dateLabel(connection.lastSyncedAt),
          ),
          const SizedBox(height: 14),
          if (connection.isConnected)
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: context.tr('SYNC NOW'),
                    onPressed: isBusy ? null : () => _syncStrava(context),
                    filled: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    label: context.tr('DISCONNECT'),
                    onPressed: isBusy ? null : () => _disconnectStrava(context),
                    filled: false,
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _buildActionButton(
                label: context.tr('CONNECT'),
                onPressed: isBusy ? null : () => _connectStrava(context),
                filled: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: darkGreen, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: darkGreen.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _buildActionButton(
              label: context.tr('CONNECT'),
              onPressed: () => showComingSoonSnackBar(context, feature: title),
              filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: darkGreen.withValues(alpha: 0.72),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required bool filled,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: filled ? darkGreen : darkGreen.withValues(alpha: 0.1),
        foregroundColor: filled ? Colors.white : darkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : darkGreen,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
