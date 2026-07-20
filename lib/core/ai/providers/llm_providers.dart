import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../on_device_llm_client.dart';
import '../groq_llm_client.dart';
import '../intent_parser_service.dart';

final onDeviceLlmClientProvider = Provider<OnDeviceLlmClient>((ref) {
  return OnDeviceLlmClient();
});

final groqLlmClientProvider = Provider<GroqLlmClient>((ref) {
  return GroqLlmClient();
});

final intentParserServiceProvider = Provider<IntentParserService>((ref) {
  return IntentParserService(
    onDeviceClient: ref.watch(onDeviceLlmClientProvider),
    cloudClient: ref.watch(groqLlmClientProvider),
  );
});