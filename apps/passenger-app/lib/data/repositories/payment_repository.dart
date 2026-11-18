import '../../features/booking/saved_card.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepository {
  PaymentRepository(this._remote);

  final PaymentRemoteDataSource _remote;

  Future<List<SavedCard>> list() async {
    return SavedCard.parseList(await _remote.list());
  }

  Future<String> publishableKey() async {
    final data = await _remote.config();
    final key = data is Map ? data['publishableKey'] : null;
    if (key is! String || !key.startsWith('pk_')) {
      throw StateError('Card payments are not configured');
    }
    return key;
  }

  Future<String> setupIntentSecret() async {
    final data = await _remote.createSetupIntent();
    final secret = data is Map ? data['clientSecret'] : null;
    if (secret is! String || secret.isEmpty) {
      throw StateError('Could not start card setup');
    }
    return secret;
  }

  Future<void> setDefault(String id) => _remote.setDefault(id);

  Future<void> remove(String id) => _remote.remove(id);
}
