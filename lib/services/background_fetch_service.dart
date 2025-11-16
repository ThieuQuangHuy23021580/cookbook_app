import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
/// Service để fetch data trong background isolate
/// Không block main UI thread, performance cao
class BackgroundFetchService {

  static SendPort? _sendPort;
  static Isolate? _isolate;
  static ReceivePort? _receivePort;
  /// Start background isolate
  static Future<void> initialize() async {
    if (_isolate != null) {
      print(' [BACKGROUND] Isolate already running');
      return;
    }
    try {
      _receivePort = ReceivePort();
      _isolate = await Isolate.spawn(
        _backgroundIsolateEntry,
        _receivePort!.sendPort,
      );
      _sendPort = await _receivePort!.first as SendPort;
      print(' [BACKGROUND] Isolate initialized successfully');
    } catch (e) {
      print(' [BACKGROUND] Failed to initialize isolate: $e');
    }
  }
  /// Stop background isolate
  static void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
    print(' [BACKGROUND] Isolate stopped');
  }
  /// Fetch data in background isolate (non-blocking)
  static Future<Map<String, dynamic>> fetchInBackground({
    required String url,
    required Map<String, String> headers,
  }) async {
    if (_sendPort == null) {
      await initialize();
    }

    final responsePort = ReceivePort();
    _sendPort!.send({
      'url': url,
      'headers': headers,
      'responsePort': responsePort.sendPort,
    });
    final response = await responsePort.first as Map<String, dynamic>;
    responsePort.close();
    return response;
  }
  /// Background isolate entry point
  static void _backgroundIsolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    receivePort.listen((message) async {
      if (message is Map<String, dynamic>) {
        final url = message['url'] as String;
        final headers = Map<String, String>.from(message['headers'] as Map);
        final responsePort = message['responsePort'] as SendPort;
        try {
          print(' [ISOLATE] Fetching: $url');
          final response = await http.get(
            Uri.parse(url),
            headers: headers,
          ).timeout(ApiConfig.timeout);
          print(' [ISOLATE] Response: ${response.statusCode}');
          responsePort.send({
            'success': true,
            'statusCode': response.statusCode,
            'body': response.body,
          });
        } catch (e) {
          print(' [ISOLATE] Error: $e');
          responsePort.send({
            'success': false,
            'error': e.toString(),
          });
        }
      }
    });
  }
  /// Fetch recently viewed recipes in background
  static Future<List<dynamic>?> fetchRecentlyViewed({
    required String token,
    int limit = 9,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/recipes/recently-viewed?limit=$limit';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      print(' [BACKGROUND] Fetching recently viewed in isolate...');
      final result = await fetchInBackground(url: url, headers: headers);
      if (result['success'] == true && result['statusCode'] == 200) {
        final List<dynamic> data = jsonDecode(result['body']);
        print(' [BACKGROUND] Fetched ${data.length} recipes');
        return data;
      } else {
        print(' [BACKGROUND] Failed: ${result['error'] ?? result['body']}');
        return null;
      }
    } catch (e) {
      print(' [BACKGROUND] Error fetching recently viewed: $e');
      return null;
    }
  }
  /// Fetch notification count in background
  static Future<int?> fetchNotificationCount({
    required String token,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/notifications/unread/count';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      print(' [BACKGROUND] Fetching notification count in isolate...');
      final result = await fetchInBackground(url: url, headers: headers);
      if (result['success'] == true && result['statusCode'] == 200) {
        final data = jsonDecode(result['body']);
        final count = data['count'] as int;
        print(' [BACKGROUND] Notification count: $count');
        return count;
      } else {
        print(' [BACKGROUND] Failed: ${result['error'] ?? result['body']}');
        return null;
      }
    } catch (e) {
      print(' [BACKGROUND] Error fetching notification count: $e');
      return null;
    }
  }
  /// Fetch all recipes in background
  static Future<List<dynamic>?> fetchAllRecipes({
    required String token,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/recipes';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      print(' [BACKGROUND] Fetching all recipes in isolate...');
      final result = await fetchInBackground(url: url, headers: headers);
      if (result['success'] == true && result['statusCode'] == 200) {
        final List<dynamic> data = jsonDecode(result['body']);
        print(' [BACKGROUND] Fetched ${data.length} recipes');
        return data;
      } else {
        print(' [BACKGROUND] Failed: ${result['error'] ?? result['body']}');
        return null;
      }
    } catch (e) {
      print(' [BACKGROUND] Error fetching recipes: $e');
      return null;
    }
  }
}
/// Smart polling service với background isolate
class AdaptiveBackgroundPolling {
  Timer? _timer;
  Duration _currentInterval = const Duration(seconds: 60);
  DateTime _lastUserActivity = DateTime.now();
  bool _isPolling = false;
  void Function()? onDataFetched;
  AdaptiveBackgroundPolling({this.onDataFetched});
  /// Start adaptive polling with background isolate
  Future<void> start() async {
    if (_isPolling) {
      print(' [ADAPTIVE] Already polling');
      return;
    }
    _isPolling = true;
    print(' [ADAPTIVE] Starting adaptive background polling');
    await BackgroundFetchService.initialize();
    _schedulePoll();
  }

  void _schedulePoll() {
    _timer?.cancel();
    _timer = Timer(_currentInterval, () async {
      if (!_isPolling) return;
      _adjustInterval();
      print(' [ADAPTIVE] Polling with interval: ${_currentInterval.inSeconds}s');
      onDataFetched?.call();
      _schedulePoll();
    });
  }

  void _adjustInterval() {

    final now = DateTime.now();
    final inactiveDuration = now.difference(_lastUserActivity);
    if (inactiveDuration.inSeconds < 30) {
      _currentInterval = const Duration(seconds: 10);
      print(' [ADAPTIVE] User very active → 10s interval');
    } else if (inactiveDuration.inSeconds < 60) {
      _currentInterval = const Duration(seconds: 30);
      print(' [ADAPTIVE] User active → 30s interval');
    } else if (inactiveDuration.inSeconds < 300) {
      _currentInterval = const Duration(seconds: 60);
      print(' [ADAPTIVE] User idle → 60s interval');
    } else {
      _currentInterval = const Duration(minutes: 5);
      print(' [ADAPTIVE] User very idle → 5min interval');
    }
  }
  /// Mark user activity to adjust polling frequency
  void markActivity() {
    _lastUserActivity = DateTime.now();
    print(' [ADAPTIVE] User activity detected');
  }
  /// Stop polling
  void stop() {
    _isPolling = false;
    _timer?.cancel();
    _timer = null;
    BackgroundFetchService.dispose();
    print(' [ADAPTIVE] Polling stopped');
  }
  /// Get current interval
  Duration get currentInterval => _currentInterval;
}
