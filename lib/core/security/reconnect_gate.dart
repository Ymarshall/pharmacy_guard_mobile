import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/routes/app_routes.dart';
import '../constants/app_colors.dart';

/// Propose de se reconnecter sans quitter l'écran en cours, puis rejoue l'appel.
class ReconnectGate {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Completer<bool>? _pending;

  /// Appelé quand l'utilisateur termine ou abandonne la reconnexion.
  void Function(bool success)? onResolved;

  bool get isWaiting => _pending != null && !_pending!.isCompleted;

  Future<bool> requestReconnect() {
    final current = _pending;
    if (current != null && !current.isCompleted) return current.future;

    final completer = Completer<bool>();
    _pending = completer;
    final context = navigatorKey.currentContext;
    if (context == null) {
      _resolve(false);
      return completer.future;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!completer.isCompleted) _presentDialog();
    });
    return completer.future;
  }

  void succeed() => _resolve(true);

  void cancel() => _resolve(false);

  void _resolve(bool success) {
    final pending = _pending;
    if (pending == null || pending.isCompleted) return;
    pending.complete(success);
    onResolved?.call(success);
  }

  void _presentDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      _resolve(false);
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Session expirée'),
          content: const Text(
            'Votre session a expiré. Reconnectez-vous pour terminer '
            'l\'action en cours. Cette page reste ouverte.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                cancel();
              },
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await navigatorKey.currentState?.pushNamed(AppRoutes.login);
                cancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Se reconnecter'),
            ),
          ],
        );
      },
    );
  }
}
