import 'dart:async';
import 'package:flutter/material.dart';
import '../services/message_service.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatScreen extends StatefulWidget {
  final int friendId;
  final String friendName;
  final String friendHandle;
  final String friendAvatar;
  final String friendBackground;
  final bool isPremium;

  const ChatScreen({
    Key? key,
    required this.friendId,
    required this.friendName,
    required this.friendHandle,
    required this.friendAvatar,
    required this.friendBackground,
    this.isPremium = false,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> messages = [];
  bool loading = true;
  int? myUserId;
  Timer? _pollingTimer;

  String safeAsset(String? path) {
    return (path == null || path.isEmpty) ? 'assets/background/black.jpg' : path;
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _fetchNewMessages());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      loading = true;
    });
    try {
      final data = await _messageService.getConversation(widget.friendId);
      setState(() {
        messages = data['messages'] ?? [];
        myUserId = int.tryParse(data['myUserId'].toString());
        loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      setState(() {
        messages = [];
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('chat_error_load_failed'.tr()))
      );
    }
  }

  Future<void> _fetchNewMessages() async {
    try {
      final data = await _messageService.getConversation(widget.friendId);
      final fetchedMessages = data['messages'] ?? [];
      if (fetchedMessages.isEmpty) return;
      for (final serverMsg in fetchedMessages) {
        messages.removeWhere(
              (msg) =>
          msg['id'] == null &&
              msg['sender_id'] == serverMsg['sender_id'] &&
              msg['content'] == serverMsg['content'],
        );
      }
      final existingIds =
      messages.where((m) => m['id'] != null).map((m) => m['id']).toSet();
      final trulyNewMessages = fetchedMessages
          .where(
            (serverMsg) =>
        serverMsg['id'] != null &&
            !existingIds.contains(serverMsg['id']),
      )
          .toList();
      if (trulyNewMessages.isNotEmpty) {
        setState(() {
          messages.addAll(trulyNewMessages);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty || myUserId == null) return;
    try {
      final myLastMsg = messages.lastWhere(
            (msg) =>
        (msg['sender_id'] is int
            ? msg['sender_id']
            : int.tryParse(msg['sender_id'].toString())) == myUserId,
        orElse: () => null,
      );
      final myAvatar = myLastMsg != null ? safeAsset(myLastMsg['sender_avatar']) : 'assets/background/black.jpg';
      final myBackground = myLastMsg != null
          ? safeAsset(myLastMsg['sender_background'])
          : 'assets/background/black.jpg';
      final newMessage = {
        'id': null,
        'sender_id': myUserId,
        'content': content,
        'sender_avatar': myAvatar,
        'sender_background': myBackground,
      };
      setState(() {
        messages.add(newMessage);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      _controller.clear();
      await _messageService.sendMessage(widget.friendId, content);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('chat_error_send_failed'.tr())),
      );
    }
  }

  Widget _profileCircle({
    required String background,
    required String avatar,
    double size = 64,
    double avatarRadius = 28,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(safeAsset(background)),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: CircleAvatar(
          backgroundImage: AssetImage(safeAsset(avatar)),
          radius: avatarRadius,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              color: colorScheme.primary,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: colorScheme.onPrimary, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 6),
                  _profileCircle(
                    background: safeAsset(widget.friendBackground),
                    avatar: safeAsset(widget.friendAvatar),
                    size: 64,
                    avatarRadius: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.friendName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          widget.friendHandle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 10),
                itemCount: messages.length,
                itemBuilder: (context, idx) {
                  final m = messages[idx];
                  final senderId = m['sender_id'] is int
                      ? m['sender_id']
                      : int.tryParse(m['sender_id'].toString());
                  final isSelf =
                      myUserId != null && senderId == myUserId;
                  final avatarPath = safeAsset(m['sender_avatar']);
                  final backgroundPath = safeAsset(m['sender_background']);
                  return Align(
                    alignment: isSelf
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isSelf
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isSelf)
                          _profileCircle(
                            background: backgroundPath,
                            avatar: avatarPath,
                            size: 40,
                            avatarRadius: 17,
                          ),
                        if (!isSelf) const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 10,
                              bottom: 2,
                              left: isSelf ? 48 : 0,
                              right: isSelf ? 0 : 48,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelf
                                  ? colorScheme.secondary.withOpacity(0.19)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: Radius.circular(isSelf ? 14 : 2),
                                bottomRight:
                                Radius.circular(isSelf ? 2 : 14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              m['content'] ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        if (isSelf) const SizedBox(width: 8),
                        if (isSelf)
                          _profileCircle(
                            background: backgroundPath,
                            avatar: avatarPath,
                            size: 40,
                            avatarRadius: 17,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.only(left: 16),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'chat_input_hint'.tr(),
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.send, color: colorScheme.onSecondary, size: 22),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}