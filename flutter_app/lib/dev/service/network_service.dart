import 'dart:io';

class NetworkService {
  static Future<String> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback && _isPrivateIp(address.address)) {
            return address.address;
          }
        }
      }

      return 'Unavailable';
    } catch (_) {
      return 'Unavailable';
    }
  }

  static bool _isPrivateIp(String ip) {
    final parts = ip.split('.');

    if (parts.length != 4) {
      return false;
    }

    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);

    if (first == null || second == null) {
      return false;
    }

    return first == 10 ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168);
  }
}