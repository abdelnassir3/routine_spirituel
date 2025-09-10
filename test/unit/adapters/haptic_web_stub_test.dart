import 'package:flutter_test/flutter_test.dart';
import '../../stubs/web_haptic_stub.dart';

void main() {
  group('WebHapticStub', () {
    test('isSupported is false and calls do not throw', () async {
      final stub = WebHapticStub();

      expect(stub.isSupported, isFalse);

      // Les méthodes doivent être des no‑ops sans lancer d'exception
      await expectLater(stub.lightImpact(), completes);
      await expectLater(stub.mediumImpact(), completes);
      await expectLater(stub.heavyImpact(), completes);
      await expectLater(stub.selectionClick(), completes);
      await expectLater(stub.customVibration(50), completes);
    });
  });
}
