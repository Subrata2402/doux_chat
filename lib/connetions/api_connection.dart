import 'package:doux_chat/services/helper.dart';

String apiUrl = "$baseUrl/api";

class PostApiConnection {
  String register = "$apiUrl/auth/register";
  String login = "$apiUrl/auth/login";
  String verifyEmail = "$apiUrl/auth/verify-email";
  String addChatUser = "$apiUrl/chat/add-chat-user";
  String addChatMessage = "$apiUrl/chat/add-chat-message";
  String getChatMessages = "$apiUrl/chat/get-chat-messages";
}

class GetApiConnection{
  String getChatList = "$apiUrl/chat/get-chat-list";
}