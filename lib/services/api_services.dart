import 'dart:convert';

import 'package:doux_chat/connetions/api_connection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response =
          await http.post(Uri.parse(PostApiConnection().register), body: data);
      return jsonDecode(response.body);
    } catch (error) {
      debugPrint('Error: $error');
      return {};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse(PostApiConnection().verifyEmail), body: data);
      return jsonDecode(response.body);
    } catch (error) {
      debugPrint('Error: $error');
      return {};
    }
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    try {
      final response =
          await http.post(Uri.parse(PostApiConnection().login), body: data);
      return jsonDecode(response.body);
    } catch (error) {
      debugPrint('Error: $error');
      return {};
    }
  }
}

class ChatServices {
  Future<Map<String, dynamic>> addChatUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    try {
      final response = await http.post(
          Uri.parse(PostApiConnection().addChatUser),
          body: data,
          headers: {
            'Authorization': 'Bearer $accessToken',
          });
      return jsonDecode(response.body);
    } catch (error) {
      debugPrint('Error: $error');
      return {};
    }
  }

  Future<Map<String, dynamic>> addChatMessage(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    try {
      final response = await http.post(
          Uri.parse(PostApiConnection().addChatMessage),
          body: data,
          headers: {
            'Authorization': 'Bearer $accessToken',
          });
      return jsonDecode(response.body);
    } catch (error) {
      debugPrint('Error: $error');
      return {};
    }
  }

  Future<Map<String, dynamic>> getChatMessages(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    try {
      final response = await http.post(
          Uri.parse(PostApiConnection().getChatMessages),
          body: data,
          headers: {
            'Authorization': 'Bearer $accessToken',
          });
      return jsonDecode(response.body);
    } catch (error) {
      debugPrint('Error: $error');
      return {};
    }
  }

  Future<Map<String, dynamic>> getChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    try {
      final response = await http.get(
          Uri.parse(GetApiConnection().getChatList),
          headers: {
            'Authorization': 'Bearer $accessToken',
          });
      return jsonDecode(response.body);
    } catch (error) {
      debugPrint('Error: $error');
      return {};
    }
  }
}