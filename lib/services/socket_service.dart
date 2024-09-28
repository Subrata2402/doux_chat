import 'dart:convert';

import 'package:doux_chat/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  late io.Socket _socket;

  SocketService._internal() {
    // Initialize the socket connection
    // _socket = io.io('http://192.168.0.100:3250', <String, dynamic>{
    _socket = io.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  io.Socket get socket => _socket;

  void connect() {
    if (!_socket.connected) {
      _socket.connect();
      _socket.onConnect((_) {
        debugPrint('Connected to socket server');
      });
    }
  }

  void disconnect() async {
    if (_socket.connected) {
      _socket.disconnect();
      _socket.onDisconnect((_) {
        debugPrint('Disconnected from socket server');
      });
    }
  }

  void socketEmit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void listen(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  void joinRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('userData')!);
    _socket.emit('join-chat', userData['_id'].toString());
  }

  void leaveRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('userData')!);
    _socket.emit('leave-chat', userData['_id'].toString());
  }
}