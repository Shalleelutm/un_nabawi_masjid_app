import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService._();

  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();

      if (!canCheck && !supported) {
        return false;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Scan fingerprint to login',
        biometricOnly: true,
      );

      return authenticated;
    } catch (_) {
      return false;
    }
  }
}