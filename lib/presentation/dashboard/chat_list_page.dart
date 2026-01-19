import 'package:flutter/material.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:datingapp/data/service/httpservice.dart';
import 'package:datingapp/presentation/dashboard/chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = UserSession().userId;
      if (userId == null) throw Exception("User not logged in");

      final chats = await _authRepository.getChatList(userId);
      setState(() {
        _chats = chats;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "PairMe",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: $_errorMessage"),
                  ElevatedButton(
                    onPressed: _loadChats,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : _chats.isEmpty
          ? const Center(child: Text("No chats yet"))
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final user = _chats[index];
                final photoUrl = user['photos']?['photo1'] != null
                    ? '${HttpService().baseUrl}/uploads/${user['photos']['photo1']}'
                    : null;

                // Parse last message time
                String timeStr = "";
                if (user['last_message_time'] != null) {
                  try {
                    final dt = DateTime.parse(user['last_message_time']);
                    final now = DateTime.now();
                    if (now.difference(dt).inDays > 0) {
                      timeStr = "${now.difference(dt).inDays}d";
                    } else {
                      timeStr =
                          "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                    }
                  } catch (_) {}
                }

                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(
                    user['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user['last_message'] ?? 'No messages',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    timeStr,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              partnerId: user['id'],
                              partnerName: user['name'] ?? 'Unknown',
                              partnerPhoto: photoUrl,
                            ),
                          ),
                        )
                        .then((_) => _loadChats());
                  },
                );
              },
            ),
    );
  }
}
