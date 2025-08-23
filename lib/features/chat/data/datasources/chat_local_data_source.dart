import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ChatLocalDataSource {
  Future<List<MessageModel>> getCachedMessages();
  Future<void> cacheMessages(List<MessageModel> messages);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  static const String cachedMessagesKey = 'CACHED_MESSAGES';
  final SharedPreferences sharedPreferences;

  ChatLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<MessageModel>> getCachedMessages() async {
    try {
      final jsonString = sharedPreferences.getString(cachedMessagesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => MessageModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException('خطا در بارگیری پیام‌های ذخیره شده');
    }
  }

  @override
  Future<void> cacheMessages(List<MessageModel> messages) async {
    try {
      final jsonString = json.encode(
        messages.map((message) => message.toJson()).toList(),
      );
      await sharedPreferences.setString(cachedMessagesKey, jsonString);
    } catch (e) {
      throw CacheException('خطا در ذخیره پیام‌ها');
    }
  }
}