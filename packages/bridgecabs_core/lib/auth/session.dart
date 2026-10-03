import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../http/api_client.dart';
import '../phone/canada_phone.dart';
import 'secure_store.dart';
import 'token_store.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.resolve());

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore(FlutterSecureStore());
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    config: ref.watch(appConfigProvider),
    tokens: ref.watch(tokenStoreProvider),
  );
  ref.onDispose(client.close);
  return client;
});

final sessionProvider = AsyncNotifierProvider<SessionController, bool>(
  SessionController.new,
);

class SessionController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final tokens = ref.read(tokenStoreProvider);
    void signedOut() {
      state = const AsyncData(false);
    }

    tokens.addOnCleared(signedOut);
    ref.onDispose(() => tokens.removeOnCleared(signedOut));
    try {
      final access = await tokens.readAccess();
      return access != null && access.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<String> requestOtp(String rawPhone) async {
    final e164 = CanadaPhone.toE164(rawPhone);
    if (e164 == null) {
      throw const PhoneException('Enter a 10-digit Canadian number.');
    }
    await ref.read(apiClientProvider).requestOtp(e164);
    return e164;
  }

  Future<void> verifyOtp(String phone, String code) async {
    await ref.read(apiClientProvider).verifyOtp(phone: phone, code: code);
    state = const AsyncData(true);
  }

  Future<void> signOut() async {
    final tokens = ref.read(tokenStoreProvider);
    final refresh = await tokens.readRefresh();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await ref
            .read(apiClientProvider)
            .dio
            .post<dynamic>('/auth/logout', data: {'refreshToken': refresh});
      } on DioException {
        // Local sign-out still proceeds when the API is unreachable.
      }
    }
    await tokens.clear();
    state = const AsyncData(false);
  }

  /// Soft-revoke FCM then clear the session. Apps should prefer this over
  /// [signOut] when push is wired so DELETE /devices stays authorized.
  Future<void> signOutWithPushCleanup(
    Future<void> Function() unregisterPush,
  ) async {
    try {
      await unregisterPush();
    } catch (_) {
      // Push cleanup is best-effort.
    }
    await signOut();
  }
}
