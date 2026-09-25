import 'ai_provider_config.dart';

class AIConversation {
  const AIConversation({
    required this.id,
    required this.providerId,
    required this.title,
    required this.createdAt,
  });

  final int id;
  final AIProviderId providerId;
  final String title;
  final DateTime createdAt;
}
