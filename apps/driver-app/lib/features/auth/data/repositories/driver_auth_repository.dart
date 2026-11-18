abstract class DriverAuthRepository {
  Future<bool> isRegisteredDriver(String digitsOnlyPhone);
  Future<bool> sendVerificationCode(String digitsOnlyPhone);
  Future<int> getRemainingLockoutSeconds(String digitsOnlyPhone);
}

class MockDriverAuthRepository implements DriverAuthRepository {
  @override
  Future<bool> isRegisteredDriver(String digitsOnlyPhone) async {
    // Simulate quick network check: 4035559876 simulates an unregistered driver
    if (digitsOnlyPhone.endsWith('5559876') || digitsOnlyPhone.endsWith('9876')) {
      return false;
    }
    return true;
  }

  @override
  Future<bool> sendVerificationCode(String digitsOnlyPhone) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }

  @override
  Future<int> getRemainingLockoutSeconds(String digitsOnlyPhone) async {
    // 0 = not locked
    return 0;
  }
}
