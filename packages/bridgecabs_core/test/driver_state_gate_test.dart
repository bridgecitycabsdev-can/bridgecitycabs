import 'package:bridgecabs_core/socket/driver_state_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ignores a lower version', () {
    final gate = DriverStateGate();
    expect(gate.acceptSocket(3), isTrue);
    expect(gate.acceptSocket(2), isFalse);
    expect(gate.lastApplied, 3);
  });

  test('ignores a socket snapshot that is not newer', () {
    final gate = DriverStateGate();
    expect(gate.acceptSocket(1), isTrue);
    expect(gate.acceptSocket(2), isTrue);
    expect(gate.acceptSocket(2), isFalse);
    expect(gate.acceptSocket(1), isFalse);
    expect(gate.lastApplied, 2);
  });

  test('a rest reload can replace the same version', () {
    final gate = DriverStateGate();
    expect(gate.acceptSocket(4), isTrue);
    expect(gate.acceptRest(4), isTrue);
    expect(gate.acceptRest(3), isFalse);
    expect(gate.lastApplied, 4);
  });
}
