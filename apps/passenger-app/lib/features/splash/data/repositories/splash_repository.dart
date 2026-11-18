import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../models/connection_status.dart';
import '../models/splash_config.dart';

abstract class SplashRepository {
  /// Checks network connectivity and tests reachability to backend services.
  Future<ConnectionStatus> checkFleetDispatchConnectivity();

  /// Launches the device phone dialer to call urgent dispatch.
  Future<bool> callUrgentCabHotline();

  /// Checks if user already has an active session token stored locally.
  Future<bool> hasStoredSession();
}

class SplashRepositoryImpl implements SplashRepository {
  final Future<bool> Function()? _customSessionCheck;

  SplashRepositoryImpl({Future<bool> Function()? customSessionCheck})
      : _customSessionCheck = customSessionCheck;

  @override
  Future<ConnectionStatus> checkFleetDispatchConnectivity() async {
    // In production, pings the API health endpoint or checks socket ping.
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      return const ConnectionStatus(
        quality: NetworkQuality.normal,
        isFleetDispatchReachable: true,
      );
    } catch (e) {
      return ConnectionStatus(
        quality: NetworkQuality.offline,
        isFleetDispatchReachable: false,
        detailMessage: e.toString(),
      );
    }
  }

  @override
  Future<bool> callUrgentCabHotline() async {
    final uri = Uri.parse(SplashConfig.urgentCabPhoneDialUrl);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  @override
  Future<bool> hasStoredSession() async {
    if (_customSessionCheck != null) {
      return _customSessionCheck!();
    }
    return false;
  }
}
