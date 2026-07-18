import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../email_router.dart';
import 'email_providers.dart';
import '../../ai/providers/intent_router_provider.dart';

final emailRouterProvider = Provider<EmailRouter>((ref) {
  return EmailRouter(
    parser: ref.watch(emailToScheduleParserProvider),
    intentRouter: ref.watch(intentRouterProvider),
  );
});