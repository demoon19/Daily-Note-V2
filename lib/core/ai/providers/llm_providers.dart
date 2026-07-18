import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../llm_client.dart';
import '../on_device_llm_client.dart';
import '../cloud_llm_client.dart';
import '../intent_parser_service.dart';
import '../../network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  // TODO: ganti baseUrl dengan URL Edge Function/proxy production.
  return ApiClient(baseUrl: 'https://your-edge-function.example.workers.dev');
});

final onDeviceLlmClientProvider = Provider<OnDeviceLlmClient>((ref) {
  return OnDeviceLlmClient();
});

final cloudLlmClientProvider = Provider<CloudLlmClient>((ref) {
  return CloudLlmClient(apiClient: ref.watch(apiClientProvider));
});

final intentParserServiceProvider = Provider<IntentParserService>((ref) {
  return IntentParserService(
    onDeviceClient: ref.watch(onDeviceLlmClientProvider),
    cloudClient: ref.watch(cloudLlmClientProvider),
  );
});