import 'dart:async';
import 'dart:convert';

import 'package:amazetalk_flutter/constants/urls.dart';
import 'package:amazetalk_flutter/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:amazetalk_flutter/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../blocs/chats_bloc/chats_bloc.dart';

const String URL = BACKEND_URL; // Replace with your server URL

class ChatScreen extends StatefulWidget {
  final String userId;
  final String roomId;
  final String chatName;
  final bool isGroupChat;
  const ChatScreen(
      {Key? key,
      required this.userId,
      required this.roomId,
      required this.chatName,
      required this.isGroupChat})
      : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  IO.Socket? socket;
  List<dynamic> messages = [];
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool otherUserTyping = false;
  bool showEmojiPicker = false;
  bool loading = false;
  bool sendingMsg = false;
  bool showAlert = false;
  Timer? typingTimer; // Timer to manage stop typing event
  bool isTyping = false; // Tracks whether we are currently in "typing" state

  @override
  void initState() {
    super.initState();
    connectSocket();
    fetchMessages();
  }

  void connectSocket() {
    String userId = widget.userId;
    String chatId = widget.roomId;
    // Create and connect the socket
    socket = IO.io(BACKEND_URL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket?.connect();

    socket?.on('connect', (_) {
      debugPrint('Connected to socket server');
      // Setup the socket with the user ID
      socket?.emit('setup', userId);
    });

    socket?.on('connected', (_) {
      debugPrint('Socket setup complete');
      // Join a specific chat room
      socket?.emit('join chat', chatId);
    });

    // Listen for new messages
    socket?.on('message received', (data) {
      debugPrint('Message received: $data');
      setState(() {
        messages.add(data);
      });
      scrollDown();
    });

    // Listen for typing events from others
    socket?.on('typing', (room) {
      if (room == chatId) {
        setState(() {
          otherUserTyping = true;
        });
      }
    });

    socket?.on('stop typing', (room) {
      if (room == chatId) {
        setState(() {
          otherUserTyping = false;
        });
      }
    });

    // Optionally handle user online/offline events
    socket?.on('user online', (uid) {
      debugPrint('User online: $uid');
    });

    socket?.on('user offline', (uid) {
      debugPrint('User offline: $uid');
    });

    socket?.on('disconnect', (_) {
      debugPrint('Disconnected from socket server');
    });
  }

  // Fetch messages from an API endpoint (simulate with your own API)
  void fetchMessages() async {
    String chatId = widget.roomId;
    final localAuthToken = await AuthLocalDataSource().getToken();
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$URL/message/$chatId'),
        headers: {
          'Authorization': 'Bearer $localAuthToken',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          messages = data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
    setState(() {
      loading = false;
    });
    scrollDown();
  }

  // Send a message using an API call then emit a socket event
  void sendMessage() async {
    final localAuthToken = await AuthLocalDataSource().getToken();
    String chatId = widget.roomId;
    if (_messageController.text.trim().isEmpty) return;
    // Cancel any pending stop typing event as we are sending the message
    _stopTyping();
    setState(() {
      sendingMsg = true;
      showAlert = false;
    });
    final messageContent = _messageController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('$URL/message/'),
        headers: {
          'Authorization': 'Bearer $localAuthToken',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'content': messageContent,
          'chatId': chatId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Emit the new message via socket
        socket?.emit('new message', data);
        setState(() {
          messages.add(data);
        });
        _messageController.clear();
        scrollDown();
      } else {
        setState(() {
          showAlert = true;
        });
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      setState(() {
        showAlert = true;
      });
    }
    setState(() {
      sendingMsg = false;
    });
  }

  // Called on every text change to manage typing status using a timer.
  void onTyping(String text) {
    String chatId = widget.roomId;
    if (text.isNotEmpty && !isTyping) {
      isTyping = true;
      socket?.emit('typing', chatId);
    }
    // Cancel any existing timer and start a new one.
    typingTimer?.cancel();
    typingTimer = Timer(const Duration(seconds: 2), () {
      _stopTyping();
    });
  }

  void _stopTyping() {
    if (isTyping) {
      isTyping = false;
      socket?.emit('stop typing', widget.roomId);
    }
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Toggle emoji picker visibility and hide the keyboard.
  void toggleEmojiPicker() {
    FocusScope.of(context).unfocus();
    setState(() {
      showEmojiPicker = !showEmojiPicker;
    });
  }

  // Append selected emoji to the text input.
  void addEmoji(String emoji) {
    setState(() {
      _messageController.text += emoji;
    });
  }

  // Show group information in a modal dialog.
  void showGroupInfo() {
    // call bloc to fetch Group Info
    BlocProvider.of<ChatsBloc>(context).add(GroupInfo(widget.roomId));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Group Info'),
          content: BlocBuilder<ChatsBloc, ChatsState>(
            builder: (context, state) {
              if (state is GroupInfoFetched) {
                final info = state.info;
                return SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: info.userMappings.length,
                    itemBuilder: (context, index) {
                      final user = info.userMappings[index];
                      final userImage = user.userImage;
                      final username = user.username;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: userImage != null
                              ? NetworkImage(userImage)
                              : null,
                          child: userImage == null
                              ? Text(username[0].toUpperCase())
                              : null,
                        ),
                        title: Text(user.getDisplayName(state.uid)),
                        subtitle: user.isAdmin ? const Text('Admin') : null,
                      );
                    },
                  ),
                );
              }

              return Loader();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // This callback is triggered when the AppBar back button is tapped.
          onPressed: () {
            BlocProvider.of<ChatsBloc>(context).add(FetchChats());
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.chatName),
        actions: widget.isGroupChat
            ? [
                // Show group info button (if applicable)
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: showGroupInfo,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isSelf = message['sender']['_id'] == userId;
                        return Align(
                          alignment: isSelf
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelf ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message['content'] ?? '',
                              style: TextStyle(
                                color: isSelf ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Typing indicator from others
          if (otherUserTyping)
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text('Someone is typing...'),
            ),
          // Show an error alert if needed
          if (showAlert)
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Error sending message. Check your network connection.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          // Input area: emoji toggle, text input, and send button
          Row(
            children: [
              IconButton(
                icon: Icon(showEmojiPicker
                    ? Icons.clear
                    : Icons.emoji_emotions_outlined),
                onPressed: toggleEmojiPicker,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onChanged: (text) {
                    onTyping(text);
                  },
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (text) {
                    sendMessage();
                    _stopTyping();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
          // Emoji picker
          if (showEmojiPicker)
            SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    addEmoji(emoji.emoji);
                  },
                  onBackspacePressed: () {
                    // Do something when the user taps the backspace button (optional)
                    // Set it to null to hide the Backspace-Button
                  },
                  textEditingController:
                      _messageController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                  config: Config(
                    height: 256,

                    // bgColor: const Color(0xFFF2F2F2),
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      // Issue: https://github.com/flutter/flutter/issues/28894
                      emojiSizeMax: 28 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.20
                              : 1.0),
                    ),
                    viewOrderConfig: const ViewOrderConfig(
                      top: EmojiPickerItem.categoryBar,
                      middle: EmojiPickerItem.emojiView,
                      bottom: EmojiPickerItem.searchBar,
                    ),
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(),
                    bottomActionBarConfig: const BottomActionBarConfig(),
                    searchViewConfig: const SearchViewConfig(),
                  ),
                )

                // EmojiPicker(
                //   onEmojiSelected: (category, emoji) {
                //     addEmoji(emoji.emoji);
                //   },
                //   // Optionally, you can remove the textEditingController here if needed:
                //   // textEditingController: _messageController,
                // ),
                ),
        ],
      ),
    );
  }
}
