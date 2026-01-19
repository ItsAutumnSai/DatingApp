import 'dart:async';
import 'package:flutter/material.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:datingapp/data/service/httpservice.dart';

class ChatPage extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final String? partnerPhoto;

  const ChatPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partnerPhoto,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Poll every 5 seconds for new messages
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadMessages(refresh: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool refresh = false}) async {
    if (!refresh) {
      setState(() => _isLoading = true);
    }
    try {
      final myId = UserSession().userId;
      if (myId == null) return;

      final messages = await _authRepository.getChatHistory(
        myId,
        widget.partnerId,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        if (!refresh) _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Error loading messages: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Small delay to ensure list is built
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  Future<void> _sendBondRequest() async {
    // Send a special message
    await _sendMessage(customText: "BOND_REQUEST");
  }

  Future<void> _acceptBond() async {
    try {
      final myId = UserSession().userId;
      if (myId == null) return;

      await _authRepository.confirmBond(myId, widget.partnerId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are now Bonded! \u2764\ufe0f")),
      );
      // Maybe navigate to a success page or refresh
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to bond: $e")));
    }
  }

  Future<void> _sendMessage({String? customText}) async {
    final text = customText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (customText == null) _messageController.clear();

    try {
      final myId = UserSession().userId;
      if (myId == null) return;

      await _authRepository.sendMessage(myId, widget.partnerId, text);
      _loadMessages(refresh: true);
      _scrollToBottom();
    } catch (e) {
      debugPrint("Error sending message: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if eligible for Seal the Deal (e.g. 5+ messages)
    // And I am the one viewing (logic: just show if > 5 messages)
    bool canSealTheDeal = _messages.length >= 5;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.partnerPhoto != null
                  ? NetworkImage(widget.partnerPhoto!)
                  : null,
              child: widget.partnerPhoto == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.partnerName,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          if (canSealTheDeal)
            IconButton(
              icon: const Icon(Icons.volunteer_activism, color: Colors.pink),
              tooltip: "Seal the Deal?",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Seal the Deal? \uD83D\uDC8D"),
                    content: const Text(
                      "Ready to make it official? This will send a bond request.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _sendBondRequest();
                        },
                        child: const Text("Send Request"),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text("Say Hi!"))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['userid1'] == UserSession().userId;
                      final messageText = msg['message'] ?? '';
                      final isBondRequest = messageText == "BOND_REQUEST";

                      if (isBondRequest) {
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
                              border: Border.all(color: Colors.pink),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isMe
                                      ? "You sent a Bond Request!"
                                      : "${widget.partnerName} wants to Bond!",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!isMe)
                                  ElevatedButton(
                                    onPressed: _acceptBond,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                      "Accept Bond \u2764\ufe0f",
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.redAccent : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            messageText,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
