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
  String toString() {
    return 'SupabaseApiException($statusCode): $message';
  }
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

  String? get accessToken {
    return _accessToken;
  }

  String? get userId {
    return _userId;
  }

  String? get email {
    return _email;
  }

  void updateSession(AuthSession? session) {
    if (session == null) {
      _accessToken = null;
      _userId = null;
      _email = null;
      return;
    }
    _accessToken = session.accessToken;
    _userId = session.userId;
    _email = session.email;
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

  Future<void> updatePassword(String newPassword) async {
    if (_accessToken == null) {
      throw SupabaseApiException('Not authenticated');
    }
    final uri = Uri.parse('${SupabaseConfig.authBaseUrl}/user');
    final response = await _client.put(
      uri,
      headers: _authHeaders(),
      body: jsonEncode({'password': newPassword}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    if (_accessToken == null) {
      throw SupabaseApiException('Not authenticated');
    }
    final uri = Uri.parse('${SupabaseConfig.authBaseUrl}/user');
    final response = await _client.put(
      uri,
      headers: _authHeaders(),
      body: jsonEncode({'email': newEmail}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseError(response);
    }
    _email = newEmail;
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

  Future<AppUser> upsertProfile(AppUser user, {bool includeNameField = false}) async {
    final uri = _restUri('profiles');
    final Map<String, dynamic> data = includeNameField
        ? user.toJson()
        : user.toJsonCreate();
    final response = await _client.post(
      uri,
      headers: _restHeaders(prefer: 'resolution=merge-duplicates,return=representation'),
      body: jsonEncode([data]),
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
    final rangeFilter =
        '(scheduled_date.gte.${start.toIso8601String()},'
        'scheduled_date.lte.${end.toIso8601String()})';
    final uri = _restUri('activity_instances', {
      'select': '*',
      'user_id': 'eq.$userId',
      'and': rangeFilter,
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
    String email = '';
    final String? rawEmail = user['email'] as String?;
    if (rawEmail != null) {
      email = rawEmail;
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user['id'] as String,
      email: email,
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
        final String? friendly = _friendlyMessageFromBody(body);
        if (friendly != null) {
          message = friendly;
        } else if (body['error_description'] is String) {
          message = body['error_description'] as String;
        } else if (body['message'] is String) {
          message = body['message'] as String;
        } else if (body['msg'] is String) {
          message = body['msg'] as String;
        } else if (body['error'] is String) {
          message = body['error'] as String;
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }
    return SupabaseApiException(message, statusCode: response.statusCode);
  }

  String? _friendlyMessageFromBody(Map<String, dynamic> body) {
    String? errorCode = body['error_code'] as String?;
    if (errorCode == null && body['error code'] is String) {
      errorCode = body['error code'] as String?;
    }
    String? error = body['error'] as String?;
    String? message = body['message'] as String?;
    String? msg = body['msg'] as String?;
    String? code = body['code'] as String?;

    if (errorCode != null) {
      errorCode = errorCode.toLowerCase();
    }
    if (error != null) {
      error = error.toLowerCase();
    }
    if (message != null) {
      message = message.toLowerCase();
    }
    if (msg != null) {
      msg = msg.toLowerCase();
    }
    if (code != null) {
      code = code.toLowerCase();
    }

    if (errorCode != null || error != null) {
      String identifier = '';
      if (errorCode != null) {
        identifier = errorCode;
      } else if (error != null) {
        identifier = error;
      }
      if (identifier.contains('invalid_credentials') ||
          identifier.contains('invalid_grant')) {
        return 'Email or password is incorrect.';
      }
      if (identifier.contains('email_not_confirmed')) {
        return 'Please confirm your email, then try again.';
      }
      if (identifier.contains('user_already_registered')) {
        return 'An account with this email already exists. Try signing in.';
      }
      if (identifier.contains('weak_password')) {
        return 'Password is too weak. Try a stronger password.';
      }
      if (identifier.contains('email_address_invalid')) {
        return 'Please enter a valid email address.';
      }
      if (identifier.contains('signup_disabled')) {
        return 'Sign up is currently disabled. Please try again later.';
      }
    }

    final buffer = StringBuffer();
    if (message != null && message.isNotEmpty) {
      buffer.write(message);
    }
    if (msg != null && msg.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(msg);
    }
    if (code != null && code.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(code);
    }
    final text = buffer.toString();
    if (text.contains('invalid login credentials')) {
      return 'Email or password is incorrect.';
    }
    if (text.contains('email not confirmed')) {
      return 'Please confirm your email, then try again.';
    }
    if (text.contains('password should be at least')) {
      return 'Password is too weak. Try a stronger password.';
    }
    return null;
  }

  dynamic _decodeJson(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    String cleaned = body;
    if (cleaned.startsWith('\uFEFF')) {
      cleaned = cleaned.substring(1);
    }
    try {
      return jsonDecode(cleaned);
    } catch (_) {
      final int start = cleaned.indexOf('{');
      final int end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        return jsonDecode(cleaned.substring(start, end + 1));
      }
    }
    return null;
  }

  List<T> _decodeList<T>(
    String body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final payload = _decodeJson(body);
    if (payload is! List) {
      return [];
    }
    final List<T> items = [];
    for (int i = 0; i < payload.length; i++) {
      items.add(fromJson(payload[i] as Map<String, dynamic>));
    }
    return items;
  }
}