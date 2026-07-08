import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mygate_coepd/config/app_config.dart';

/// A global navigator key that lets ApiService redirect to login from
/// outside the widget tree (e.g. when a token refresh fails).
///
/// Wire this up in your MaterialApp:
///   navigatorKey: ApiService.navigatorKey,
final GlobalKey<NavigatorState> apiNavigatorKey = GlobalKey<NavigatorState>();

class ApiService {
  // static const String baseUrl = 'https://app.mygatebell.com/backend';
  static const String baseUrl =
      'https://magenta-grouse-563358.hostingersite.com/backend';

  /// The path segment that identifies the refresh endpoint.
  /// Used to prevent infinite refresh loops.
  static const String _refreshPath = '/api/auth/refresh';

  late Dio dio;

  /// A static future to hold any ongoing refresh operation globally across
  /// all ApiService instances, preventing multiple concurrent refresh calls.
  static Future<String?>? _activeRefresh;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        // ── REQUEST ──────────────────────────────────────────────────────────
        onRequest: (options, handler) async {
          final isRefreshCall = options.uri.path.contains('/auth/refresh');

          String? token = AppConfig.token;

          // Inject device real-time for POST/PUT/PATCH requests via Header
          if (['POST', 'PUT', 'PATCH'].contains(options.method.toUpperCase())) {
            final String deviceTime = DateTime.now().toLocal().toString().split('.')[0];
            options.headers['X-Device-Time'] = deviceTime;
            
            // Still inject in body just in case some specific controllers look for it directly
            if (options.data is Map<String, dynamic>) {
              options.data['created_at'] = deviceTime;
              options.data['createdAt'] = deviceTime;
              options.data['updated_at'] = deviceTime;
              options.data['updatedAt'] = deviceTime;
            } else if (options.data is FormData) {
              options.data.fields.add(MapEntry('created_at', deviceTime));
              options.data.fields.add(MapEntry('createdAt', deviceTime));
              options.data.fields.add(MapEntry('updated_at', deviceTime));
              options.data.fields.add(MapEntry('updatedAt', deviceTime));
            }
          }

          if (token != null && !isRefreshCall) {
            // Preemptively refresh if the token is expired or about to expire
            if (_isTokenExpired(token)) {
              log(
                '[ApiService] Token expired/near-expiry — attempting proactive refresh',
              );
              final refreshed = await _doRefresh(token);
              if (refreshed != null) {
                token = refreshed;
              } else {
                // Refresh failed at request time → force logout
                log('[ApiService] Proactive refresh failed — logging out');
                await _logout();
                // Reject this request with a meaningful error
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    error: 'Session expired. Please log in again.',
                    type: DioExceptionType.cancel,
                  ),
                );
              }
            }
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // ── RESPONSE ─────────────────────────────────────────────────────────
        onResponse: (response, handler) {
          return handler.next(response);
        },

        // ── ERROR ─────────────────────────────────────────────────────────────
        onError: (DioException e, handler) async {
          final isRefreshCall = e.requestOptions.uri.path.contains(
            '/auth/refresh',
          );

          if (e.response?.statusCode == 401 && !isRefreshCall) {
            log('[ApiService] 401 received — attempting reactive refresh');
            final token = AppConfig.token;
            if (token != null) {
              final refreshed = await _doRefresh(token);
              if (refreshed != null) {
                // Retry the original request with the new token
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $refreshed';
                try {
                  final retryResp = await dio.fetch(opts);
                  return handler.resolve(retryResp);
                } on DioException catch (retryErr) {
                  if (retryErr.response?.statusCode != 401) {
                    // It's a standard API error, not an auth error. Forward it.
                    return handler.next(retryErr);
                  }
                  // If it's STILL 401, fall through to logout
                } catch (retryErr) {
                  // Unknown error, just forward it
                  return handler.next(e);
                }
              }
            }
            // All refresh attempts exhausted or retry still gave 401 — logout
            log('[ApiService] Reactive refresh failed — logging out');
            await _logout();
          }

          // ── Timeout Retry Logic ──
          final isTimeout =
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout;

          int retries = e.requestOptions.extra['retries'] as int? ?? 0;
          if (isTimeout && retries < 2) {
            log(
              '[ApiService] Timeout on ${e.requestOptions.path}. Retrying (${retries + 1}/2)...',
            );
            e.requestOptions.extra['retries'] = retries + 1;
            try {
              await Future.delayed(const Duration(seconds: 1));
              final retryResp = await dio.fetch(e.requestOptions);
              return handler.resolve(retryResp);
            } on DioException catch (retryErr) {
              return handler.next(retryErr);
            } catch (_) {
              return handler.next(e);
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Attempts to exchange the current (possibly expired) token for a new one.
  /// Returns the new token string on success, or null on failure.
  Future<String?> _doRefresh(String expiredToken) async {
    if (_activeRefresh != null) {
      log(
        '[ApiService] Refresh already in progress — awaiting existing global refresh',
      );
      return await _activeRefresh;
    }

    _activeRefresh = _performRefreshRequest(expiredToken);
    try {
      final result = await _activeRefresh;
      return result;
    } finally {
      _activeRefresh = null;
    }
  }

  Future<String?> _performRefreshRequest(String expiredToken) async {
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $expiredToken',
          },
        ),
      );
      final response = await refreshDio.post('$baseUrl/api/auth/refresh');
      if (response.data != null && response.data['status'] == true) {
        final newToken = response.data['data']['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          await AppConfig.setToken(newToken);
          log('[ApiService] Token refreshed successfully');
          return newToken;
        }
      }
    } catch (e) {
      log('[ApiService] Refresh request failed: $e');
    }
    return null;
  }

  /// Clears all stored credentials and navigates to the login screen.
  Future<void> _logout() async {
    await AppConfig.setToken(null);
    // Navigate to auth screen — works from anywhere because we use the global key
    final ctx = apiNavigatorKey.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).pushNamedAndRemoveUntil('/auth', (route) => false);
    }
  }

  /// Returns true if the JWT is already expired OR will expire within
  /// the next 5 minutes (300 seconds).
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payloadMap = json.decode(payload);
      if (payloadMap is Map && payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // Refresh proactively if < 5 minutes remain, or already expired
        return (exp - now) < 300;
      }
      // No 'exp' field — treat as non-expiring
      return false;
    } catch (e) {
      // Malformed token → force refresh/login
      return true;
    }
  }
}
