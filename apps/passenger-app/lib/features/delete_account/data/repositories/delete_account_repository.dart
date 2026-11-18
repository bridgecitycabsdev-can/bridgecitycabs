import '../../../../data/datasources/profile_remote_datasource.dart';
import '../models/delete_account_model.dart';

abstract class DeleteAccountRepository {
  Future<bool> requestDeletionOtp(String phone);
  Future<bool> validateOtp(String code);
  Future<DeletionRequestResult> submitAccountDeletion({
    required LeavingReason reason,
    String? feedback,
    required String otp,
  });
  Future<bool> restoreAccount();
}

class MockDeleteAccountRepository implements DeleteAccountRepository {
  final Duration delay;

  MockDeleteAccountRepository({this.delay = const Duration(milliseconds: 60)});

  @override
  Future<bool> requestDeletionOtp(String phone) async {
    await Future.delayed(delay);
    return true;
  }

  @override
  Future<bool> validateOtp(String code) async {
    await Future.delayed(delay);
    return code == '482000' || code.length == 6;
  }

  @override
  Future<DeletionRequestResult> submitAccountDeletion({
    required LeavingReason reason,
    String? feedback,
    required String otp,
  }) async {
    await Future.delayed(delay);
    return const DeletionRequestResult();
  }

  @override
  Future<bool> restoreAccount() async {
    await Future.delayed(delay);
    return true;
  }
}

class ApiDeleteAccountRepository implements DeleteAccountRepository {
  ApiDeleteAccountRepository(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<bool> requestDeletionOtp(String phone) async {
    await _remote.requestDeletionCode();
    return true;
  }

  @override
  Future<bool> validateOtp(String code) async {
    return code.trim().length >= 4;
  }

  @override
  Future<DeletionRequestResult> submitAccountDeletion({
    required LeavingReason reason,
    String? feedback,
    required String otp,
  }) async {
    await _remote.deleteAccount(
      reason: reason.label,
      feedback: feedback,
      otp: otp,
    );
    return const DeletionRequestResult();
  }

  @override
  Future<bool> restoreAccount() async {
    return false;
  }
}
