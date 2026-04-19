import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/empty_state_view.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  static const routePath = AppRoutes.chat;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _messageController;
  bool _isSendingMessage = false;
  String? _selectedThreadId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final threadsAsync = ref.watch(chatThreadsProvider);
    final blockedChatThreadsCount =
        ref.watch(blockedChatThreadsCountProvider).valueOrNull ?? 0;
    final primaryThreadId = ref.watch(primaryChatThreadIdProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final resolvedThreads = threadsAsync.valueOrNull;
    final resolvedSelectedThreadId = resolvedThreads != null &&
            resolvedThreads.any((thread) => thread.id == _selectedThreadId)
        ? _selectedThreadId
        : primaryThreadId;
    final composerThread =
        resolvedSelectedThreadId == null || resolvedThreads == null
            ? null
            : resolvedThreads.firstWhere(
                (thread) => thread.id == resolvedSelectedThreadId,
              );
    final canSendMessage =
        (composerThread?.hasParticipant(currentUserId) ?? false) &&
            !_isSendingMessage;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: threadsAsync.when(
        data: (threads) {
          final effectiveThreadId = threads.any(
            (thread) => thread.id == _selectedThreadId,
          )
              ? _selectedThreadId
              : threads.isEmpty
                  ? null
                  : threads.first.id;
          final selectedThread = effectiveThreadId == null
              ? null
              : threads.firstWhere((thread) => thread.id == effectiveThreadId);

          if (threads.isEmpty) {
            return EmptyStateView(
              title: blockedChatThreadsCount > 0
                  ? l10n.chatBlockedThreadsEmptyTitle
                  : l10n.chatEmptyTitle,
              message: blockedChatThreadsCount > 0
                  ? l10n.chatBlockedThreadsEmptyMessage
                  : l10n.chatEmptyMessage,
              action: RouteActionButton(
                label: l10n.openExploreAction,
                route: AppRoutes.explore,
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: selectedThread == null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.chatSelectedThreadTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.chatSelectedThreadEmpty,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.chatSelectedThreadTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.chatSelectedThreadSubtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (threads.length > 1) ...[
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: threads
                                    .map(
                                      (thread) => ChoiceChip(
                                        selected:
                                            thread.id == selectedThread.id,
                                        onSelected: (_) {
                                          setState(() {
                                            _selectedThreadId = thread.id;
                                          });
                                        },
                                        label: Text(
                                          l10n.chatThreadChipLabel(
                                            thread.activityId,
                                            thread.participantsCount,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              l10n.chatActivityLabel(selectedThread.activityId),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(selectedThread.lastMessagePreview),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.chatParticipantsCount(
                                selectedThread.participantsCount,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ThreadCard(
                thread: selectedThread!,
                isPrimary: true,
                isSendingMessage: _isSendingMessage,
                currentUserId: currentUserId,
                draftController: _messageController,
                onSendMessage: (message) => _sendMessage(
                  threadId: selectedThread.id,
                  senderUserId: currentUserId,
                  message: message,
                ),
              ),
            ],
          );
        },
        loading: () => const AsyncLoadingView(),
        error: (error, stackTrace) => AsyncErrorView(message: error.toString()),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _messageController,
              enabled: canSendMessage,
              maxLength: ChatMessage.maxTextLength,
              onSubmitted: (value) async {
                await _sendMessage(
                  threadId: resolvedSelectedThreadId,
                  senderUserId: currentUserId,
                  message: value,
                );
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: canSendMessage
                    ? l10n.chatComposerHint
                    : l10n.chatSelectedThreadEmpty,
                suffixIcon: _isSendingMessage
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: !canSendMessage
                            ? null
                            : () async {
                                await _sendMessage(
                                  threadId: resolvedSelectedThreadId,
                                  senderUserId: currentUserId,
                                  message: _messageController.text,
                                );
                              },
                        icon: const Icon(Icons.send_outlined),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage({
    required String? threadId,
    required String? senderUserId,
    required String message,
  }) async {
    final draft = ChatMessage(
      id: 'draft',
      threadId: threadId ?? '',
      senderUserId: senderUserId ?? '',
      text: message,
      sentAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    if (!draft.hasText || threadId == null || senderUserId == null) {
      return;
    }
    if (_isSendingMessage) {
      return;
    }
    final trimmed = draft.normalizedText;
    setState(() {
      _isSendingMessage = true;
    });
    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            threadId: threadId,
            senderUserId: senderUserId,
            message: trimmed,
          );
      await ref.read(analyticsServiceProvider).logEvent(
        name: AnalyticsEvents.chatMessageSent,
        parameters: {
          'thread_id': threadId,
        },
      );
      _messageController.clear();
    } catch (_) {
      if (mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).chatMessageSendFailedToast,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }
}

class _ThreadCard extends ConsumerWidget {
  const _ThreadCard({
    required this.thread,
    required this.isPrimary,
    required this.isSendingMessage,
    required this.currentUserId,
    required this.onSendMessage,
    this.draftController,
  });

  final ChatThread thread;
  final bool isPrimary;
  final bool isSendingMessage;
  final String? currentUserId;
  final TextEditingController? draftController;
  final Future<void> Function(String message) onSendMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final safetyBannerEnabled = ref.watch(safetyBannerEnabledProvider);
    final messagesAsync = ref.watch(chatMessagesProvider(thread.id));
    final quickReplies = [
      l10n.quickReplyOnMyWay,
      l10n.quickReplyRunningLate,
      l10n.quickReplyShareArea,
      l10n.quickReplyConfirmTime,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thread.shouldShowSafetyBanner(safetyBannerEnabled)) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(l10n.chatSafetyBanner),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              l10n.chatActivityLabel(thread.activityId),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(thread.lastMessagePreview),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.chatHistoryTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Text(
                    l10n.chatHistoryEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                final recentMessages = messages.length <= 4
                    ? messages
                    : messages.sublist(messages.length - 4);
                return Column(
                  children: recentMessages
                      .map(
                        (message) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _MessageBubble(
                            message: message,
                            isOwnMessage: message.senderUserId == currentUserId,
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
              loading: () => const AsyncLoadingView(),
              error: (error, stackTrace) =>
                  AsyncErrorView(message: error.toString()),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.chatQuickRepliesTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.chatQuickRepliesHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: quickReplies
                  .map(
                    (reply) => ActionChip(
                      label: Text(reply),
                      onPressed: isSendingMessage
                          ? null
                          : () async {
                              if (draftController != null) {
                                draftController!.text = reply;
                              }
                              await onSendMessage(reply);
                            },
                    ),
                  )
                  .toList(growable: false),
            ),
            if (isPrimary) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.chatComposerHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isOwnMessage,
  });

  final ChatMessage message;
  final bool isOwnMessage;

  @override
  Widget build(BuildContext context) {
    final alignment =
        isOwnMessage ? Alignment.centerRight : Alignment.centerLeft;
    final backgroundColor = isOwnMessage
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message.text),
      ),
    );
  }
}
