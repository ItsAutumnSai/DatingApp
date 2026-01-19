import 'dart:async';
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    try {
      final myId = UserSession().userId;
      if (myId == null) return;

      await _authRepository.sendMessage(myId, widget.partnerId, text);
      _loadMessages(refresh: true); // Reload immediately
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
                            msg['message'] ?? '',
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
