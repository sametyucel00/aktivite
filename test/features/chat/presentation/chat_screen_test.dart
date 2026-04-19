import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/chat/presentation/chat_screen.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers/fakes.dart';
import '../../../test_helpers/test_harness.dart';

void main() {
  testWidgets(
    'lets the user switch selected threads and keeps typed draft on send failure',
    (tester) async {
      final chatRepository = FakeChatRepository(
        threads: const [
          ChatThread(
            id: 'thread-1',
            activityId: 'coffee-plan',
            participantIds: [SampleIds.currentUser, SampleIds.guestOne],
            lastMessagePreview: 'Coffee preview',
            safetyBannerVisible: true,
          ),
          ChatThread(
            id: 'thread-2',
            activityId: 'walk-plan',
            participantIds: [SampleIds.currentUser, SampleIds.guestTwo],
            lastMessagePreview: 'Walk preview',
            safetyBannerVisible: true,
          ),
        ],
        messagesByThreadId: {
          'thread-1': [
            ChatMessage(
              id: 'm1',
              threadId: 'thread-1',
              senderUserId: SampleIds.currentUser,
              text: 'Coffee preview',
              sentAt: DateTime(2026, 4, 19, 12),
            ),
          ],
          'thread-2': [
            ChatMessage(
              id: 'm2',
              threadId: 'thread-2',
              senderUserId: SampleIds.currentUser,
              text: 'Walk preview',
              sentAt: DateTime(2026, 4, 19, 13),
            ),
          ],
        },
        throwOnSend: true,
      );

      await pumpTestApp(
        tester,
        child: const ChatScreen(),
        overrides: [
          chatRepositoryProvider.overrideWithValue(chatRepository),
          chatThreadsProvider.overrideWith(
            (ref) => AsyncValue.data(chatRepository.threads),
          ),
          chatMessagesProvider.overrideWith(
            (ref, threadId) => Stream.value(
                chatRepository.messagesByThreadId[threadId] ?? const []),
          ),
          blockedChatThreadsCountProvider.overrideWith(
            (ref) => const AsyncValue.data(0),
          ),
          analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        ],
      );

      expect(find.text('Selected thread'), findsOneWidget);
      expect(find.text('Coffee preview'), findsWidgets);

      await tester.tap(find.textContaining('walk-plan'));
      await tester.pumpAndSettle();

      expect(find.text('Walk preview'), findsWidgets);

      await tester.enterText(find.byType(TextField), 'On my way');
      await tester.tap(find.byIcon(Icons.send_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Message could not be sent right now.'), findsOneWidget);
      expect(find.text('On my way'), findsOneWidget);
      expect(chatRepository.lastThreadId, 'thread-2');
      expect(chatRepository.lastMessage, 'On my way');
    },
  );

  testWidgets(
    'explains blocked chat visibility in empty state',
    (tester) async {
      await pumpTestApp(
        tester,
        child: const ChatScreen(),
        overrides: [
          chatThreadsProvider.overrideWith(
            (ref) => const AsyncValue.data(<ChatThread>[]),
          ),
          blockedChatThreadsCountProvider.overrideWith(
            (ref) => const AsyncValue.data(1),
          ),
        ],
      );

      expect(find.text('Blocked chats stay hidden'), findsOneWidget);
      expect(
        find.text(
          'Chats connected to blocked users stay hidden from your coordination space.',
        ),
        findsOneWidget,
      );
    },
  );
}
