import 'dart:async';
import 'dart:convert';

import 'package:doux_chat/services/api_services.dart';
import 'package:doux_chat/services/helper.dart';
import 'package:doux_chat/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  String timeString = '';
  bool isTyping = false;
  bool isOnline = false;
  Timer? _typingTimer;

  Future<void> fetchChatMessages() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('userData')!);
    final data = {
      'receiverId': widget.user['_id'].toString(),
    };
    final response = await ChatServices().getChatMessages(data);
    if (response['success']) {
      for (var message in response['data']) {
        if (mounted) {
          setState(() {
            _messages.add({
              'message': message['message'],
              'isOwn': message['senderId']['_id'] == userData['_id'],
              'timestamp': message['createdAt']
            });
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    _scrollToBottom();
  }

  double _borderRadius = 50; // Default border radius for single line
  // Function to adjust border radius based on text field content
  void _updateBorderRadius(String text) {
    int lineCount = '\n'.allMatches(text).length + 1; // Count new lines
    if (lineCount > 2) {
      setState(() {
        _borderRadius = 25; // Smaller border radius for multi-line input
      });
    } else if (lineCount > 1) {
      setState(() {
        _borderRadius = 33; // Smaller border radius for multi-line input
      });
    } else {
      setState(() {
        _borderRadius = 50; // Larger border radius for single line
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.isNotEmpty) {
      SocketService().socketEmit('private-message',
          {'message': message, 'receiverId': widget.user['_id'].toString()});
      if (mounted) {
        setState(() {
          _messages.add({
            'message': message,
            'isOwn': true,
            'timestamp':
                DateTime.now().subtract(const Duration(hours: 5, minutes: 30))
          });
        });
      }
      _scrollToBottom();
      await ChatServices().addChatMessage({
        'message': message,
        'receiverId': widget.user['_id'].toString(),
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _startTypingTimer() {
    _typingTimer?.cancel(); // Cancel any existing timer
    _typingTimer = Timer(const Duration(seconds: 2), () {
      SocketService().socketEmit(
          'stop-typing', {'receiverId': widget.user['_id'].toString()});
    });
  }

  Future<void> checkOnlineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('userData')!);
    final data = {
      'receiverId': widget.user['_id'].toString(),
      'userId': userData['_id'].toString()
    };
    SocketService().socketEmit('online', data);
  }

  @override
  void initState() {
    super.initState();
    fetchChatMessages();
    checkOnlineStatus();

    // Listen for online status
    SocketService().listen('online', (data) {
      debugPrint('Online status: ${data['isOnline']}');
      if (mounted) {
        setState(() {
          isOnline = data['isOnline'];
        });
      }
    });

    // SocketService().listen('read-message', (data) {
    //   debugPrint("Message read");
    // });

    // SocketService().socketEmit(
    //     'read-message', {'receiverId': widget.user['_id'].toString()});

    SocketService().listen('typing', (data) {
      if (mounted) {
        setState(() {
          isTyping = true;
        });
      }
    });

    SocketService().listen('stop-typing', (data) {
      if (mounted) {
        setState(() {
          isTyping = false;
        });
      }
    });

    // Listen for incoming messages
    SocketService().listen('private-message', (data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'message': data['message'],
            'isOwn': false,
            'timestamp':
                DateTime.now().subtract(const Duration(hours: 5, minutes: 30))
          });
        });
      }
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        // ),
        // leadingWidth: 40,
        // flexibleSpace:,
        flexibleSpace: Container(
          margin: MediaQuery.of(context).padding,
          // margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/user_icon.png'),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.user['firstName'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      // const SizedBox(height: 5),
                      Text(
                          isTyping
                              ? 'Typing...'
                              : isOnline
                                  ? 'Online'
                                  : '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isTyping || isOnline ? 12 : 0,
                              fontWeight: FontWeight.w300)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    color: Colors.white,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.deepPurple,
        shadowColor: Colors.deepPurple,
        elevation: 5,
        automaticallyImplyLeading: false,
      ),
      // This property allows the layout to adjust when the keyboard appears
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Chat messages area
          Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                    )
                  : _messages.isEmpty
                      ? const Center(
                          child: Text('No messages yet'),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            var message = _messages[index];
                            var isOwnMessage = message['isOwn'];
                            var previousMessageIsSameSender = index > 0 &&
                                _messages[index - 1]['isOwn'] == isOwnMessage;
                            String previousTime = index > 0
                                ? getIstTime(_messages[index - 1]['timestamp']
                                    .toString())
                                : '';
                            String previousDateOrDay = index > 0
                                ? getIstDateOrDay(_messages[index - 1]
                                        ['timestamp']
                                    .toString())
                                : '';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!previousMessageIsSameSender)
                                  const SizedBox(height: 10),
                                if (previousTime !=
                                    getIstTime(message['timestamp'].toString()))
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (previousMessageIsSameSender)
                                        const SizedBox(height: 10),
                                      if (previousDateOrDay !=
                                          getIstDateOrDay(
                                              message['timestamp'].toString()))
                                        Column(
                                          children: [
                                            timeContainer(
                                                getIstDateOrDay(
                                                    message['timestamp']
                                                        .toString()),
                                                isDate: true),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      timeContainer(getIstTime(
                                          message['timestamp'].toString())),
                                      const SizedBox(height: 10),
                                    ],
                                  ), // Add space if the sender changes
                                isOwnMessage
                                    ? messageContainer(
                                        message['message'],
                                        getIstTime(
                                            message['timestamp'].toString()),
                                        previousTime,
                                        true,
                                        isLast: previousMessageIsSameSender)
                                    : messageContainer(
                                        message['message'],
                                        getIstTime(
                                            message['timestamp'].toString()),
                                        previousTime,
                                        false,
                                        isOwn: false,
                                        isLast: previousMessageIsSameSender),
                              ],
                            );
                          },
                        )),
          // Input field and send button
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 4,
                    minLines: 1,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    controller: _messageController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      fillColor: Colors.deepPurple,
                      filled: true,
                      hintText: 'Type a message',
                      hintStyle: const TextStyle(color: Colors.white),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(_borderRadius)),
                      ),
                    ),
                    textInputAction: TextInputAction.newline,
                    onChanged: (text) {
                      _updateBorderRadius(text);
                      SocketService().socketEmit('typing',
                          {'receiverId': widget.user['_id'].toString()});
                      _startTypingTimer();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // Handle sending message
                    _sendMessage(_messageController.text);
                    _messageController.clear(); // Clear the text field
                    _typingTimer?.cancel(); // Cancel the typing timer
                    SocketService().socketEmit('stop-typing',
                        {'receiverId': widget.user['_id'].toString()});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget messageContainer(
      String message, String time, String previousTime, bool isRead,
      {bool isOwn = true, bool isLast = false}) {
    return Row(
      mainAxisAlignment:
          isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          margin: EdgeInsets.only(
              left: isOwn ? 50 : 10, right: isOwn ? 10 : 50, top: 2, bottom: 2),
          decoration: BoxDecoration(
            color: isOwn ? Colors.deepPurple : Colors.grey.shade400,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          constraints: const BoxConstraints(
            maxWidth: 300,
          ),
          child: Text(message,
              style: TextStyle(color: isOwn ? Colors.white : Colors.black)),
        ),
      ],
    );
  }

  Widget timeContainer(String time, {bool isDate = false}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDate ? Colors.grey : Colors.grey.shade200,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(
          time,
          style: TextStyle(
              color: isDate ? Colors.white : Colors.black, fontSize: 12),
        ),
      ),
    );
  }
}
