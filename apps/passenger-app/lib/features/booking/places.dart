import 'dart:async';
import 'dart:math';

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'draft.dart';

const placeDebounce = Duration(milliseconds: 250);

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
  });

  final String placeId;
  final String primaryText;
  final String secondaryText;

  static PlaceSuggestion? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final placeId = json['placeId'];
    final primaryText = json['primaryText'];
    final secondaryText = json['secondaryText'];
    if (placeId is! String ||
        primaryText is! String ||
        secondaryText is! String) {
      return null;
    }
    return PlaceSuggestion(
      placeId: placeId,
      primaryText: primaryText,
      secondaryText: secondaryText,
    );
  }
}

class PlaceDetails {
  const PlaceDetails({
    required this.placeId,
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String placeId;
  final String address;
  final double lat;
  final double lng;

  static PlaceDetails? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final placeId = json['placeId'];
    final address = json['address'];
    final lat = json['lat'];
    final lng = json['lng'];
    if (placeId is! String ||
        address is! String ||
        lat is! num ||
        lng is! num) {
      return null;
    }
    return PlaceDetails(
      placeId: placeId,
      address: address,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
    );
  }
}

/// Debounced autocomplete with abort + session token, matching dispatch-web.
class PlaceSearchController extends ChangeNotifier {
  PlaceSearchController(this._dio);

  final Dio _dio;
  String _text = '';
  List<PlaceSuggestion> _suggestions = const [];
  bool _open = false;
  String _session = _newSession();
  Timer? _debounce;
  CancelToken? _cancel;

  String get text => _text;
  List<PlaceSuggestion> get suggestions => _suggestions;
  bool get open => _open;

  void edit(String value) {
    _text = value;
    _open = true;
    if (value.trim().length < 3) {
      _cancel?.cancel();
      _suggestions = const [];
      notifyListeners();
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(placeDebounce, () => _search(value.trim()));
    notifyListeners();
  }

  void setText(String value) {
    _text = value;
    _open = false;
    _suggestions = const [];
    notifyListeners();
  }

  Future<PlaceDetails?> select(String placeId) async {
    final session = _session;
    _open = false;
    _suggestions = const [];
    notifyListeners();
    final response = await _dio.get<dynamic>(
      '/places/$placeId',
      queryParameters: {'session': session},
    );
    _session = _newSession();
    final details = PlaceDetails.tryParse(response.data);
    if (details != null) {
      _text = details.address;
      notifyListeners();
    }
    return details;
  }

  Future<void> _search(String query) async {
    _cancel?.cancel();
    final token = CancelToken();
    _cancel = token;
    try {
      final response = await _dio.get<dynamic>(
        '/places/autocomplete',
        queryParameters: {'q': query, 'session': _session},
        cancelToken: token,
      );
      if (token.isCancelled) return;
      final rows = response.data;
      final next = <PlaceSuggestion>[];
      if (rows is List) {
        for (final row in rows) {
          final item = PlaceSuggestion.tryParse(row);
          if (item != null) next.add(item);
        }
      }
      _suggestions = next;
      _open = true;
      notifyListeners();
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || token.isCancelled) return;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancel?.cancel();
    super.dispose();
  }
}

String _newSession() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

Future<PlaceStop?> reverseGeocode(Dio dio, double lat, double lng) async {
  final response = await dio.get<dynamic>(
    '/places/reverse',
    queryParameters: {'lat': lat, 'lng': lng},
  );
  final json = jsonMap(response.data);
  final address = json?['address'];
  if (address is! String || address.isEmpty) return null;
  return PlaceStop(address: address, lat: lat, lng: lng);
}
