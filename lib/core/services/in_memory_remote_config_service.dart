import 'package:aktivite/core/config/remote_config_keys.dart';
import 'package:aktivite/core/services/remote_config_service.dart';

class InMemoryRemoteConfigService implements RemoteConfigService {
  static const _values = RemoteConfigDefaults.values;

  @override
  bool getBool(String key) {
    return (_values[key] as bool?) ?? false;
  }

  @override
  String getString(String key) {
    return _values[key]?.toString() ?? '';
  }
}
