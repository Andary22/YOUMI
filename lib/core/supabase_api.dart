import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youmi_dev/core/supabase_config.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/task_folder.dart';
import 'package:youmi_dev/models/task_template.dart';
import 'package:youmi_dev/models/user.dart';

class SupabaseApiException implements Exception {
  final String message;
  final int? statusCode;

  SupabaseApiException(this.message, {this.statusCode});

  @override
  String toString() => 'SupabaseApiException($statusCode): $message';
}

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
  });
}

class SupabaseApi {
  SupabaseApi._();

  static final SupabaseApi instance = SupabaseApi._();

  final http.Client _client = http.Client();
  String? _accessToken;
  String? _userId;
  String? _email;

  String? get accessToken => _accessToken;
  String? get userId => _userId;
  String? get email => _email;

  void updateSession(AuthSession? session) {
    _accessToken = session?.accessToken;
    _userId = session?.userId;
    _email = session?.email;
  }

  Future<AuthSession> signUp(String email, String password) async {
    final uri = Uri.parse('${SupabaseConfig.authBaseUrl}/signup');
    final response = await _client.post(
      uri,
      headers: _authHeaders(includeAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parseAuthResponse(response);
  }

  Future<AuthSession> signIn(String email, String password) async {
    final uri = Uri.parse(
      '${SupabaseConfig.authBaseUrl}/token?grant_type=password',
    );
    final response = await _client.post(
      uri,
      headers: _authHeaders(includeAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parseAuthResponse(response);
  }

  Future<void> signOut() async {
    if (_accessToken == null) {
      updateSession(null);
      return;
    }
    final uri = Uri.parse('${SupabaseConfig.authBaseUrl}/logout');
    final response = await _client.post(uri, headers: _authHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    updateSession(null);
  }

  Future<AppUser?> fetchProfile(String userId) async {
    final uri = _restUri('profiles', {
      'select': '*',
      'id': 'eq.$userId',
      'limit': '1',
    });
    final response = await _client.get(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    final payload = _decodeJson(response.body);
    if (payload is List && payload.isNotEmpty) {
      return AppUser.fromJson(payload.first as Map<String, dynamic>);
    }
    return null;
  }

  Future<AppUser> upsertProfile(AppUser user) async {
    final uri = _restUri('profiles');
    final response = await _client.post(
      uri,
      headers: _restHeaders(prefer: 'resolution=merge-duplicates,return=representation'),
      body: jsonEncode([user.toJson()]),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    final payload = _decodeJson(response.body);
    if (payload is List && payload.isNotEmpty) {
      return AppUser.fromJson(payload.first as Map<String, dynamic>);
    }
    throw SupabaseApiException('Profile upsert failed');
  }

  Future<List<TaskFolder>> fetchTaskFolders(String userId) async {
    final uri = _restUri('task_folders', {
      'select': '*',
      'user_id': 'eq.$userId',
      'order': 'title.asc',
    });
    final response = await _client.get(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    return _decodeList(response.body, TaskFolder.fromJson);
  }

  Future<TaskFolder> upsertTaskFolder(TaskFolder folder) async {
    final uri = _restUri('task_folders');
    final response = await _client.post(
      uri,
      headers: _restHeaders(prefer: 'resolution=merge-duplicates,return=representation'),
      body: jsonEncode([folder.toJson()]),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    final list = _decodeList(response.body, TaskFolder.fromJson);
    return list.first;
  }

  Future<void> deleteTaskFolder(String id) async {
    final uri = _restUri('task_folders', {'id': 'eq.$id'});
    final response = await _client.delete(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
  }

  Future<List<TaskTemplate>> fetchTaskTemplates(String userId) async {
    final uri = _restUri('task_templates', {
      'select': '*',
      'user_id': 'eq.$userId',
      'order': 'title.asc',
    });
    final response = await _client.get(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    return _decodeList(response.body, TaskTemplate.fromJson);
  }

  Future<TaskTemplate> upsertTaskTemplate(TaskTemplate template) async {
    final uri = _restUri('task_templates');
    final response = await _client.post(
      uri,
      headers: _restHeaders(prefer: 'resolution=merge-duplicates,return=representation'),
      body: jsonEncode([template.toJson()]),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    final list = _decodeList(response.body, TaskTemplate.fromJson);
    return list.first;
  }

  Future<void> deleteTaskTemplate(String id) async {
    final uri = _restUri('task_templates', {'id': 'eq.$id'});
    final response = await _client.delete(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
  }

  Future<List<Habit>> fetchHabits(String userId) async {
    final uri = _restUri('habits', {
      'select': '*',
      'user_id': 'eq.$userId',
      'order': 'title.asc',
    });
    final response = await _client.get(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    return _decodeList(response.body, Habit.fromJson);
  }

  Future<Habit> upsertHabit(Habit habit) async {
    final uri = _restUri('habits');
    final response = await _client.post(
      uri,
      headers: _restHeaders(prefer: 'resolution=merge-duplicates,return=representation'),
      body: jsonEncode([habit.toJson()]),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    final list = _decodeList(response.body, Habit.fromJson);
    return list.first;
  }

  Future<void> deleteHabit(String id) async {
    final uri = _restUri('habits', {'id': 'eq.$id'});
    final response = await _client.delete(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
  }

  Future<List<ActivityInstance>> fetchActivityInstances(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final uri = _restUri('activity_instances', {
      'select': '*',
      'user_id': 'eq.$userId',
      'scheduled_date': 'gte.${start.toIso8601String()}',
      'scheduled_date': 'lte.${end.toIso8601String()}',
      'order': 'scheduled_date.asc',
    });
    final response = await _client.get(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    return _decodeList(response.body, ActivityInstance.fromJson);
  }

  Future<ActivityInstance> upsertActivityInstance(
    ActivityInstance instance,
  ) async {
    final uri = _restUri('activity_instances');
    final response = await _client.post(
      uri,
      headers: _restHeaders(prefer: 'resolution=merge-duplicates,return=representation'),
      body: jsonEncode([instance.toJson()]),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    final list = _decodeList(response.body, ActivityInstance.fromJson);
    return list.first;
  }

  Future<void> updateActivityInstance(
    String id,
    Map<String, dynamic> patch,
  ) async {
    final uri = _restUri('activity_instances', {'id': 'eq.$id'});
    final response = await _client.patch(
      uri,
      headers: _restHeaders(prefer: 'return=representation'),
      body: jsonEncode(patch),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
  }

  Future<void> deleteActivityInstance(String id) async {
    final uri = _restUri('activity_instances', {'id': 'eq.$id'});
    final response = await _client.delete(uri, headers: _restHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
  }

  AuthSession _parseAuthResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    final decoded = _decodeJson(response.body);
    if (decoded == null) {
      throw SupabaseApiException(
        'Signup requires email confirmation. Check your inbox.',
      );
    }
    final payload = decoded as Map<String, dynamic>;
    final accessToken = payload['access_token'] as String?;
    final refreshToken = payload['refresh_token'] as String?;
    final user = payload['user'] as Map<String, dynamic>?;
    if (user == null) {
      throw SupabaseApiException('Invalid auth response');
    }
    if (accessToken == null || refreshToken == null) {
      throw SupabaseApiException(
        'Signup requires email confirmation. Check your inbox.',
      );
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user['id'] as String,
      email: user['email'] as String? ?? '',
    );
  }

  Map<String, String> _authHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'apikey': SupabaseConfig.anonKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    } else {
      headers['Authorization'] = 'Bearer ${SupabaseConfig.anonKey}';
    }
    return headers;
  }

  Map<String, String> _restHeaders({String? prefer, bool includeAuth = true}) {
    final headers = _authHeaders(includeAuth: includeAuth);
    if (prefer != null) {
      headers['Prefer'] = prefer;
    }
    return headers;
  }

  Uri _restUri(String table, [Map<String, String>? query]) {
    return Uri.parse('${SupabaseConfig.restBaseUrl}/$table')
        .replace(queryParameters: query);
  }

  SupabaseApiException _parseError(http.Response response) {
    String message = 'Request failed';
    try {
      final body = _decodeJson(response.body);
      if (body is Map<String, dynamic>) {
        message = body['error_description'] as String? ??
            body['message'] as String? ??
            body['error'] as String? ??
            message;
      }
    } catch (_) {
      message = response.body.isNotEmpty ? response.body : message;
    }
    if (response.body.isNotEmpty && message != response.body) {
      message = '$message | ${response.body}';
    }
    return SupabaseApiException(message, statusCode: response.statusCode);
  }

  dynamic _decodeJson(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    return jsonDecode(body);
  }

  List<T> _decodeList<T>(
    String body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final payload = _decodeJson(body);
    if (payload is! List) {
      return [];
    }
    return payload
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
