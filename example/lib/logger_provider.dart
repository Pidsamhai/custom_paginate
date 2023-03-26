import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoggerProvider extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('''
[RIVERPOD][${provider.hashCode}]
{
  "provider": "${provider.name}",
  "newValue": "$newValue"
}''');
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    print("[RIVERPOD][${provider.hashCode}] Create ${provider.name}");
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    print("[RIVERPOD][${provider.hashCode}] Diapose ${provider.name}");
  }
}
