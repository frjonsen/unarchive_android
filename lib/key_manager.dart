import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class KeyManager {
  static const KEY_STORAGE_KEY = "SSH_KEY";
  Future<bool> _verifyBiometrics() async {
    var localAuth = new LocalAuthentication();
    return await localAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate yourself');
  }

  Future<void> addKey(String sshKey) async {
    var authenticated = await _verifyBiometrics();
    if (!authenticated) return;

    final storage = new FlutterSecureStorage();
    await storage.write(key: KEY_STORAGE_KEY, value: sshKey);
  }

  Future<String> getKey() async {
    var authenticated = await _verifyBiometrics();
    if (!authenticated) return null;
    final storage = new FlutterSecureStorage();
    var key = await storage.read(key: KEY_STORAGE_KEY);
    print(key);
    return key;
  }
}
