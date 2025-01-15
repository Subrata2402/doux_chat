import 'dart:convert';

import 'package:doux_chat/screens/chat_screen.dart';
import 'package:doux_chat/services/api_services.dart';
import 'package:doux_chat/services/helper.dart';
import 'package:doux_chat/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController usernameController = TextEditingController();
  dynamic chatList = [];
  bool isLoading = false;
  String? userId;

  void dropDownMenu(BuildContext context) {
    showMenu(
      elevation: 5,
      context: context,
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 200,
      ),
      position: const RelativeRect.fromLTRB(10, 100, 0, 0),
      items: [
        PopupMenuItem(
            onTap: () {},
            child: const Row(
              children: [
                Icon(Icons.settings),
                SizedBox(width: 10),
                Text('Settings'),
              ],
            )),
        PopupMenuItem(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Row(
              children: [
                Icon(Icons.logout),
                SizedBox(width: 10),
                Text('Logout'),
              ],
            )),
      ],
    );
  }

  Future<void> addUser() async {
    final response = await ChatServices().addChatUser({
      "userName": usernameController.text,
    });
    if (!mounted) return;
    Navigator.pop(context);
    usernameController.clear();
    if (response['success']) {
      customSnackBar(context, response['message'], 'success');
      setState(() {
        fetchChatList();
      });
    } else {
      customSnackBar(context, response['message'], 'error');
    }
  }

  void openModalBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: Container(
            height: 235,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add a User to start chat',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter username',
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          addUser();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text('Add User',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchChatList({bool loading = true}) async {
    if (loading) {
      setState(() {
        isLoading = true;
      });
    }
    final response = await ChatServices().getChatList();
    if (!mounted) return;
    if (response['success']) {
      setState(() {
        chatList.clear();
        // debugPrint(response['data'].toString());
        chatList = response['data'];
      });
    } else {
      customSnackBar(context, response['message'], 'error');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null) {
      final user = jsonDecode(userData);
      userId = user['_id'];
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchChatList();
    // Join chat room using socket service
    SocketService().joinRoom();

    // Listen for incoming messages
    SocketService().listen('private-message', (data) {
      debugPrint('Message received: $data');
      fetchChatList(loading: false);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    SocketService().leaveRoom();
    usernameController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused) {
      debugPrint("App is in the background or minimized");
      SocketService().socketEmit('offline', userId);
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("App is in the foreground");
      SocketService().socketEmit('online', userId);
    } else if (state == AppLifecycleState.inactive) {
      debugPrint("App is inactive (e.g., during a phone call)");
      SocketService().socketEmit('offline', userId);
    } else if (state == AppLifecycleState.detached) {
      print("App is detached from the view (not attached to UI anymore)");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) => didPop ? true : false,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            margin: MediaQuery.of(context).padding,
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                const Text('Doux Chat',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    dropDownMenu(context);
                  },
                  icon: const Icon(Icons.more_vert),
                  color: Colors.white,
                ),
              ],
            ),
          ),
          backgroundColor: Colors.deepPurple,
          // elevation: 5,
          shadowColor: Colors.deepPurple,
          scrolledUnderElevation: 20,
          automaticallyImplyLeading: false,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  fetchChatList();
                },
                backgroundColor: Colors.deepPurple,
                color: Colors.white,
                strokeWidth: 3,
                child: _buildChatList()),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            openModalBottomSheet();
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add_comment_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    if (chatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You didn't have any chat yet",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45)),
            const SizedBox(height: 10),
            const Text('Click on the button below to start a chat',
                style: TextStyle(fontSize: 16, color: Colors.black45)),
            IconButton(
                onPressed: () {
                  openModalBottomSheet();
                },
                icon: const Icon(Icons.add_circle_outline,
                    size: 50, color: Colors.deepPurple)),
          ],
        ),
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(
        color: Colors.black12,
        height: 1,
      ),
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(user: chatList[index]))).then((_) {
              fetchChatList(loading: false);
            });
          },
          child: ListTile(
            leading: const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/user_icon.png'),
            ),
            title: Text(
                chatList[index]['firstName'] +
                    ' ' +
                    chatList[index]['lastName'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                // const Icon(Icons.done_all, color: Colors.blue, size: 20),
                // const SizedBox(width: 5),
                Expanded(
                  child: Text(
                      chatList[index]['message'] == null
                          ? 'No messages yet'
                          : chatList[index]['message']['message'],
                      style: const TextStyle(color: Colors.black45),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                chatList[index]['message'] != null
                    ? Text(getIstTime(chatList[index]['message']['createdAt']),
                        style: TextStyle(
                            fontSize: 12,
                            color: chatList[index]['unread'] > 0
                                ? Colors.green
                                : Colors.black45))
                    : const SizedBox(),
                chatList[index]['unread'] > 0
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.green,
                        child: Text(chatList[index]['unread'].toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}
